"""Independent pixel-center and GDAL projection references for the runtime sampler."""
import pathlib,sys,json
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python-libs'))
import rasterio,numpy as np
from rasterio.warp import transform
from rasterio.windows import Window
points=[]
with rasterio.open(ROOT/'tools/data/ldem_64_uint.tif') as dem:
 for row,col in [(5760,11520),(3100,6500),(8000,22000),(1,0),(11518,23039)]:
  h=float(dem.read(1,window=Window(col,row,1,1))[0,0])*.5-10000
  points.append(dict(dataset='global',row=row,col=col,lat=90-(row+.5)/dem.height*180,lon=(col+.5)/dem.width*360-180,height=h))
with rasterio.open(ROOT/'tools/data/polar.tif') as dem:
 for row,col in [(3800,3800),(3550,4200),(4500,2200),(1000,6000)]:
  x,y=dem.xy(row,col)
  lon,lat=transform(dem.crs,'+proj=longlat +R=1737400 +no_defs',[x],[y])
  h=float(dem.read(1,window=Window(col,row,1,1))[0,0])
  points.append(dict(dataset='south',row=row,col=col,lat=lat[0],lon=lon[0],height=h))
(ROOT/'tests/terrain-reference.json').write_text(json.dumps(points,indent=2))
print('Prepared independent references from original NASA rasters:',len(points))
