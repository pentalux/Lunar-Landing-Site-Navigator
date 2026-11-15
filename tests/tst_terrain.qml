import QtQuick
import QtTest
import "../HackathonContent"
import "../HackathonContent/Terrain.js" as Terrain
Item { width:1440;height:940
 Navigator{id:app;anchors.fill:parent;controller.settingsLocation:Qt.resolvedUrl("../build/terrain-test.ini")}
 TestCase{name:"GeographicTerrain";when:windowShown
 function test_terrain(){wait(1500);var scene=findChild(app,"sceneView"),patch=findChild(scene,"terrainPatch");tryCompare(scene,"moonReady",true,15000);tryCompare(scene,"landerReady",true,15000)
  for(var index=0;index<8;index++){app.controller.selectPreset(index);wait(50);verify(patch.vertexCount>50000);var g=patch.generated,mid=(g.size/2)*(g.size+1)+g.size/2,point=g.p[mid];verify(Math.abs(point.x)<1e-8&&Math.abs(point.z)<1e-8);verify(Math.abs(patch.heightAt(0,0)-point.y)<1e-8);verify(scene.supports.gaps.every(function(h){return h>=-1e-8;}));verify(Math.abs(Math.min.apply(Math,scene.supports.gaps))<1e-8);}
  compare(scene.assetError,"")
 }
 }
}
