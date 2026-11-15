import QtQuick
import QtTest
import "../HackathonContent"
Item {
 width: 1280; height: 900
 Navigator { id: nav; anchors.fill: parent; controller.settingsLocation: Qt.resolvedUrl("../build/dialog-history-test.ini") }
 TestCase {
  name: "SavedMissionDialogs"; when: windowShown
  function test_dialogs(){
   nav.controller.savedMissions=[];nav.controller.saveMission();
   var history=findChild(nav,"historyDialog");history.open();tryCompare(history,"opened",true);history.close();
   var comparison=findChild(nav,"comparisonDialog");comparison.open();tryCompare(comparison,"opened",true);compare(comparison.rows.length,9);wait(300);
   comparison.close();
   var method=findChild(nav,"dataDialog");method.open();tryCompare(method,"opened",true);method.close();
  }
 }
}
