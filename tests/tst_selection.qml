import QtQuick
import QtTest
import "../HackathonContent"
Item {
 id: root; width: 1440; height: 940
 Navigator { id: app; anchors.fill: parent; controller.settingsLocation: Qt.resolvedUrl("../build/pin-test.ini") }
 TestCase {
  name: "SingleSelectionPin"; when: windowShown
  function snapshot(name){var p=decodeURIComponent(Qt.resolvedUrl("../docs/selection-"+name+".png").toString()).replace(/^file:\/\/\//,"");grabImage(app).save(p);}
  function test_selection(){
   wait(1800)
   var scene=findChild(app,"sceneView"),pin=findChild(scene,"selectedSitePin"),asset=findChild(scene,"selectionPinAsset"),preset=findChild(app,"sitePreset")
   verify(pin!==null);tryCompare(scene,"pinReady",true,15000);verify(!app.controller.siteMarked)
   // Selecting the already-active default preset must also show its marker.
   preset.currentIndex=0;preset.activated(0);verify(app.controller.siteMarked);verify(pin.visible)
   // Choose a front-facing preset and rotate to see its outward-facing pin.
   preset.currentIndex=4;preset.activated(4);compare(app.controller.selectedSite,4)
   scene.yaw=150;scene.pitch=5;wait(300);snapshot("preset")
   scene.resetCamera();wait(200)
   var point=scene.projectOnGlobe(0,-150)
   mouseClick(scene,point.x,point.y)
   compare(app.controller.selectedSite,-1);verify(Math.abs(app.controller.site.lat)<1);verify(Math.abs(app.controller.site.lon+150)<1)
   console.log("Pin tip",scene.pinTipRadius,scene.pinPosition);verify(scene.pinTipRadius>.99&&scene.pinTipRadius<1.01,"Tip radius "+scene.pinTipRadius);verify(pin.visible);compare(scene.phase,"ORBITAL CONTEXT")
   snapshot("click")
   var first=pin,lat=app.controller.site.lat,lon=app.controller.site.lon
   point=scene.projectOnGlobe(15,-140);mouseClick(scene,point.x,point.y)
   compare(first,findChild(scene,"selectedSitePin"));verify(Math.abs(app.controller.site.lat-lat)>5);verify(Math.abs(app.controller.site.lon-lon)>5)
   snapshot("replaced")
   // Empty-space clicks and drags do not change the selected landing site.
   lat=app.controller.site.lat;lon=app.controller.site.lon
   mouseClick(scene,20,scene.height-30);compare(app.controller.site.lat,lat);compare(app.controller.site.lon,lon)
   mouseDrag(scene,scene.width/2,scene.height/2,50,10);compare(app.controller.site.lat,lat);compare(app.controller.site.lon,lon)
   preset.currentIndex=6;preset.activated(6);compare(app.controller.selectedSite,6);compare(first,findChild(scene,"selectedSitePin"));verify(pin.visible)
   compare(scene.assetError,"")
  }
 }
}

