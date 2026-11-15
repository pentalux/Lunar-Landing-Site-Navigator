const fs=require('node:fs'),vm=require('node:vm'),path=require('node:path');
const root=path.join(__dirname,'../HackathonContent');
function load(file,imports={}){const c={...imports};vm.createContext(c);vm.runInContext(fs.readFileSync(path.join(root,file),'utf8').replace(/^\.(pragma|import).*$/gm,''),c,{filename:file});return c;}
class Request{open(method,url){this.url=url;}send(){const b=fs.readFileSync(this.url);this.status=200;this.response=b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength);}}
const Qt={resolvedUrl:p=>path.join(root,p),vector3d:(x,y,z)=>({x,y,z}),vector2d:(x,y)=>({x,y}),vector4d:(x,y,z,w)=>({x,y,z,w}),quaternion:(w,x,y,z)=>({w,scalar:w,x,y,z})};
const terrain=load('Terrain.js',{XMLHttpRequest:Request,Qt}),math=load('SceneMath.js',{Qt});
module.exports={root,load,terrain,math,Qt};
