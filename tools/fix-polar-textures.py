"""Use stereographic cap textures and UVs to remove lunar polar singularities."""
import pathlib,sys,json,struct
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python-libs'))
import numpy as np,rasterio
OUT=ROOT/'HackathonContent/assets/science';R=1737400.;EXTENT=1500000.
with rasterio.open(ROOT/'tools/data/ldem_64_uint.tif') as source:heights=source.read(1)
with rasterio.open(OUT/'moon-albedo.jpg') as source:albedo=source.read([1,2,3])

def height(lat,lon):
 rows,cols=heights.shape;x=(lon+180)/360*cols-.5;y=np.clip((90-lat)/180*rows-.5,0,rows-1)
 i=np.floor(x).astype(int);j=np.floor(y).astype(int);fx=x-i;fy=y-j
 def h(a,b):return heights[np.clip(b,0,rows-1),a%cols].astype(float)*.5-10000
 return (1-fy)*(h(i,j)*(1-fx)+h(i+1,j)*fx)+fy*(h(i,j+1)*(1-fx)+h(i+1,j+1)*fx)

def from_polar(x,y,pole):
 rho=np.hypot(x,y)
 return pole*(90-2*np.degrees(np.arctan(rho/(2*R)))),np.degrees(np.arctan2(x,-pole*y))

def position(lat,lon):
 a=np.radians(lat);b=np.radians(lon)
 return np.stack([np.cos(a)*np.cos(b),np.sin(a),-np.cos(a)*np.sin(b)],-1)*(1+height(lat,lon)[...,None]/R)

def polar_position(x,y,pole):return position(*from_polar(x,y,pole))
def radial(x,y,pole):
 lat,lon=from_polar(x,y,pole);a=np.radians(lat);b=np.radians(lon)
 return np.stack([np.cos(a)*np.cos(b),np.sin(a),-np.cos(a)*np.sin(b)],-1)

def image_sample(lat,lon):
 channels,rows,cols=albedo.shape
 x=(lon+180)/360*cols-.5;y=np.clip((90-lat)/180*rows-.5,0,rows-1)
 i=np.floor(x).astype(int);j=np.floor(y).astype(int);fx=x-i;fy=y-j
 def c(a,b):return albedo[:,np.clip(b,0,rows-1),a%cols].astype(np.float32)
 return np.asarray(np.clip((1-fy)*(c(i,j)*(1-fx)+c(i+1,j)*fx)+fy*(c(i,j+1)*(1-fx)+c(i+1,j+1)*fx),0,255),dtype='uint8')

for pole,name in [(1,'north'),(-1,'south')]:
 size=4096;image=np.empty((3,size,size),dtype='uint8')
 for row in range(0,size,128):
  x,y=np.meshgrid(((np.arange(size)+.5)/size*2-1)*EXTENT,(1-(np.arange(row,min(size,row+128))+.5)/size*2)*EXTENT)
  image[:,row:row+128]=image_sample(*from_polar(x,y,pole))
 with rasterio.open(OUT/f'moon-{name}-albedo.jpg','w',driver='JPEG',width=size,height=size,count=3,dtype='uint8',quality=94) as target:target.write(image)
 print('Prepared stereographic',name,'albedo',flush=True)

 # Normal-map tangent axes follow the cap's actual glTF U/V directions.
 normal_size=4096;normal_image=np.empty((3,normal_size,normal_size),dtype='uint8')
 for row in range(0,normal_size,128):
  x,y=np.meshgrid(((np.arange(normal_size)+.5)/normal_size*2-1)*EXTENT,(1-(np.arange(row,min(normal_size,row+128))+.5)/normal_size*2)*EXTENT)
  dx=polar_position(x+240,y,pole)-polar_position(x-240,y,pole);dy=polar_position(x,y+240,pole)-polar_position(x,y-240,pole)
  n=np.cross(dx,dy);n/=np.linalg.norm(n,axis=-1)[...,None]
  tangent=radial(x+240,y,pole)-radial(x-240,y,pole);tangent/=np.linalg.norm(tangent,axis=-1)[...,None]
  bitangent=radial(x,y-240,pole)-radial(x,y+240,pole);bitangent/=np.linalg.norm(bitangent,axis=-1)[...,None]
  normal=np.stack([np.sum(n*tangent,axis=-1),np.sum(n*bitangent,axis=-1),np.sum(n*radial(x,y,pole),axis=-1)],0)
  normal_image[:,row:row+128]=np.asarray(np.clip((normal+1)*127.5,0,255),dtype='uint8')
 with rasterio.open(OUT/f'moon-{name}-normals.png','w',driver='PNG',width=normal_size,height=normal_size,count=3,dtype='uint8') as target:target.write(normal_image)


# glTF V points south in the cylindrical band, so the green component is +north slope.
with rasterio.open(OUT/'moon-normals.png') as source:normal=source.read()
normal[1]=255-normal[1]
with rasterio.open(OUT/'moon-band-normals.png','w',driver='PNG',width=normal.shape[2],height=normal.shape[1],count=3,dtype='uint8') as target:target.write(normal)

data=bytearray();views=[];accessors=[];meshes=[];nodes=[]
def append_array(values,kind):
 array=np.asarray(values,dtype='<u4' if kind=='SCALAR' else '<f4');view=len(views)
 views.append(dict(buffer=0,byteOffset=len(data),byteLength=array.nbytes,target=34963 if kind=='SCALAR' else 34962));data.extend(array.tobytes())
 index=len(accessors);accessors.append(dict(bufferView=view,componentType=5125 if kind=='SCALAR' else 5126,count=len(array),type=kind,**(dict(min=array.min(axis=0).tolist(),max=array.max(axis=0).tolist()) if kind=='VEC3' else {})))
 return index

def mesh(name,p,n,uv,material):
 rows,cols=p.shape[:2];g=np.arange(rows*cols).reshape(rows,cols);q=g[:-1,:-1].ravel()
 idx=np.stack([q,q+cols,q+1,q+1,q+cols,q+cols+1],-1).reshape(-1,3)
 points=p.reshape(-1,3);normals=n.reshape(-1,3)
 tri=points[idx];cross=np.cross(tri[:,1]-tri[:,0],tri[:,2]-tri[:,0]);flip=np.sum(cross*tri.mean(axis=1),axis=1)<0
 idx[flip]=idx[flip][:,[0,2,1]]
 # Keep tiny polar faces above Assimp's degeneracy tolerance during import.
 # The viewer scales these authoring units back to one lunar radius.
 attrs=dict(POSITION=append_array(points*1000,'VEC3'),NORMAL=append_array(normals,'VEC3'),TEXCOORD_0=append_array(uv.reshape(-1,2),'VEC2'))
 ia=append_array(idx.ravel(),'SCALAR');nodes.append(dict(name=name,mesh=len(meshes)));meshes.append(dict(name=name,primitives=[dict(attributes=attrs,indices=ia,material=material)]))

# The equirectangular band never reaches the singularities at either pole.
lon,lat=np.meshgrid(np.linspace(-180,180,1025),np.linspace(45,-45,513))
p=position(lat,lon);up=p/np.linalg.norm(p,axis=-1)[...,None]
# Fine DEM slopes belong in the normal texture. Baking those same slopes into a
# coarse latitude grid stretches interpolated normals along the meridians.
n=up
mesh('LunarBand',p,n,np.stack([(lon+180)/360,(90-lat)/180],-1),0)

for pole,name in [(1,'NorthCap'),(-1,'SouthCap')]:
 rho,theta=np.meshgrid(np.linspace(0,2*R*np.tan(np.radians(22.5)),257),np.linspace(-np.pi,np.pi,1025),indexing='ij')
 x=rho*np.sin(theta);y=-pole*rho*np.cos(theta);lat,lon=from_polar(x,y,pole);p=position(lat,lon)
 # All copies of the center share one height and one UV, irrespective of longitude.
 mean_height=float(heights[0 if pole==1 else -1].mean())*.5-10000
 p[0,:,:]=[0,pole*(1+mean_height/R),0]
 # Derivatives in the cap's planar coordinates avoid the 1/cos(latitude) singularity.
 n=p/np.linalg.norm(p,axis=-1)[...,None]
 mesh(name,p,n,np.stack([(x+EXTENT)/(2*EXTENT),(EXTENT-y)/(2*EXTENT)],-1),1 if pole==1 else 2)

images=[]
for filename in ['moon-albedo.jpg','moon-band-normals.png','moon-north-albedo.jpg','moon-south-albedo.jpg','moon-north-normals.png','moon-south-normals.png']:
 blob=(OUT/filename).read_bytes();views.append(dict(buffer=0,byteOffset=len(data),byteLength=len(blob)));data.extend(blob);data.extend(b'\0'*((-len(data))%4));images.append(dict(bufferView=len(views)-1,mimeType='image/png' if filename.endswith('.png') else 'image/jpeg'))
materials=[]
for i in range(3):
 mat=dict(name=['LunarBand','NorthCap','SouthCap'][i],pbrMetallicRoughness=dict(baseColorTexture=dict(index=[0,2,3][i]),metallicFactor=0,roughnessFactor=1))
 mat['normalTexture']=dict(index=[1,4,5][i],scale=1)
 materials.append(mat)
doc=dict(asset=dict(version='2.0',generator='NASA LOLA globe with stereographic polar caps',extras=dict(unitsPerLunarRadius=1000)),scene=0,scenes=[dict(nodes=list(range(len(nodes))))],nodes=nodes,meshes=meshes,materials=materials,buffers=[dict(byteLength=len(data))],bufferViews=views,accessors=accessors,images=images,textures=[dict(source=i,sampler=0 if i<2 else 1) for i in range(6)],samplers=[dict(wrapS=10497,wrapT=33071,magFilter=9729,minFilter=9987),dict(wrapS=33071,wrapT=33071,magFilter=9729,minFilter=9987)])
j=json.dumps(doc,separators=(',',':')).encode();j+=b' '*((-len(j))%4)
(OUT/'moon-topography.glb').write_bytes(struct.pack('<5I',0x46546c67,2,28+len(j)+len(data),len(j),0x4e4f534a)+j+struct.pack('<2I',len(data),0x004e4942)+data)
print('Prepared band and two polar caps; height sources and geographic coordinates preserved.',flush=True)
manifest_path=OUT/'detail-provenance.json'
manifest=json.loads(manifest_path.read_text())
manifest.update(globeProjection='cylindrical band from -45 to 45 degrees; stereographic north/south caps',polarTextureHalfExtentMetres=EXTENT,polarAlbedoSize=4096,polarNormalSize=4096,capRadialIntervals=256,unitsPerLunarRadius=1000)
manifest_path.write_text(json.dumps(manifest,indent=2))
