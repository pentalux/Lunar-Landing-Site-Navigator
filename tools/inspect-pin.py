import pathlib,struct,json,sys
sys.path.insert(0,str((pathlib.Path(__file__).resolve().parents[1]/'tools/python-libs').resolve()))
import numpy as np
p=pathlib.Path('C:/Users/pentalux/Downloads/pin.glb');b=p.read_bytes();size=struct.unpack_from('<I',b,12)[0];g=json.loads(b[20:20+size]);print(json.dumps({k:g.get(k) for k in ['asset','scenes','nodes','meshes','materials']},indent=2)[:11000]);print('Accessors:',json.dumps(g.get('accessors'),indent=2)[:4000])
