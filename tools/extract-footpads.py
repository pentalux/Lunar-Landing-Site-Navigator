import pathlib,json
p=(pathlib.Path(__file__).resolve().parents[1]/'docs/lander-geometry.json');g=json.loads(p.read_text());feet=[]
import sys
sys.path.insert(0,str((pathlib.Path(__file__).resolve().parents[1]/'tools/python-libs').resolve()))
import numpy as np
points=np.array(g['bottom']);xz=points[:,[0,2]]
remaining=set(range(len(points)));clusters=[]
while remaining:
 seed=remaining.pop();component=[seed];queue=[seed]
 while queue:
  i=queue.pop();near=[j for j in remaining if np.linalg.norm(xz[i]-xz[j])<.25]
  for j in near:remaining.remove(j);component.append(j);queue.append(j)
 clusters.append(component)
print("Footpad components:",[(len(c),points[c].mean(0).tolist()) for c in clusters])
for component in clusters:
 pts=points[component];feet.append(((pts.min(0)+pts.max(0))/2).tolist())
meta=dict(min=g['min'],max=g['max'],feet=feet,height=g['max'][1]-g['min'][1])
(pathlib.Path(__file__).resolve().parents[1]/'HackathonContent/assets/science/LanderGeometry.js').write_text('.pragma library\nvar geometry='+json.dumps(meta)+';\n');print(json.dumps(meta,indent=2))



