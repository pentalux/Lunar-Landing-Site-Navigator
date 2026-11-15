import pathlib,sys,struct,json
sys.path.insert(0,str((pathlib.Path(__file__).resolve().parents[1]/'tools/python-libs').resolve()))
import numpy as np
b=(pathlib.Path(__file__).resolve().parents[1]/'HackathonContent/assets/lander.glb').read_bytes();jl=struct.unpack_from('<I',b,12)[0];g=json.loads(b[20:20+jl]);blob=b[28+jl:]
def mat(n):
 if 'matrix' in n:return np.array(n['matrix']).reshape(4,4).T
 x,y,z,w=n.get('rotation',[0,0,0,1]);m=np.eye(4);m[:3,:3]=np.array([[1-2*y*y-2*z*z,2*x*y-2*z*w,2*x*z+2*y*w],[2*x*y+2*z*w,1-2*x*x-2*z*z,2*y*z-2*x*w],[2*x*z-2*y*w,2*y*z+2*x*w,1-2*x*x-2*y*y]])@np.diag(n.get('scale',[1,1,1]));m[:3,3]=n.get('translation',[0,0,0]);return m
allp=[];parts=[]
def walk(i,parent):
 n=g['nodes'][i];m=parent@mat(n)
 if 'mesh' in n:
  pp=[]
  for p in g['meshes'][n['mesh']]['primitives']:
   a=g['accessors'][p['attributes']['POSITION']];v=g['bufferViews'][a['bufferView']];offset=v.get('byteOffset',0)+a.get('byteOffset',0);p=np.ndarray((a['count'],3),dtype='<f4',buffer=blob,offset=offset,strides=(v.get('byteStride',12),4));p=p@m[:3,:3].T+m[:3,3];pp.append(p)
  p=np.concatenate(pp);allp.append(p);parts.append((n.get('name',''),p.min(0).tolist(),p.max(0).tolist()))
 for c in n.get('children',[]):walk(c,m)
for i in g['scenes'][g.get('scene',0)]['nodes']:walk(i,np.eye(4))
p=np.concatenate(allp);print('BOUNDS',p.min(0),p.max(0));print('LOW PARTS');print(json.dumps(sorted(parts,key=lambda x:x[1][1])[:14],indent=2));bottom=p[p[:,1]<p[:,1].min()+.025];print('BOTTOM',bottom.min(0),bottom.max(0),len(bottom))
(pathlib.Path(__file__).resolve().parents[1]/'docs/lander-geometry.json').write_text(json.dumps(dict(min=p.min(0).tolist(),max=p.max(0).tolist(),bottom=bottom.tolist(),parts=parts),indent=2))
