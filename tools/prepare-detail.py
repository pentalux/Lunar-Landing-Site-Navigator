"""Prepare aligned geographic geometry and tiled, unaveraged LOLA samples."""
import pathlib,sys,json,struct,math
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python-libs'))
import numpy as np,rasterio
from rasterio.enums import Resampling
from rasterio.windows import Window
CACHE=ROOT/'tools/data';OUT=ROOT/'HackathonContent/assets/science'
TILES=OUT/'heights';TILES.mkdir(exist_ok=True)
R=1737400.
global_dem=rasterio.open(CACHE/'ldem_64_uint.tif')
polar_dem=rasterio.open(CACHE/'polar.tif')
global_h=global_dem.read(1)

def sample(lat,lon):
 x=(lon+180)/360*global_dem.width-.5;y=np.clip((90-lat)/180*global_dem.height-.5,0,global_dem.height-1)
 i=np.floor(x).astype(int);j=np.floor(y).astype(int);fx=x-i;fy=y-j
 def at(a,b):return global_h[np.clip(b,0,global_dem.height-1),a%global_dem.width].astype(float)*.5-10000
 return (1-fy)*(at(i,j)*(1-fx)+at(i+1,j)*fx)+fy*(at(i,j+1)*(1-fx)+at(i+1,j+1)*fx)


nx,ny=1024,512
if '--metadata-only' not in sys.argv:
 for name,ds,size in [('global',global_dem,720),('south',polar_dem,512)]:
  for row in range(math.ceil(ds.height/size)):
   for col in range(math.ceil(ds.width/size)):
    data=ds.read(1,window=Window(col*size,row*size,size,size),boundless=True,fill_value=65535 if name=='global' else np.nan)
    if name=='south':data=np.where(np.isfinite(data),np.clip(np.rint((data+10000)*2),0,65534),65535)
    (TILES/f'{name}-{row}-{col}.bin').write_bytes(np.asarray(data,dtype='<u2').tobytes())
  print('Tiled',name,ds.width,ds.height,flush=True)

 # Uniform global overview mesh. Local geometry is sampled separately at full data resolution.
 nx,ny=1024,512
 lon,lat=np.meshgrid(np.linspace(-180,180,nx+1),np.linspace(90,-90,ny+1))
 a=np.radians(lat);b=np.radians(lon);up=np.stack([np.cos(a)*np.cos(b),np.sin(a),-np.cos(a)*np.sin(b)],-1)
 h=sample(lat,lon);p=up*(1+h[...,None]/R)
 east=np.stack([-np.sin(b),np.zeros_like(b),-np.cos(b)],-1)
 north=np.stack([-np.sin(a)*np.cos(b),np.cos(a),np.sin(a)*np.sin(b)],-1)
 dlat=180/global_dem.height;dlon=360/global_dem.width
 dx=(sample(lat,lon+dlon)-sample(lat,lon-dlon))/(2*R*np.maximum(.001,np.cos(a))*np.radians(dlon))
 dn=(sample(np.minimum(90,lat+dlat),lon)-sample(np.maximum(-90,lat-dlat),lon))/(2*R*np.radians(dlat))
 norm=up-east*dx[...,None]-north*dn[...,None];norm/=np.linalg.norm(norm,axis=-1)[...,None]
 uv=np.stack([(lon+180)/360,(90-lat)/180],-1)
 grid=np.arange((ny+1)*(nx+1)).reshape(ny+1,nx+1);q=grid[:-1,:-1].ravel();indices=np.stack([q,q+nx+1,q+1,q+1,q+nx+1,q+nx+2],-1).ravel()
 arrays=[p.reshape(-1,3).astype('<f4'),norm.reshape(-1,3).astype('<f4'),uv.reshape(-1,2).astype('<f4'),indices.astype('<u4')]
 data=b'';views=[];accessors=[]
 for i,arr in enumerate(arrays):
  views.append(dict(buffer=0,byteOffset=len(data),byteLength=arr.nbytes,target=34963 if i==3 else 34962));data+=arr.tobytes()
  accessors.append(dict(bufferView=i,componentType=5125 if i==3 else 5126,count=len(arr),type=['VEC3','VEC3','VEC2','SCALAR'][i],**(dict(min=arr.min(axis=0).tolist(),max=arr.max(axis=0).tolist()) if i==0 else {})))
 doc=dict(asset=dict(version='2.0',generator='Aligned NASA LOLA geographic mesh'),scene=0,scenes=[dict(nodes=[0])],nodes=[dict(mesh=0)],meshes=[dict(primitives=[dict(attributes=dict(POSITION=0,NORMAL=1,TEXCOORD_0=2),indices=3,material=0)])],materials=[dict(pbrMetallicRoughness=dict(metallicFactor=0,roughnessFactor=1))],buffers=[dict(byteLength=len(data))],bufferViews=views,accessors=accessors)
 j=json.dumps(doc,separators=(',',':')).encode();j+=b' '*((-len(j))%4)
 (OUT/'moon-topography.glb').write_bytes(struct.pack('<5I',0x46546c67,2,28+len(j)+len(data),len(j),0x4e4f534a)+j+struct.pack('<2I',len(data),0x004e4942)+data)
 print('Global mesh',len(p.reshape(-1,3)),'vertices',flush=True)

 # Keep the NASA albedo in geographic orientation, with no baked synthetic craters.
 with rasterio.open(CACHE/'lroc_color_poles_16k.tif') as color:
  rgb=color.read([1,2,3])
  with rasterio.open(OUT/'moon-albedo.jpg','w',driver='JPEG',width=color.width,height=color.height,count=3,dtype='uint8',quality=94) as output:output.write(rgb)
 print('Prepared 16K geographic albedo',flush=True)

 # Detail normal map is derived from DEM slopes, not from color-image contrast.
 width,height=8192,4096
 with rasterio.open(OUT/'moon-normals.png','w',driver='PNG',width=width,height=height,count=3,dtype='uint8') as output:
  rows=[]
  for start in range(0,height,128):
   lo,la=np.meshgrid((np.arange(width)+.5)/width*360-180,90-(np.arange(start,min(height,start+128))+.5)/height*180)
   east_slope=(sample(la,lo+dlon)-sample(la,lo-dlon))/(2*R*np.maximum(.001,np.cos(np.radians(la)))*np.radians(dlon))
   north_slope=(sample(np.minimum(90,la+dlat),lo)-sample(np.maximum(-90,la-dlat),lo))/(2*R*np.radians(dlat))
   normal=np.stack([-east_slope,-north_slope,np.ones_like(la)],0);normal/=np.linalg.norm(normal,axis=0)
   output.write(np.asarray(np.clip((normal+1)*127.5,0,255),dtype='uint8'),window=Window(0,start,width,normal.shape[1]))
 print('Prepared DEM-derived normal map',flush=True)

 # Embed aligned appearance maps so the same generated globe works in QDS and in resources.
 for filename,mime in [('moon-albedo.jpg','image/jpeg'),('moon-normals.png','image/png')]:
  image=(OUT/filename).read_bytes();views.append(dict(buffer=0,byteOffset=len(data),byteLength=len(image)));data+=image;data+=b'\0'*((-len(data))%4)
  doc.setdefault('images',[]).append(dict(bufferView=len(views)-1,mimeType=mime))
 doc['samplers']=[dict(wrapS=10497,wrapT=33071,magFilter=9729,minFilter=9987)]
 doc['textures']=[dict(source=0,sampler=0),dict(source=1,sampler=0)]
 doc['materials'][0]['pbrMetallicRoughness']['baseColorTexture']=dict(index=0)
 doc['materials'][0]['normalTexture']=dict(index=1,scale=1)
 doc['buffers'][0]['byteLength']=len(data)
 j=json.dumps(doc,separators=(',',':')).encode();j+=b' '*((-len(j))%4)
 (OUT/'moon-topography.glb').write_bytes(struct.pack('<5I',0x46546c67,2,28+len(j)+len(data),len(j),0x4e4f534a)+j+struct.pack('<2I',len(data),0x004e4942)+data)

# Recompute preset elevations and skyline masks from the same samples as the viewer.
polar_h=polar_dem.read(1)
def elevation(lat,lon):
 result=sample(lat,lon)
 rho=2*R*np.tan(np.pi/4+np.radians(lat)/2);xp=(rho*np.sin(np.radians(lon))+304000)/80-.5;yp=(304000-rho*np.cos(np.radians(lon)))/80-.5
 valid=(lat< -80)&(xp>=1)&(xp<7598)&(yp>=1)&(yp<7598)
 i=np.clip(np.floor(xp).astype(int),0,7598);j=np.clip(np.floor(yp).astype(int),0,7598);fx=xp-i;fy=yp-j
 p=(1-fy)*(polar_h[j,i]*(1-fx)+polar_h[j,i+1]*fx)+fy*(polar_h[j+1,i]*(1-fx)+polar_h[j+1,i+1]*fx)
 return np.where(valid&np.isfinite(p),p,result)
provenance=json.loads((OUT/'provenance.json').read_text());sites=provenance['terrain']
for s in sites:
 a,b=np.radians([s['lat'],s['lon']]);up=np.array([np.cos(a)*np.cos(b),np.cos(a)*np.sin(b),np.sin(a)]);east=np.array([-np.sin(b),np.cos(b),0]);north=np.cross(up,east)
 h0=float(elevation(np.array(s['lat']),np.array(s['lon'])));s['elevation']=round(h0*2)/2;rho=2*R*np.tan(np.pi/4+a/2);xp=(rho*np.sin(b)+304000)/80-.5;yp=(304000-rho*np.cos(b))/80-.5;s['resolution']=80 if s['lat']< -80 and 1<=xp<7598 and 1<=yp<7598 else 474;s['meshStep']=75;s['extent']=60000
 az=np.radians(np.arange(360));distance=np.geomspace(s['resolution'],100000,420)
 points=up*R+distance[None,:,None]*(np.sin(az)[:,None,None]*east+np.cos(az)[:,None,None]*north);length=np.linalg.norm(points,axis=-1)
 heights=elevation(np.degrees(np.arcsin(points[...,2]/length)),np.degrees(np.arctan2(points[...,1],points[...,0])))
 points=points/length[...,None]*(R+heights)[...,None];relative=points-up*(R+s['elevation']);vertical=relative@up;horizontal=np.hypot(relative@east,relative@north)
 s['horizons']=[np.round(np.degrees(np.arctan2(vertical-height,horizontal)).max(axis=1),4).tolist() for height in [0,2,5,10]]
 print('Updated skyline',s['name'],s['elevation'],flush=True)
terrain_js=OUT/'TerrainData.js';old=terrain_js.read_text();prefix=old.index('\nvar width=')
terrain_js.write_text('.pragma library\nvar sites=JSON.parse('+json.dumps(json.dumps(sites,separators=(',',':')))+');'+old[prefix:])
provenance['terrain']=sites;provenance['sources']['detailedGlobal']='https://svs.gsfc.nasa.gov/vis/a000000/a004700/a004720/ldem_64_uint.tif'
(OUT/'provenance.json').write_text(json.dumps(provenance,indent=2))

manifest=dict(source='NASA LOLA LDEM 64 ppd / GSFC south polar 80 m',globalWidth=global_dem.width,globalHeight=global_dem.height,globalTileSize=720,globalResolution=2*math.pi*R/global_dem.width,polarWidth=polar_dem.width,polarHeight=polar_dem.height,polarTileSize=512,polarTransform=list(polar_dem.transform)[:6],polarResolution=80,encoding='little-endian uint16; height = value * 0.5 - 10000 metres; 65535 = unavailable',albedoWidth=16384,albedoHeight=8192,globalMeshColumns=nx,globalMeshRows=ny,sourceUrls=['https://svs.gsfc.nasa.gov/4720/','https://pgda.gsfc.nasa.gov/products/90'])
(OUT/'detail-provenance.json').write_text(json.dumps(manifest,indent=2))
if '--metadata-only' not in sys.argv:
 import subprocess
 subprocess.run([sys.executable,str(ROOT/'tools/fix-polar-textures.py')],check=True)
