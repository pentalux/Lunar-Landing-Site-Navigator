import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import "Mission.js" as Mission
import "SceneMath.js" as Math3
import "Terrain.js" as Terrain
Model {
 id: root
 property var site: Mission.sites[0]
 property bool slopeVisible: false
 readonly property bool polarMapping: Math.abs(site.lat)>=75
 readonly property string albedoSource: polarMapping?(site.lat>0?"assets/science/moon-north-albedo.jpg":"assets/science/moon-south-albedo.jpg"):"assets/science/moon-albedo.jpg"
 readonly property var generated: generate()
 readonly property var vertices: generated.p.map(function(p){return [p.x,p.y,p.z];})
 readonly property int vertexCount: generated.p.length
 function generate(){
  var axis=[],b=Mission.basis(site),p=[],uv=[],detailUV=[],norm=[],colors=[],idx=[],r=Terrain.radius
  // One continuous mesh, with 75 m cells around the lander and coarser cells toward the border.
  for(var k=0;k<32;k++)axis.push(-30000+k*750)
  for(k=0;k<=160;k++)axis.push(-6000+k*75)
  for(k=1;k<=32;k++)axis.push(6000+k*750)
  var n=axis.length-1
  for(var j=0;j<=n;j++)for(var i=0;i<=n;i++){
   var x=axis[i],z=axis[j],v=[b.u[0]*r+b.e[0]*x-b.n[0]*z,b.u[1]*r+b.e[1]*x-b.n[1]*z,b.u[2]*r+b.e[2]*x-b.n[2]*z],len=Math.sqrt(Mission.dot(v,v)),lat=Math.asin(v[2]/len)*180/Math.PI,lon=Math.atan2(v[1],v[0])*180/Math.PI,rr=r+Terrain.elevation(lat,lon),rel=[v[0]/len*rr-b.u[0]*(r+site.elevation),v[1]/len*rr-b.u[1]*(r+site.elevation),v[2]/len*rr-b.u[2]*(r+site.elevation)]
   p.push(Qt.vector3d(Mission.dot(rel,b.e)/100,Mission.dot(rel,b.u)/100,-Mission.dot(rel,b.n)/100))
   var u=polarMapping?Terrain.polarUV(lat,lon,site.lat>0?1:-1):Terrain.uv(lat,lon)
   if(!polarMapping){
    if(u[0]-(site.lon+180)/360>.5)u[0]-=1
    if(u[0]-(site.lon+180)/360<-.5)u[0]+=1
   }
   uv.push(Qt.vector2d(u[0],u[1]));detailUV.push(Qt.vector2d(x/200,-z/200))
  }
  for(j=0;j<=n;j++)for(i=0;i<=n;i++){
   k=j*(n+1)+i
   var l=p[j*(n+1)+Math.max(0,i-1)],right=p[j*(n+1)+Math.min(n,i+1)],down=p[Math.min(n,j+1)*(n+1)+i],up=p[Math.max(0,j-1)*(n+1)+i],dx=(right.y-l.y)/Math.max(.001,right.x-l.x),dz=(down.y-up.y)/Math.max(.001,down.z-up.z),ln=Math.hypot(dx,1,dz)
   norm.push(Qt.vector3d(-dx/ln,1/ln,-dz/ln))
   var slope=Math.atan(Math.hypot(dx,dz))*180/Math.PI,t=Mission.clamp((slope-8)/12,0,1)
   colors.push(Qt.vector4d(.16+.64*t,.55-.34*t,.26-.13*t,1))
   if(j<n&&i<n){var a=k,c=a+n+1;idx.push(a,c,a+1,a+1,c,c+1);}
  }
  return {p:p,n:norm,c:colors,i:idx,u:uv,detailUV:detailUV,axis:axis.map(function(x){return x/100;}),size:n}
 }
 function cell(axis,x){var lo=0,hi=axis.length-1;while(hi-lo>1){var mid=(lo+hi)>>1;if(axis[mid]<=x)lo=mid;else hi=mid;}return lo;}
 function heightAt(x,z){
  var g=generated,n=g.size,i=cell(g.axis,x),j=cell(g.axis,z),points=vertices
  for(var y=Math.max(0,j-2);y<=Math.min(n-1,j+2);y++)for(var xx=Math.max(0,i-2);xx<=Math.min(n-1,i+2);xx++){
   var a=y*(n+1)+xx,b=a+n+1,h=Math3.triangleHeight(points[a],points[b],points[a+1],x,z)
   if(h!==null)return h
   h=Math3.triangleHeight(points[a+1],points[b],points[b+1],x,z);if(h!==null)return h
  }
  return 0
 }
 geometry: ProceduralMesh { positions: root.generated.p; normals: root.generated.n; colors: root.slopeVisible?root.generated.c:[]; indexes: root.generated.i; uv0s: root.generated.u; uv1s: root.generated.detailUV }
 materials: PrincipledMaterial {
  roughness: 1
  baseColor: root.slopeVisible?"white":"#e0e0e0"
  baseColorMap: Texture { source: root.slopeVisible?"":root.albedoSource; tilingModeHorizontal: root.polarMapping?Texture.ClampToEdge:Texture.Repeat; generateMipmaps: true; mipFilter: Texture.Linear }
  normalMap: Texture { source: "assets/regolith-normal.png"; indexUV: 1; tilingModeHorizontal: Texture.Repeat; tilingModeVertical: Texture.Repeat }
  normalStrength: .15
  cullMode: Material.NoCulling
 }
}
