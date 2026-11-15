// Deterministic, synthetic terrain. No lunar measurement data is used.
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const out = path.resolve(__dirname, '../HackathonContent/assets');
fs.mkdirSync(out, { recursive: true });
function height(x,z) {
  const flatten = 1-Math.exp(-(x*x+z*z)/600);
  let h=2.5*Math.sin(x*.038)*Math.cos(z*.031)+1.8*Math.sin(x*.083+z*.051)+.45*Math.sin(x*.34-z*.21);
  for (const [cx,cz,r,d] of [[-78,-55,49,20],[85,-90,34,13],[95,48,24,9],[-110,98,18,6],[-25,123,10,4],[40,-22,7,2]]) {
    const t=Math.hypot(x-cx,z-cz)/r;
    h+=-d*Math.exp(-t*t*2.1)+d*.30*Math.exp(-Math.pow((t-1.02)/.15,2));
  }
  return h*flatten;
}
function glb(name, slope) {
  const n=160, size=380, positions=[], normals=[], colors=[], indices=[];
  for(let j=0;j<=n;j++) for(let i=0;i<=n;i++) {
    const x=(i/n-.5)*size,z=(j/n-.5)*size,y=height(x,z);
    const dx=(height(x+.3,z)-height(x-.3,z))/.6,dz=(height(x,z+.3)-height(x,z-.3))/.6;
    const norm=Math.hypot(dx,1,dz), shade=.43+.05*Math.sin(x*2.7+z*1.8)+.035*Math.cos(z*3.3);
    positions.push(x,y,z); normals.push(-dx/norm,1/norm,-dz/norm);
    if(slope) { const t=Math.min(1,Math.atan(Math.hypot(dx,dz))*180/Math.PI/25); colors.push(.16+.68*t,.57-.29*t,.53-.39*t,1); }
    else colors.push(shade*1.06,shade*1.04,shade,1);
  }
  for(let j=0;j<n;j++) for(let i=0;i<n;i++) {const a=j*(n+1)+i,b=a+n+1;indices.push(a,b,a+1,a+1,b,b+1);}
  const arrays=[new Float32Array(positions),new Float32Array(normals),new Float32Array(colors),new Uint32Array(indices)];
  let offset=0;const views=arrays.map((a,i)=>{const v={buffer:0,byteOffset:offset,byteLength:a.byteLength,target:i===3?34963:34962};offset+=a.byteLength;return v;});
  const bin=Buffer.concat(arrays.map(a=>Buffer.from(a.buffer)));
  const doc={asset:{version:'2.0',generator:'Lunar Navigator synthetic terrain generator'},scene:0,scenes:[{nodes:[0]}],nodes:[{mesh:0,name:'Synthetic terrain • 380 m patch'}],meshes:[{primitives:[{attributes:{POSITION:0,NORMAL:1,COLOR_0:2},indices:3,material:0}]}],materials:[{doubleSided:true,pbrMetallicRoughness:{baseColorFactor:[1,1,1,1],metallicFactor:0,roughnessFactor:.96}}],buffers:[{byteLength:bin.length}],bufferViews:views,accessors:[{bufferView:0,componentType:5126,count:positions.length/3,type:'VEC3',min:[-190,-40,-190],max:[190,20,190]},{bufferView:1,componentType:5126,count:normals.length/3,type:'VEC3'},{bufferView:2,componentType:5126,count:colors.length/4,type:'VEC4'},{bufferView:3,componentType:5125,count:indices.length,type:'SCALAR'}]};
  let json=Buffer.from(JSON.stringify(doc)); json=Buffer.concat([json,Buffer.alloc((4-json.length%4)%4,32)]);
  const header=Buffer.alloc(20);header.writeUInt32LE(0x46546c67,0);header.writeUInt32LE(2,4);header.writeUInt32LE(28+json.length+bin.length,8);header.writeUInt32LE(json.length,12);header.writeUInt32LE(0x4e4f534a,16);
  const bh=Buffer.alloc(8);bh.writeUInt32LE(bin.length,0);bh.writeUInt32LE(0x004e4942,4);
  fs.writeFileSync(path.join(out,name),Buffer.concat([header,json,bh,bin]));
}
function crc(buf) {let c=0xffffffff;for(const b of buf){c^=b;for(let k=0;k<8;k++)c=(c>>>1)^((c&1)?0xedb88320:0);}return (c^0xffffffff)>>>0;}
function png(name,w,h,pixel) {
  const raw=Buffer.alloc(h*(w*3+1));for(let y=0;y<h;y++)for(let x=0;x<w;x++){const rgb=pixel(x/w,y/h);for(let k=0;k<3;k++)raw[y*(w*3+1)+1+x*3+k]=Math.max(0,Math.min(255,Math.round(rgb[k])));}
  function chunk(type,data){const t=Buffer.from(type),b=Buffer.alloc(12+data.length);b.writeUInt32BE(data.length,0);t.copy(b,4);data.copy(b,8);b.writeUInt32BE(crc(Buffer.concat([t,data])),8+data.length);return b;}
  const ih=Buffer.alloc(13);ih.writeUInt32BE(w,0);ih.writeUInt32BE(h,4);ih[8]=8;ih[9]=2;
  fs.writeFileSync(path.join(out,name),Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',ih),chunk('IDAT',zlib.deflateSync(raw)),chunk('IEND',Buffer.alloc(0))]));
}
const craters=Array.from({length:130},(_,i)=>({u:((Math.sin(i*72.171)*18976)%1+1)%1,v:((Math.sin(i*16.12)*17263)%1+1)%1,r:.004+(((Math.sin(i*9.71)*7731)%1+1)%1)*.031}));
png('moon.png',1024,512,(u,v)=>{let c=133+16*Math.sin(u*41)*Math.sin(v*23)+9*Math.cos(u*113+v*57)+4*Math.sin(u*1453+v*1023);for(const q of craters){const du=Math.min(Math.abs(u-q.u),1-Math.abs(u-q.u));const d=Math.hypot(du*Math.sin(v*Math.PI),v-q.v)/q.r;if(d<1.4)c+=-31*Math.exp(-d*d*3)+30*Math.exp(-Math.pow((d-1)/.13,2));}return[c,c*.99,c*.96];});
// Stylised globe texture, explicitly illustrative (not a geographical basemap).
png('earth.png',1024,512,(u,v)=>{const lat=(.5-v)*Math.PI,lon=u*Math.PI*2;const land=Math.sin(lon*3+Math.sin(lat*4)*2)+.55*Math.sin(lon*7-lat*5)+.3*Math.cos(lon*13+lat*8);const cloud=Math.pow(Math.max(0,Math.sin(lon*19+lat*13+Math.sin(lon*4)*3)*Math.cos(lat*17-lon*5)),12)*.55;let c=Math.abs(lat)>1.26?[178,194,196]:land>.65?[62+30*Math.cos(lat*3),88+28*Math.cos(lat*3),69]:[23,58,91];return c.map(a=>a*(1-cloud)+220*cloud);});
glb('terrain.glb',false);glb('terrain-slope.glb',true);
console.log('Generated synthetic terrain and illustrative planet textures.');
