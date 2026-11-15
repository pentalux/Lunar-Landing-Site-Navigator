import QtQuick
import QtTest
import "../HackathonContent"
Item {
 width: 1200; height: 850
 Navigator { id: app; anchors.fill: parent }
 TestCase { name: "LunarUV"; when: windowShown
  function test_coordinates(){
   wait(1500)
   var scene=findChild(app,"sceneView"),view=findChild(scene,"orbitViewport")
   tryCompare(scene,"moonReady",true,15000)
   for(var p of [[0,0],[0,90],[0,-90],[30,0],[-30,0]]){
    scene.yaw=p[1]+150;scene.pitch=p[0];wait(150)
    var screen=scene.projectOnGlobe(p[0],p[1]),hit=view.pick(screen.x,screen.y)
    console.log("UV",p,hit.uvPosition,hit.scenePosition)
    verify(scene.isMoonHit(hit))
    verify(Math.abs(hit.uvPosition.x-(p[1]+180)/360)<.002,"Longitude does not match albedo UV")
    verify(Math.abs(hit.uvPosition.y-(p[0]+90)/180)<.002,"Latitude does not match albedo UV")
   }
  }
 }
}
