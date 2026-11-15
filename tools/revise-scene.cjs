process.chdir(require('node:path').resolve(__dirname, '..'));
const fs=require('fs');const p='HackathonContent/SceneView.qml';let s=fs.readFileSync(p,'utf8');s=s.replace('property real compression: 1','property real compression: 1\n property real verticalSpeed: 0\n property real descentTime: 0\n property bool descending: false');s=s.replace('function land(){landing.stop();returning.stop();','function land(){descending=false;touchdown.stop();landing.stop();returning.stop();surfaceCamera.z=12;blend=0;');s=s.replace('function orbit(){landing.stop();','function orbit(){descending=false;touchdown.stop();landing.stop();');let start=s.indexOf('  ScriptAction { script: root.phase="POWERED DESCENT" }'),end=s.indexOf(' SequentialAnimation { id: returning');s=s.slice(0,start)+`  ScriptAction { script: {root.phase="POWERED DESCENT";root.verticalSpeed=-2;root.descentTime=0;root.descending=true;} }
 }
 Timer { interval: 16; repeat: true; running: root.descending
  onTriggered: {
   var dt=.064,h=root.altitude*100,target=-Math.max(.7,Math.min(15,Math.sqrt(2*1.2*Math.max(0,h))));
   var thrust=Mission.clamp(1.62+1.8*(target-root.verticalSpeed),0,4.8);
   root.verticalSpeed+=(-1.62+thrust)*dt;
   root.altitude=Math.max(0,root.altitude+root.verticalSpeed*dt/100);
   root.descentTime+=dt;
   root.wobble=Math.sin(root.descentTime*2.7)*Math.min(2,h/30);
   if(root.altitude<=0){root.descending=false;root.phase="TOUCHDOWN / DAMPING";touchdown.start();}
  }
 }
 SequentialAnimation { id: touchdown
  ParallelAnimation {
   SequentialAnimation { NumberAnimation { target: root; property: "altitude"; to: .02; duration: 180 } NumberAnimation { target: root; property: "altitude"; to: 0; duration: 600; easing.type: Easing.OutBounce } }
   SequentialAnimation { NumberAnimation { target: root; property: "compression"; to: .94; duration: 120 } NumberAnimation { target: root; property: "compression"; to: 1; duration: 1000; easing.type: Easing.OutElastic } }
   NumberAnimation { target: root; property: "wobble"; from: 2; to: 0; duration: 1500; easing.type: Easing.OutElastic }
  }
  ScriptAction { script: root.phase="LANDED / STABLE" }
 }
`+s.slice(end);s=s.replace(/z: 520; clipNear: .01; clipFar: 10000; fieldOfView: 52; position: Qt.vector3d\(0,0,520\*\(1-root.flight\)\+3\*root.flight\)/,'clipNear: .01; clipFar: 10000; fieldOfView: 52; z: 520*(1-root.flight)+3*root.flight');s=s.replace('Qt.vector3d(12,12,12)','Qt.vector3d(40,40,40)');s=s.replace('!landing.running&&!returning.running','!landing.running&&!returning.running&&!root.descending');fs.writeFileSync(p,s);
