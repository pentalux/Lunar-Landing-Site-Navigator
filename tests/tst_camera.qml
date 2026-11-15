import QtQuick
import QtTest
import "../HackathonContent"
Item {
 id: root; width: 1440; height: 940
 Navigator { id: app; anchors.fill: parent; controller.settingsLocation: Qt.resolvedUrl("../build/camera-test.ini") }
 TestCase {
  name: "MoonCenteredCamera"; when: windowShown
  function cameraState(camera){return [camera.x,camera.y,camera.z,camera.rotation.scalar,camera.rotation.x,camera.rotation.y,camera.rotation.z];}
  function unchanged(camera,state){var now=cameraState(camera);for(var i=0;i<now.length;i++)verify(Math.abs(now[i]-state[i])<1e-7,"Camera changed with lunar rotation at component "+i);}
  function centered(scene){var p=scene.projectMoonCenter();verify(Math.abs(p.x-scene.width/2)<.05,"Center X: "+p.x+" expected "+scene.width/2);verify(Math.abs(p.y-scene.height/2)<.05,"Center Y: "+p.y+" expected "+scene.height/2);}
  function snapshot(name){var p=decodeURIComponent(Qt.resolvedUrl("../docs/camera-"+name+".png").toString()).replace(/^file:\/\/\//,"");grabImage(app).save(p);}
  function test_independentRotation(){
   wait(1800)
   var scene=findChild(app,"sceneView"),camera=findChild(scene,"orbitCamera"),body=findChild(scene,"lunarBodyFrame"),pin=findChild(scene,"selectedSitePin")
   verify(camera!==null);verify(body!==null);tryCompare(scene,"pinReady",true,15000)
   var initial=cameraState(camera)
   app.controller.selectPreset(4);wait(500);snapshot("reference")
   for(var hour of [24,72,336]){app.controller.seek(hour);wait(200);unchanged(camera,initial);centered(scene);verify(Math.abs(body.rotation.scalar)<.999,"Moon must rotate while camera stays still");}
   snapshot("half-cycle")
   // A drag still changes the view; advancing time must preserve that new orientation.
   mouseDrag(scene,scene.width/2,scene.height/2,55,30);wait(150)
   var dragged=cameraState(camera);verify(Math.abs(dragged[0]-initial[0])>.01)
   app.controller.seek(360);wait(200);unchanged(camera,dragged);centered(scene)
   // Picking uses body coordinates even after the globe has rotated.
   var p=scene.worldToBody(scene.orbitalEye),r=Math.hypot(p[0],p[1],p[2]),lat=Math.asin(p[1]/r)*180/Math.PI,lon=Math.atan2(-p[2],p[0])*180/Math.PI,screen=scene.projectOnGlobe(lat,lon)
   mouseClick(scene,screen.x,screen.y);wait(500)
   compare(app.controller.selectedSite,-1);verify(Math.abs(app.controller.site.lat-lat)<.5);verify(Math.abs(app.controller.site.lon-lon)<.5)
   compare(pin.visible,true);verify(scene.pinTipRadius>.99&&scene.pinTipRadius<1.01)
   // The selected marker follows the surface, without moving the orbital camera.
   var previous=Qt.vector3d(pin.x,pin.y,pin.z)
   app.controller.seek(384);wait(200);unchanged(camera,dragged);centered(scene)
   verify(pin.position.minus(previous).length()>.1,"Pin movement "+pin.position.minus(previous).length());verify(scene.pinTipRadius>.99&&scene.pinTipRadius<1.01,"Pin radius "+scene.pinTipRadius)
   snapshot("selected-after-rotation")
   // Local ENU coordinates remain unchanged when the whole lunar body rotates.
   var local=[.15,.08,-.21],world=scene.globalDirection(local),point=[scene.anchor[0]+world[0]/17374,scene.anchor[1]+world[1]/17374,scene.anchor[2]+world[2]/17374],roundtrip=scene.localPoint(point)
   for(var k=0;k<3;k++)verify(Math.abs(roundtrip[k]-local[k])<1e-8)
   scene.land();tryCompare(scene,"phase","LANDED / STABLE",45000);verify(Math.abs(scene.contactGap)<1e-8);compare(scene.assetError,"")
   var localEye=scene.localPoint(scene.pose.eye)
   app.controller.seek(408);wait(200)
   var nextEye=scene.localPoint(scene.pose.eye);for(k=0;k<3;k++)verify(Math.abs(localEye[k]-nextEye[k])<1e-5,"Local camera should stay with the lander")
   scene.orbit();tryCompare(scene,"phase","ORBITAL CONTEXT",10000);unchanged(camera,dragged);centered(scene)
  }
 }
}
