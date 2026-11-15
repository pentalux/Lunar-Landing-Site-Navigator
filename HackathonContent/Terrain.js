.pragma library

// Native LOLA samples, loaded by tile. All geometry and picking use east-positive longitude.
var radius=1737400;
var cache={};
var recent=[];
var tileReads=0;
function clamp(x,a,b){return Math.max(a,Math.min(b,x));}
function tile(name,row,col,size){
 var key=name+'-'+row+'-'+col;if(cache[key])return cache[key];
 var request=new XMLHttpRequest();request.open('GET',Qt.resolvedUrl('assets/science/heights/'+key+'.bin'),false);request.responseType='arraybuffer';request.send();
 if(request.status!==0&&request.status!==200)throw new Error('LOLA tile could not be read: '+key);
 var bytes=request.response;if(!bytes||bytes.byteLength!==size*size*2)throw new Error('Incomplete DEM tile: '+key);
 var values=new Uint16Array(bytes);cache[key]=values;recent.push(key);tileReads++;
 while(recent.length>96){var removed=recent.shift();delete cache[removed];}
 return values;
}
function at(name,x,y){
 var size=name==='global'?720:512,w=name==='global'?23040:7600,h=name==='global'?11520:7600;
 x=name==='global'?((x%w)+w)%w:clamp(x,0,w-1);y=clamp(y,0,h-1);
 var row=Math.floor(y/size),col=Math.floor(x/size),value=tile(name,row,col,size)[(y-row*size)*size+x-col*size];
 return value===65535?NaN:value*.5-10000;
}
function interpolate(name,x,y){
 var i=Math.floor(x),j=Math.floor(y),fx=x-i,fy=y-j,a=at(name,i,j),b=at(name,i+1,j),c=at(name,i,j+1),d=at(name,i+1,j+1);
 return (1-fy)*(a*(1-fx)+b*fx)+fy*(c*(1-fx)+d*fx);
}
function polarPixel(lat,lon){
 var a=lat*Math.PI/180,b=lon*Math.PI/180,rho=2*radius*Math.tan(Math.PI/4+a/2);
 return [(rho*Math.sin(b)+304000)/80-.5,(304000-rho*Math.cos(b))/80-.5];
}
function hasPolar(lat,lon){var p=polarPixel(lat,lon);return lat< -80&&p[0]>=1&&p[0]<7598&&p[1]>=1&&p[1]<7598;}
function resolution(lat,lon){return hasPolar(lat,lon)?80:2*Math.PI*radius/23040;}
function elevation(lat,lon){
 if(hasPolar(lat,lon)){var p=polarPixel(lat,lon),h=interpolate('south',p[0],p[1]);if(isFinite(h))return h;}
 return interpolate('global',(lon+180)/360*23040-.5,clamp((90-lat)/180*11520-.5,0,11519));
}
function uv(lat,lon){return [(lon+180)/360,(lat+90)/180];}
function polarUV(lat,lon,pole){var a=lat*Math.PI/180,b=lon*Math.PI/180,rho=2*radius*Math.tan(Math.PI/4-pole*a/2),extent=1500000;return [(rho*Math.sin(b)+extent)/(2*extent),(-pole*rho*Math.cos(b)+extent)/(2*extent)];}
