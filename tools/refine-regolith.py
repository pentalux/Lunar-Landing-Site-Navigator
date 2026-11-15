import sys,pathlib,struct,json,zlib
root=pathlib.Path(__file__).resolve().parents[1];sys.path.insert(0,str((root/'tools/python-libs').resolve()))
import numpy as np
rng=np.random.default_rng(234);n=256;h=rng.normal(0,1,(n,n))
for i in range(3):h=(h+np.roll(h,1,0)+np.roll(h,-1,0)+np.roll(h,1,1)+np.roll(h,-1,1))/5
h/=h.std();dy,dx=np.gradient(h);norm=np.stack([-dx*.25,np.ones_like(h),-dy*.25],-1);norm/=np.linalg.norm(norm,axis=-1)[...,None]
# Tangent-space texture normals: RGB = X,Y,Z, where Z points out of the surface.
normal=np.stack([norm[...,0],norm[...,2],norm[...,1]],-1)
def png(arr):
 arr=np.clip(arr,0,255).astype('uint8');raw=b''.join(b'\0'+row.tobytes() for row in arr)
 def chunk(t,d):return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d))
 return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',n,n,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b'')
diff=png(np.repeat((177+h*5)[...,None],3,axis=-1));normalpng=png((normal+1)*127.5)
(root/'HackathonContent/assets/regolith.png').write_bytes(diff);(root/'HackathonContent/assets/regolith-normal.png').write_bytes(normalpng)
for p in (root/'HackathonContent/assets/science').glob('*.glb'):
 b=p.read_bytes();size=struct.unpack_from('<I',b,12)[0];g=json.loads(b[20:20+size]);data=b[28+size:]
 for tex in [diff,normalpng]:
  g['bufferViews'].append(dict(buffer=0,byteOffset=len(data),byteLength=len(tex)));data+=tex;data+=b'\0'*((-len(data))%4)
 g['images']=[dict(bufferView=len(g['bufferViews'])-2,mimeType='image/png'),dict(bufferView=len(g['bufferViews'])-1,mimeType='image/png')];g['textures']=[dict(source=0,sampler=0),dict(source=1,sampler=0)];g['materials'][0]['normalTexture']=dict(index=1,scale=.35);g['buffers'][0]['byteLength']=len(data);j=json.dumps(g).encode();j+=b' '*((-len(j))%4);p.write_bytes(struct.pack('<5I',0x46546c67,2,28+len(j)+len(data),len(j),0x4e4f534a)+j+struct.pack('<2I',len(data),0x004e4942)+data)
