pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils
import "Mission.js" as Mission
import "SceneMath.js" as Math3
import "assets/science/LanderGeometry.js" as LanderGeometry
import "assets/science/PinGeometry.js" as PinGeometry
Item {
 id: root
 required property MissionController mission
 property bool systemView: true
 property bool slopeVisible: false
 property bool landerVisible: true
 property real pinLift: 0
 property real pinSize: 1
 property real pinSquash: 1
 property real travel: 0
 readonly property real blend: 1-Mission.clamp(Math.log(Math.max(1,viewDistance/60))/Math.log(2.5),0,1)
 readonly property real viewDistance: travel===0?1e8:Math.sqrt(Math3.dot(Math3.add(pose.eye,Math3.mul(pose.target,-1)),Math3.add(pose.eye,Math3.mul(pose.target,-1))))*17374
 property real altitude: 1.2
 property real compression: 1
 property real wobble: 0
 property real verticalSpeed: 0
 property real descentTime: 0
 property bool descending: false
 property string phase: "ORBITAL CONTEXT"
 property real yaw: 0
 property real pitch: 0
 property real zoom: 6.2
 property real localYaw: 21
 property real localPitch: 27
 property real localDistance: .22
 property var departureEye: [0,0,4.5]
 property var departureUp: [0,1,0]
 readonly property bool landerReady: lander.status===RuntimeLoader.Success
 readonly property bool moonReady: moon.status===RuntimeLoader.Success
 readonly property bool pinReady: selectionPin.status===RuntimeLoader.Success
 readonly property vector3d pinPosition: snapPinToSurface()
 readonly property real pinTipRadius: pinPosition.length()
 readonly property string assetError: selectionPin.status===RuntimeLoader.Error?selectionPin.errorString:lander.status===RuntimeLoader.Error?lander.errorString:moon.status===RuntimeLoader.Error?moon.errorString:""
 readonly property real landerScale: .01
 readonly property real runtimeMinY: lander.bounds.minimum.y
 readonly property real modelBottomOffsetY: LanderGeometry.geometry.min[1]*landerScale
 readonly property real groundY: getTerrainHeightAt(0,0)
 readonly property var supports: Math3.supportPose(LanderGeometry.geometry.feet,landerScale,getTerrainHeightAt)
 readonly property real targetY: supports.y
 readonly property real landerY: targetY+altitude
 readonly property real contactGap: Math.min.apply(Math,supports.gaps)+altitude
 readonly property var frame: Mission.basis(mission.site)
 readonly property var lunarRotation: Mission.orientation(mission.currentUtc)
 readonly property var anchor: bodyToWorld(Math3.mul([frame.u[0],frame.u[2],-frame.u[1]],1+mission.site.elevation/1737400))
 readonly property var sunDirection: worldVector('sun',1)
 readonly property var earthDirection: worldVector('earth',1)
 readonly property var orbitalEye: orbitEye()
 readonly property var orbitalUp: [0,1,0]
 readonly property var pose: cameraPose()
 function v(a){return Qt.vector3d(a[0],a[1],a[2]);}
 function prepareGlobe(node){if(node instanceof Model){node.pickable=true;node.objectName="lunarTerrainModel";}for(var i=0;i<node.children.length;i++)prepareGlobe(node.children[i]);}
 function bodyToWorld(p){return Math3.rotate(lunarRotation,p);}
 function worldToBody(p){var q=lunarRotation;return Math3.rotate({w:q.w,x:-q.x,y:-q.y,z:-q.z},p);}
 function playPinDrop(){pinDrop.stop();pinLift=.55;pinSize=.78;pinSquash=1;pinDrop.start();}
 Connections { target: root.mission; function onSiteSelected(){root.playPinDrop();} }
 SequentialAnimation {
  id: pinDrop
  ParallelAnimation {
   NumberAnimation { target: root; property: "pinLift"; to: 0; duration: 270; easing.type: Easing.InCubic }
   NumberAnimation { target: root; property: "pinSize"; to: 1; duration: 180; easing.type: Easing.OutCubic }
  }
  ParallelAnimation {
   NumberAnimation { target: root; property: "pinLift"; to: -.012; duration: 45; easing.type: Easing.OutQuad }
   NumberAnimation { target: root; property: "pinSquash"; to: .96; duration: 45; easing.type: Easing.OutQuad }
  }
  ParallelAnimation {
   NumberAnimation { target: root; property: "pinLift"; to: 0; duration: 140; easing.type: Easing.OutCubic }
   NumberAnimation { target: root; property: "pinSquash"; to: 1; duration: 140; easing.type: Easing.OutBack }
  }
 }
 function isMoonHit(hit){var node=hit.objectHit;while(node){if(node===moon)return true;node=node.parent;}return false;}
 function snapPinToSurface(){var n=Math3.unit(anchor);if(!mission.siteMarked||!moonReady)return v(n);var hit=orbitView.rayPick(v(Math3.mul(n,2)),v(Math3.mul(n,-1)));return isMoonHit(hit)?hit.scenePosition:v(n);}
 function projectOnGlobe(lat,lon){var b=Mission.basis({lat:lat,lon:lon});return orbitView.mapFrom3DScene(v(bodyToWorld([b.u[0],b.u[2],-b.u[1]])));}
 function projectMoonCenter(){return orbitView.mapFrom3DScene(moon.scenePosition);}
 function selectAt(x,y){var hit=orbitView.pick(x,y);if(!isMoonHit(hit))return false;var p=Math3.unit(worldToBody([hit.scenePosition.x,hit.scenePosition.y,hit.scenePosition.z]));return mission.setCustom(Math.asin(Mission.clamp(p[1],-1,1))*180/Math.PI,Math.atan2(-p[2],p[0])*180/Math.PI);}
 function worldVector(body,length){var p=Mission.vector(body,mission.currentUtc);return p?bodyToWorld(Math3.mul(Math3.unit([p[0],p[2],-p[1]]),length)):[1,0,0];}
 function globalDirection(local){return bodyToWorld([frame.e[0]*local[0]+frame.u[0]*local[1]-frame.n[0]*local[2],frame.e[2]*local[0]+frame.u[2]*local[1]-frame.n[2]*local[2],-frame.e[1]*local[0]-frame.u[1]*local[1]+frame.n[1]*local[2]]);}
 function localPoint(p){var d=Math3.mul(worldToBody(Math3.add(p,Math3.mul(anchor,-1))),17374),me=[d[0],-d[2],d[1]];return [Mission.dot(me,frame.e),Mission.dot(me,frame.u),-Mission.dot(me,frame.n)];}
 function orbitEye(){var a=(yaw-60)*Math.PI/180,b=pitch*Math.PI/180;return [Math.sin(a)*Math.cos(b)*zoom,Math.sin(b)*zoom,Math.cos(a)*Math.cos(b)*zoom];}
 function cameraPose(){if(travel===0)return {eye:orbitalEye,target:[0,0,0],up:orbitalUp};var q=Mission.clamp((travel-.4)/.6,0,1),dir0=Math3.unit(departureEye),dir1=Math3.unit(globalDirection([Math.sin(localYaw*Math.PI/180)*Math.cos(localPitch*Math.PI/180),Math.sin(localPitch*Math.PI/180),Math.cos(localYaw*Math.PI/180)*Math.cos(localPitch*Math.PI/180)])),angle=Math.acos(Mission.clamp(Math3.dot(dir0,dir1),-1,1)),t=Mission.clamp(travel/.4,0,1),dir=angle<.001?dir1:Math3.unit(Math3.add(Math3.mul(dir0,Math.sin((1-t)*angle)),Math3.mul(dir1,Math.sin(t*angle)))),distance=Math.sqrt(Math3.dot(departureEye,departureEye))*Math.pow((localDistance/17374)/Math.sqrt(Math3.dot(departureEye,departureEye)),q),target=Math3.mix([0,0,0],Math3.add(anchor,Math3.mul(globalDirection([0,.028+groundY+altitude,0]),1/17374)),Math.min(1,travel/.4));return {eye:Math3.add(target,Math3.mul(dir,distance)),target:target,up:Math3.unit(Math3.add(Math3.mix(departureUp,globalDirection([0,1,0]),travel),[.2*Math.sin(Math.PI*travel),0,.1*Math.sin(Math.PI*travel)]))};}
 function getTerrainHeightAt(x,z){return customTerrain.heightAt(x,z);}
 function resetCamera(){yaw=0;pitch=0;zoom=6.2;localDistance=.22;}
 function inspectLander(){localPitch=22;localDistance=.15;}
 function topView(){localPitch=60;localDistance=40;}
 function zoomBy(delta){if(travel>0){if(!systemView){localDistance=Mission.clamp(localDistance*Math.exp(-delta*.001),.08,120);if(delta<0&&localDistance>=80&&!flight.running)orbit();}}else{zoom=Mission.clamp(zoom*Math.exp(-delta*.001),1.4,2000);}}
 function land(){descending=false;touchdown.stop();flight.stop();if(travel===0){departureUp=orbitalUp;departureEye=orbitalEye;}systemView=false;altitude=1.2;compression=1;wobble=0;phase="APPROACH";flight.to=1;flight.start();}
 function orbit(){descending=false;touchdown.stop();flight.stop();phase="RETURN TO ORBIT";flight.to=0;flight.start();}
 NumberAnimation { id: flight; target: root; property: "travel"; duration: 1900; easing.type: Easing.InOutCubic
  onFinished: {if(root.travel===1){root.phase="POWERED DESCENT";root.verticalSpeed=-2;root.descentTime=0;root.descending=true;}else{root.systemView=true;root.phase="ORBITAL CONTEXT";root.localDistance=.22;}}
 }
 Timer { interval: 16; repeat: true; running: root.descending
  onTriggered: {var dt=.064,h=root.altitude*100,target=-Math.max(.7,Math.min(15,Math.sqrt(2*1.2*h))),thrust=Mission.clamp(1.62+1.8*(target-root.verticalSpeed),0,4.8);root.verticalSpeed+=(-1.62+thrust)*dt;root.altitude=Math.max(0,root.altitude+root.verticalSpeed*dt/100);root.descentTime+=dt;root.wobble=Math.sin(root.descentTime*2.7)*Math.min(1,h/30);if(root.altitude<=0){root.descending=false;root.phase="TOUCHDOWN / DAMPING";touchdown.start();}}
 }
 SequentialAnimation { id: touchdown
  ParallelAnimation {
   SequentialAnimation { NumberAnimation { target: root; property: "compression"; to: .94; duration: 90 } NumberAnimation { target: root; property: "compression"; to: 1; duration: 90 } }
   SequentialAnimation { NumberAnimation { target: root; property: "wobble"; from: 1.2; to: -.7; duration: 130 } NumberAnimation { target: root; property: "wobble"; to: .35; duration: 130 } NumberAnimation { target: root; property: "wobble"; to: -.15; duration: 130 } NumberAnimation { target: root; property: "wobble"; to: 0; duration: 130 } }
  }
  ScriptAction { script: root.phase="LANDED / STABLE" }
 }
 View3D {
  id: orbitView; objectName: "orbitViewport"; anchors.fill: parent; opacity: 1-root.blend; visible: opacity>.001
  camera: orbitCamera
  environment: SceneEnvironment { backgroundMode: SceneEnvironment.Color; clearColor: "#05070b"; antialiasingMode: SceneEnvironment.MSAA; antialiasingQuality: SceneEnvironment.High; lightProbe: Texture { textureData: ProceduralSkyTextureData { skyTopColor: "#485361"; skyHorizonColor: "#8c9299"; groundBottomColor: "#20232a"; groundHorizonColor: "#62666b"; skyEnergy: .3; groundEnergy: .2 } } }
  PerspectiveCamera { id: orbitCamera; objectName: "orbitCamera"; position: root.v(root.pose.eye); rotation: Math3.lookRotation(root.pose.eye,root.pose.target,root.pose.up); clipNear: root.travel===0?.02:.000001; clipFar: Math.max(1000,root.zoom*3+300); fieldOfView: 48 }
  DirectionalLight { eulerRotation: Qt.vector3d(-Math.asin(root.sunDirection[1])*180/Math.PI,Math.atan2(root.sunDirection[0],root.sunDirection[2])*180/Math.PI,0); brightness: 1.5 }
  DirectionalLight { eulerRotation: Qt.vector3d(25,160,0); brightness: .15; ambientColor: "#343942" }
  // The body rotates inside the nonrotating, Moon-centered viewer frame.
  // The orbit camera is a sibling, so it follows the center without inheriting spin.
  Node {
   objectName: "lunarBodyFrame"
   rotation: Qt.quaternion(root.lunarRotation.w,root.lunarRotation.x,root.lunarRotation.y,root.lunarRotation.z)
   RuntimeLoader { id: moon; objectName: "moonGlobe"; source: "assets/science/moon-topography.glb"; scale: Qt.vector3d(.001,.001,.001); onStatusChanged: if(status===RuntimeLoader.Success)root.prepareGlobe(moon) }
  }
  Node {
   objectName: "selectedSitePin"
   visible: root.mission.siteMarked
   position: root.v(Math3.add([root.pinPosition.x,root.pinPosition.y,root.pinPosition.z],Math3.mul(Math3.unit([root.pinPosition.x,root.pinPosition.y,root.pinPosition.z]),root.pinLift)))
   readonly property var outward: Math3.alignUp([root.pinPosition.x,root.pinPosition.y,root.pinPosition.z])
   rotation: Qt.quaternion(outward.w,outward.x,outward.y,outward.z)
   Node {
    readonly property real factor: .3/PinGeometry.geometry.height*root.pinSize
    scale: Qt.vector3d(factor,factor*root.pinSquash,factor)
    RuntimeLoader { id: selectionPin; objectName: "selectionPinAsset"; source: "assets/pin.glb"; y: -PinGeometry.geometry.tip[1] }
   }
  }
  Model { id: earth; objectName: "earthGlobe"; source: "#Sphere"; position: root.v(root.worldVector('earth',25)); scale: Qt.vector3d(.07,.07,.07); materials: PrincipledMaterial { baseColorMap: Texture { source: "assets/earth-nasa.jpg" } roughness: .8 } }
  Model { objectName: "sunGlobe"; source: "#Sphere"; position: root.v(root.worldVector('sun',275)); scale: Qt.vector3d(.24,.24,.24); materials: PrincipledMaterial { baseColor: "#ffdc91"; lighting: PrincipledMaterial.NoLighting } }
  Repeater3D { model: 200
   Model { required property int index; source: "#Sphere"; position: Qt.vector3d(Math.sin(index*12.7)*90,Math.cos(index*7.2)*90,Math.sin(index*17.1)*90); scale: Qt.vector3d(.0005,.0005,.0005); materials: PrincipledMaterial { baseColor: "#8995ac"; lighting: PrincipledMaterial.NoLighting } }
  }
  MouseArea { anchors.fill: parent; enabled: !flight.running; property point previous; property point pressedAt; property bool moved: false
   onPressed: mouse => {previous=Qt.point(mouse.x,mouse.y);pressedAt=previous;moved=false;}
   onPositionChanged: mouse => {if(pressed){var dx=mouse.x-previous.x,dy=mouse.y-previous.y;root.yaw+=dx*.3;root.pitch=Mission.clamp(root.pitch+dy*.3,-75,65);previous=Qt.point(mouse.x,mouse.y);if(Math.hypot(mouse.x-pressedAt.x,mouse.y-pressedAt.y)>4)moved=true;}}
   onClicked: mouse => {if(!moved)root.selectAt(mouse.x,mouse.y);}
   onWheel: wheel => root.zoomBy(wheel.angleDelta.y)
  }
 }
 View3D {
  id: surfaceView; anchors.fill: parent; opacity: root.blend; visible: opacity>.001; camera: surfaceCamera
  environment: SceneEnvironment { backgroundMode: SceneEnvironment.Color; clearColor: "#080b10"; antialiasingMode: SceneEnvironment.MSAA; antialiasingQuality: SceneEnvironment.High; aoEnabled: true; aoDistance: .1; aoStrength: 40
   lightProbe: Texture { textureData: ProceduralSkyTextureData { skyTopColor: "#7c8b9c"; skyHorizonColor: "#b8bbc0"; groundBottomColor: "#303238"; groundHorizonColor: "#737478"; skyEnergy: .7; groundEnergy: .4 } }
  }
  PerspectiveCamera { id: surfaceCamera; position: root.v(root.localPoint(root.pose.eye)); rotation: Math3.lookRotation(root.localPoint(root.pose.eye),root.localPoint(root.pose.target),root.localPoint(Math3.add(root.anchor,root.pose.up))); clipNear: .001; clipFar: 2000; fieldOfView: 48 }
  DirectionalLight { eulerRotation: Qt.vector3d(-root.mission.instant.sunEl,180-root.mission.instant.sunAz,0); brightness: root.mission.instant.sunEl>0?2:0; castsShadow: true; shadowMapQuality: Light.ShadowMapQualityVeryHigh; shadowBias: .001; shadowFactor: 95 }
  DirectionalLight { eulerRotation: Qt.vector3d(-45,-30,0); brightness: .45 }
  CustomTerrain { id: customTerrain; objectName: "terrainPatch"; site: root.mission.site; slopeVisible: root.slopeVisible }
  Node { id: landedBody; y: root.landerY; rotation: Qt.quaternion(root.supports.rotation.w,root.supports.rotation.x,root.supports.rotation.y,root.supports.rotation.z)
   Node { eulerRotation: Qt.vector3d(root.wobble,0,root.wobble*.6); scale: Qt.vector3d(root.landerScale,root.landerScale*root.compression,root.landerScale)
    RuntimeLoader { id: lander; visible: root.landerVisible; source: "assets/lander.glb"; x: -(LanderGeometry.geometry.min[0]+LanderGeometry.geometry.max[0])/2; z: -(LanderGeometry.geometry.min[2]+LanderGeometry.geometry.max[2])/2 }
   }
  }
  MouseArea { anchors.fill: parent; enabled: root.travel===1&&!root.descending; property point lastPoint; onPressed: mouse => lastPoint=Qt.point(mouse.x,mouse.y); onPositionChanged: mouse => {if(pressed){root.localYaw+=(mouse.x-lastPoint.x)*.3;root.localPitch=Mission.clamp(root.localPitch+(mouse.y-lastPoint.y)*.3,5,85);lastPoint=Qt.point(mouse.x,mouse.y);}} }
  WheelHandler { target: null; onWheel: event => {root.zoomBy(event.angleDelta.y);} }
 }
 Text { anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 12; text: Mission.utcLabel(root.mission.currentUtc); color: "#c2ccd5"; font.family: "Consolas"; font.pixelSize: 12 }
 Column { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 12; spacing: 4
  Text { text: root.mission.site.name+" — "+root.phase; color: "white"; font.family: "Segoe UI"; font.pixelSize: 15 }
  Text { text: root.mission.site.lat.toFixed(4)+"° N, "+root.mission.site.lon.toFixed(4)+"° E"; color: "#c2ccd5"; font.family: "Consolas"; font.pixelSize: 12 }
 }
}









