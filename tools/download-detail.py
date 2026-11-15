"""Download the documented NASA global DEM and albedo, without changing sources."""
import pathlib,sys,concurrent.futures
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python-libs'))
import requests
CACHE=ROOT/'tools/data'
base='https://svs.gsfc.nasa.gov/vis/a000000/a004700/a004720/'
def download(name):
 target=CACHE/name
 if target.exists():return str(target)
 temporary=target.with_suffix('.part')
 with requests.get(base+name,stream=True,timeout=(30,120)) as response:
  response.raise_for_status()
  with temporary.open('wb') as output:
   for chunk in response.iter_content(1024*1024):output.write(chunk)
 temporary.replace(target)
 print('Downloaded',name,target.stat().st_size,flush=True)
 return str(target)
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 list(pool.map(download,['ldem_64_uint.tif','lroc_color_poles_16k.tif']))
