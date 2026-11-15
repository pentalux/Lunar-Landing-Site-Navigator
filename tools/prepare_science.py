"""Reproducible NASA data preparation; runs at authoring time, never invents terrain."""
import sys, pathlib, json, math, struct, concurrent.futures, datetime
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python-libs'))
import requests, numpy as np, rasterio, spiceypy as sp
from rasterio.enums import Resampling
CACHE=ROOT/'tools/data'; CACHE.mkdir(exist_ok=True)
OUT=ROOT/'HackathonContent/assets/science'; OUT.mkdir(parents=True,exist_ok=True)
base='https://naif.jpl.nasa.gov/pub/naif/generic_kernels/'
urls={
'de421.bsp':base+'spk/planets/a_old_versions/de421.bsp',
'moon_pa_de421_1900-2050.bpc':base+'pck/moon_pa_de421_1900-2050.bpc',
'moon_080317.tf':base+'fk/satellites/moon_080317.tf',
'naif0012.tls':base+'lsk/naif0012.tls',
'global.tif':'https://svs.gsfc.nasa.gov/vis/a000000/a004700/a004720/ldem_16.tif',
'polar.tif':'https://pgda.gsfc.nasa.gov/data/LOLA_20mpp/LDEM_80S_80MPP_ADJ.TIF'}
def download(item):
 name,url=item; p=CACHE/name
 if not p.exists():
  print('Downloading',name,flush=True)
  r=requests.get(url,timeout=240);r.raise_for_status();p.write_bytes(r.content)
 return name
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as ex:list(ex.map(download,urls.items()))
for name in list(urls)[:4]:sp.furnsh(str(CACHE/name))
start=datetime.datetime(2026,1,1,tzinfo=datetime.timezone.utc)
end=datetime.datetime(2028,1,1,tzinfo=datetime.timezone.utc)
vectors=[]
for i in range(int((end-start).total_seconds()/3600)+1):
 utc=start+datetime.timedelta(hours=i);et=sp.str2et(utc.strftime('%Y-%m-%dT%H:%M:%S'))
 row=[]
 for body in ['SUN','EARTH']:
  pos,_=sp.spkpos(body,et,'MOON_ME','NONE','MOON');row.extend(np.round(pos,3).tolist())
 vectors.append(row)
print('SPICE vectors',len(vectors),flush=True)
(OUT/'Ephemeris.js').write_text('.pragma library\nvar start='+str(int(start.timestamp()*1000))+';\nvar step=3600000;\nvar rows='+json.dumps(vectors,separators=(',',':'))+';\n')
sites=[('Shackleton Rim',-89.67,129.78),('Connecting Ridge',-89.45,137.4),('de Gerlache Rim',-88.71,-68.14),('Malapert Massif',-86,2.7),('Apollo 11',.67,23.47),('Apollo 15',26.13,3.63),('Apollo 17',20.19,30.77),('IM-1 Malapert A',-80.13,1.44)]
globalds=rasterio.open(CACHE/'global.tif');globalh=globalds.read(1)
print('Global',globalds.profile,globalh.min(),globalh.max(),flush=True)
polar=rasterio.open(CACHE/'polar.tif'); print('Polar',polar.profile,flush=True)
R=1737400.
def basis(lat,lon):
 a,b=np.radians([lat,lon]);up=np.array([np.cos(a)*np.cos(b),np.cos(a)*np.sin(b),np.sin(a)]);east=np.array([-np.sin(b),np.cos(b),0]);north=np.cross(up,east);return up,east,north
def elevations(points,usepolar):
 radii=np.linalg.norm(points,axis=-1);lat=np.degrees(np.arcsin(points[...,2]/radii));lon=np.degrees(np.arctan2(points[...,1],points[...,0]))
 if usepolar:
  a=np.radians(lat);b=np.radians(lon);rho=2*R*np.tan(np.pi/4+a/2);x=rho*np.sin(b);y=rho*np.cos(b)
  rr,cc=rasterio.transform.rowcol(polar.transform,x.ravel(),y.ravel());rr=np.array(rr);cc=np.array(cc)
  r0,r1=max(0,int(rr.min())),min(polar.height,int(rr.max())+1);c0,c1=max(0,int(cc.min())),min(polar.width,int(cc.max())+1)
  data=polar.read(1,window=rasterio.windows.Window(c0,r0,c1-c0,r1-r0));vals=data[np.clip(rr-r0,0,data.shape[0]-1),np.clip(cc-c0,0,data.shape[1]-1)].reshape(lat.shape)
  if np.any(vals < -20000):raise ValueError('DEM no-data encountered')
  return vals
 # Global float TIFF: elevations in km, centered on longitude zero.
 x=(lon+180)/360*globalds.width-.5;y=(90-lat)/180*globalds.height-.5
 xi=np.floor(x).astype(int);yi=np.floor(y).astype(int);fx=x-xi;fy=y-yi
 return 1000*((1-fy)*((1-fx)*globalh[np.clip(yi,0,globalds.height-1),xi%globalds.width]+fx*globalh[np.clip(yi,0,globalds.height-1),(xi+1)%globalds.width])+fy*((1-fx)*globalh[np.clip(yi+1,0,globalds.height-1),xi%globalds.width]+fx*globalh[np.clip(yi+1,0,globalds.height-1),(xi+1)%globalds.width]))
def writeglb(filename,pos,norm,col,idx):
 arrays=[np.asarray(pos,dtype='<f4'),np.asarray(norm,dtype='<f4'),np.asarray(col,dtype='<f4'),np.asarray(idx,dtype='<u4')];data=b'';views=[]
 for i,a in enumerate(arrays):views.append(dict(buffer=0,byteOffset=len(data),byteLength=a.nbytes,target=34963 if i==3 else 34962));data+=a.tobytes()
 doc=dict(asset=dict(version='2.0',generator='NASA LOLA terrain pipeline'),scene=0,scenes=[dict(nodes=[0])],nodes=[dict(mesh=0)],meshes=[dict(primitives=[dict(attributes=dict(POSITION=0,NORMAL=1,COLOR_0=2),indices=3,material=0)])],materials=[dict(doubleSided=True,pbrMetallicRoughness=dict(metallicFactor=0,roughnessFactor=1))],buffers=[dict(byteLength=len(data))],bufferViews=views,accessors=[dict(bufferView=i,componentType=5125 if i==3 else 5126,count=len(a),type=['VEC3','VEC3','VEC4','SCALAR'][i],**(dict(min=a.min(axis=0).tolist(),max=a.max(axis=0).tolist()) if i==0 else {})) for i,a in enumerate(arrays)])
 j=json.dumps(doc).encode();j+=b' '*((-len(j))%4);(OUT/filename).write_bytes(struct.pack('<5I',0x46546c67,2,28+len(j)+len(data),len(j),0x4e4f534a)+j+struct.pack('<2I',len(data),0x004e4942)+data)
metadata=[]
for si,(name,lat,lon) in enumerate(sites):
 up,east,north=basis(lat,lon);usepolar=lat<-80.2;h0=float(elevations(up[None,:]*R,usepolar)[0]);n=160;extent=60000.;axis=np.linspace(-extent/2,extent/2,n+1);x,z=np.meshgrid(axis,axis);pts=up*R+x[...,None]*east-z[...,None]*north;ht=elevations(pts,usepolar);r=np.linalg.norm(pts,axis=-1);positions=(pts/r[...,None]*(R+ht)[...,None]-up*(R+h0));px=positions@east;py=positions@up;pz=-(positions@north)
 # Metres to scene units; 1 scene unit = 100 m, equal vertical/horizontal scale.
 pos=np.stack([px,py,pz],-1)/100;dz,dx=np.gradient(py,extent/n);norm=np.stack([-dx,np.ones_like(dx),-dz],-1);norm/=np.linalg.norm(norm,axis=-1)[...,None];slope=np.degrees(np.arctan(np.hypot(dx,dz)));t=np.clip((slope-8)/12,0,1);grey=np.full_like(t,.43);col=np.stack([grey,grey,grey,np.ones_like(t)],-1);scol=np.stack([.16+.64*t,.55-.34*t,.26-.13*t,np.ones_like(t)],-1);idx=[]
 for j in range(n):
  for i in range(n):a=j*(n+1)+i;b=a+n+1;idx.extend([a,b,a+1,a+1,b,b+1])
 for suffix,c in [('',col),('-slope',scol)]:writeglb(str(si)+suffix+'.glb',pos.reshape(-1,3),norm.reshape(-1,3),c.reshape(-1,4),idx)
 az=np.radians(np.arange(360));distance=np.geomspace(80 if usepolar else 2000,100000,420);points=up*R+distance[None,:,None]*(np.sin(az)[:,None,None]*east+np.cos(az)[:,None,None]*north);heights=elevations(points,usepolar);points=points/np.linalg.norm(points,axis=-1)[...,None]*(R+heights)[...,None];rel=points-up*(R+h0);vertical=rel@up;horizontal=np.hypot(rel@east,rel@north)
 horizons=[]
 for mast in [0,2,5,10]:horizons.append(np.round(np.degrees(np.arctan2(vertical-mast,horizontal)).max(axis=1),4).tolist())
 metadata.append(dict(name=name,lat=lat,lon=lon,elevation=round(h0,2),resolution=80 if usepolar else 1895,meshStep=375,extent=60000,minElevation=round(float(ht.min())),maxElevation=round(float(ht.max())),horizons=horizons,slope=round(float(slope[n//2,n//2]),2)))
 print(name,h0,'relief',ht.min(),ht.max(),flush=True)
# Global 4 pixels/degree height grid supports arbitrary custom sites without network.
small=globalds.read(1,out_shape=(720,1440),resampling=Resampling.average)
(OUT/'TerrainData.js').write_text('.pragma library\nvar sites='+json.dumps(metadata,separators=(',',':'))+';\nvar width=1440;var height=720;var globalHeights='+json.dumps(np.round(small*1000).astype(int).ravel().tolist(),separators=(',',':'))+';\n')
(OUT/'provenance.json').write_text(json.dumps(dict(sources=urls,frame='MOON_ME / DE421',utcStart='2026-01-01',utcEnd='2028-01-01',ephemerisStepSeconds=3600,correction='NONE',terrain=metadata),indent=2))
# Qt 6.8 cannot reliably evaluate million-element JavaScript array literals.
# Keep global data in lazy row chunks and parse ephemeris JSON at startup.
eph=OUT/'Ephemeris.js'
eph.write_text('.pragma library\nvar start='+str(int(start.timestamp()*1000))+';\nvar step=3600000;\nvar rows=JSON.parse('+json.dumps(json.dumps(vectors,separators=(',',':')))+');\n')
encoded=[json.dumps(row.tolist(),separators=(',',':')) for row in np.round(small*1000).astype(int)]
(OUT/'TerrainData.js').write_text('.pragma library\nvar sites=JSON.parse('+json.dumps(json.dumps(metadata,separators=(',',':')))+');\nvar width=1440;var height=720;var encodedRows='+json.dumps(encoded,separators=(',',':'))+';\nvar cache={};\nfunction at(index){var row=Math.floor(index/width);if(!cache[row])cache[row]=JSON.parse(encodedRows[row]);return cache[row][index%width];}\n')
import subprocess
subprocess.run(['node',str(ROOT/'tools/decorate-terrain.cjs')],cwd=ROOT.parent,check=True)
subprocess.run([sys.executable,str(ROOT/'tools/refine-regolith.py')],cwd=ROOT.parent,check=True)
subprocess.run(['node',str(ROOT/'tools/extract-landing-meshes.cjs')],cwd=ROOT.parent,check=True)
subprocess.run([sys.executable,str(ROOT/'tools/inspect-lander.py')],cwd=ROOT.parent,check=True)
subprocess.run([sys.executable,str(ROOT/'tools/extract-footpads.py')],cwd=ROOT.parent,check=True)
subprocess.run(['node',str(ROOT/'tools/prepare-pin.cjs')],cwd=ROOT.parent,check=True)
subprocess.run([sys.executable,str(ROOT/'tools/prepare-orientation.py')],cwd=ROOT.parent,check=True)
subprocess.run([sys.executable,str(ROOT/'tools/download-detail.py')],cwd=ROOT.parent,check=True)
subprocess.run([sys.executable,str(ROOT/'tools/prepare-detail.py')],cwd=ROOT.parent,check=True)
