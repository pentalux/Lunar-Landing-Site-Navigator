import pathlib,sys,json,datetime
sys.path.insert(0,str((pathlib.Path(__file__).resolve().parents[1]/'tools/python-libs').resolve()))
import requests,spiceypy as sp,numpy as np
root=(pathlib.Path(__file__).resolve().parents[1]/'tools/data')
for f in ['de421.bsp','moon_pa_de421_1900-2050.bpc','moon_080317.tf','naif0012.tls']:sp.furnsh(str(root/f))
# Independent direct SPICE calculation at an inter-sample UTC time.
lat,lon=.67,23.47;a,b=np.radians([lat,lon]);up=np.array([np.cos(a)*np.cos(b),np.cos(a)*np.sin(b),np.sin(a)]);east=np.array([-np.sin(b),np.cos(b),0]);north=np.cross(up,east)
output={}
for body in ['SUN','EARTH']:
 p,_=sp.spkpos(body,sp.str2et('2026-11-15T06:30:00'),'MOON_ME','NONE','MOON');p-=up*(1737.4-1.9195157+.002);e,n,u=p@east,p@north,p@up;output[body]=dict(az=float(np.degrees(np.arctan2(e,n))%360),el=float(np.degrees(np.arctan2(u,np.hypot(e,n)))))
(pathlib.Path(__file__).resolve().parents[1]/'tests/spice-reference.json').write_text(json.dumps(output,indent=2));print(output)
q=dict(format='json',COMMAND="'10'",EPHEM_TYPE="'OBSERVER'",CENTER="'coord@301'",COORD_TYPE="'GEODETIC'",SITE_COORD="'23.47,0.67,-1.9175157'",START_TIME="'2026-11-15 06:30'",STOP_TIME="'2026-11-15 07:30'",STEP_SIZE="'1 h'",QUANTITIES="'4'",CSV_FORMAT="'YES'",APPARENT="'AIRLESS'")
r=requests.get('https://ssd.jpl.nasa.gov/api/horizons.api',params=q,timeout=30).json();(pathlib.Path(__file__).resolve().parents[1]/'docs/horizons-validation.txt').write_text(r.get('result',str(r)));print(r.get('result',str(r)).split('$$SOE')[-1].split('$$EOE')[0][:800])
