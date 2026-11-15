import QtQuick
import QtTest
import "../HackathonContent"
Item {width:1440;height:940
 Navigator{id:app;anchors.fill:parent;controller.settingsLocation:Qt.resolvedUrl("../build/polar-test.ini")}
 TestCase{name:"PolarMapping";when:windowShown
 function test_poles(){wait(1800);var scene=findChild(app,"sceneView"),view=findChild(scene,"orbitViewport"),patch=findChild(scene,"terrainPatch");tryCompare(scene,"moonReady",true,15000)
  for(var pole of [1,-1]){scene.pitch=pole*89.9;scene.zoom=1.65;wait(300);var hit=view.pick(scene.width/2,scene.height/2);verify(scene.isMoonHit(hit));verify(Math.abs(hit.uvPosition.x-.5)<.01);verify(Math.abs(hit.uvPosition.y-.5)<.01);}
  app.controller.setCustom(-89.8,45);scene.travel=1;scene.systemView=false;scene.altitude=0;scene.topView();wait(300);verify(patch.polarMapping);compare(scene.assetError,"")
 }
 }
}
