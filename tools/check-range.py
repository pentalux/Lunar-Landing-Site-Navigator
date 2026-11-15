import sys,pathlib
sys.path.insert(0,str((pathlib.Path(__file__).resolve().parents[1]/'tools/python-libs').resolve()))
import requests,time
u='https://pgda.gsfc.nasa.gov/data/LOLA_20mpp/LDEM_80S_80MPP_ADJ.TIF'
t=time.time();r=requests.get(u,headers={'Range':'bytes=0-65535'},timeout=30);print(r.status_code,len(r.content),time.time()-t,r.headers.get('content-range'))
