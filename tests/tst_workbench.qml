import QtQuick
import QtTest
import "../HackathonContent"
Item {
 id: testRoot; width: 1440; height: 940
 Navigator { id: navigator; anchors.fill: parent; controller.settingsLocation: Qt.resolvedUrl("../build/workbench-fix-test.ini") }
 TestCase {
  name: "SceneFixes"; when: windowShown
  function snapshot(name){var p=decodeURIComponent(Qt.resolvedUrl("../docs/fix-"+name+".png").toString()).replace(/^file:\/\/\//,"");grabImage(navigator).save(p);}
  function test_scene(){
   wait(3500)
   var scene=findChild(navigator,"sceneView")
   tryCompare(scene,"landerReady",true,30000)
   compare(scene.assetError,"")
   snapshot("orbit")
   mouseClick(findChild(navigator,"calculateButton"))
   tryCompare(scene,"phase","POWERED DESCENT",10000)
   snapshot("descent")
   tryCompare(scene,"phase","LANDED / STABLE",60000)
   compare(scene.altitude,0)
   verify(Math.abs(scene.contactGap)<1e-8,"Model bottom must contact the rendered triangle")
   verify(scene.supports.gaps.every(function(g){return g>=-1e-8;}));console.log("Runtime minimum Y / mesh minimum Y",scene.runtimeMinY,scene.modelBottomOffsetY/scene.landerScale,"support gaps (m)",scene.supports.gaps.map(function(g){return g*100;}))
   compare(scene.assetError,"")
   snapshot("surface")
   scene.inspectLander();wait(300);snapshot("lander");mouseWheel(scene,scene.width/2,scene.height/2,0,-8000);tryCompare(scene,"phase","ORBITAL CONTEXT",10000);compare(scene.travel,0);verify(scene.blend===0);scene.land();tryCompare(scene,"phase","LANDED / STABLE",60000)
   scene.slopeVisible=true;wait(1000);snapshot("slope")
   var before=scene.pose.eye.slice()
   scene.orbit()
   for(var k=0;k<3;k++)verify(Math.abs(scene.pose.eye[k]-before[k])<1e-10,"Return must not change camera pose at animation start")
   tryCompare(scene,"phase","ORBITAL CONTEXT",10000)
   compare(scene.travel,0)
   verify(navigator.controller.setCustom(26.13,3.63))
   scene.land();wait(2500);compare(scene.assetError,"");snapshot("custom")
   scene.orbit();wait(2200)
   testRoot.width=1180;testRoot.height=760;wait(400);snapshot("compact")
   mouseClick(findChild(navigator,"reportButton"));tryCompare(findChild(navigator,"reportDialog"),"opened",true);snapshot("report");findChild(navigator,"reportDialog").close()
   mouseClick(findChild(navigator,"methodButton"));tryCompare(findChild(navigator,"dataDialog"),"opened",true);findChild(navigator,"dataDialog").close()
   mouseClick(findChild(navigator,"compareButton"));tryCompare(findChild(navigator,"comparisonDialog"),"opened",true);findChild(navigator,"comparisonDialog").close()
   findChild(navigator,"calendarButton").clicked();tryCompare(findChild(navigator,"calendarPopup"),"opened",true);findChild(navigator,"calendarPopup").close();navigator.controller.selectedSite=4;navigator.controller.seek(180);wait(300);snapshot("favorable")
  }
 }
}


