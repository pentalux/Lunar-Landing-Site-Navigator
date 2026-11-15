"""Cache the Moon's rotation in a nonrotating, Moon-centered viewer frame."""
import pathlib,sys,json,datetime
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python-libs'))
import numpy as np, spiceypy as sp
for name in ['moon_pa_de421_1900-2050.bpc','moon_080317.tf','naif0012.tls']:
 sp.furnsh(str(ROOT/'tools/data'/name))
start=datetime.datetime(2026,1,1,tzinfo=datetime.timezone.utc)
stop=datetime.datetime(2028,1,1,tzinfo=datetime.timezone.utc)
reference=sp.pxform('MOON_ME','J2000',sp.str2et('2026-11-15T00:00:00'))
# Qt: [ME X, ME Z, -ME Y]. The reference is constant, not evaluated at view time.
C=np.array([[1.,0,0],[0,0,1],[0,-1,0]])
rows=[]
for i in range(int((stop-start).total_seconds()/3600)+1):
 utc=start+datetime.timedelta(hours=i)
 matrix=C@reference.T@sp.pxform('MOON_ME','J2000',sp.str2et(utc.strftime('%Y-%m-%dT%H:%M:%S')))@C.T
 q=sp.m2q(matrix)
 if rows and np.dot(q,rows[-1])<0:q=-q
 rows.append(np.round(q,12).tolist())
out=ROOT/'HackathonContent/assets/science/LunarOrientation.js'
out.write_text('.pragma library\nvar start='+str(int(start.timestamp()*1000))+';\nvar step=3600000;\nvar reference="MOON_ME aligned at 2026-11-15T00:00:00 UTC; nonrotating J2000 axes";\nvar rows=JSON.parse('+json.dumps(json.dumps(rows,separators=(',',':')))+');\n')
print('Prepared',len(rows),'SPICE lunar orientation quaternions.')
