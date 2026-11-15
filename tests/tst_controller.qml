import QtQuick
import QtTest
import "../HackathonContent"
TestCase {
 name: "MissionControllerPro"
 MissionController { id: mission; settingsLocation: Qt.resolvedUrl("../build/controller-pro-test.ini") }
 function test_saveAndRestore(){mission.selectedSite=3;mission.durationHours=2160;mission.observerHeight=3.5;mission.clearance=2.5;mission.panelWatts=2000;mission.saveMission();mission.selectedSite=0;mission.loadMission();compare(mission.selectedSite,3);compare(mission.durationHours,2160);compare(mission.panelWatts,2000);}
 function test_customAndDate(){verify(mission.setCustom(26.13,3.63));compare(mission.site.name,"Custom Site");compare(mission.selectedSite,-1);verify(!mission.setCustom(100,0));verify(!mission.setDate("2026-02-30"));verify(!mission.setDate("2028-01-01"));verify(mission.setDate("2026-11-15"));mission.seek(1e9);compare(mission.cursorHour,mission.durationHours);mission.seek(-1);compare(mission.cursorHour,0);}
 function test_realData(){mission.selectedSite=0;verify(mission.instant.valid);compare(mission.assessment.rows.length,mission.durationHours);compare(mission.comparisons.length,8);}
 function test_history(){
  mission.savedMissions=[];
  mission.selectPreset(2);mission.durationHours=672;mission.saveMission();
  verify(mission.setCustom(12.3,45.6));mission.panelWatts=2300;mission.saveMission();
  compare(mission.savedMissions.length,2);mission.saveMission();compare(mission.savedMissions.length,2);
  mission.selectPreset(0);mission.readHistory();compare(mission.savedMissions.length,2);
  mission.loadMission(0);compare(mission.selectedSite,-1);compare(mission.site.lat,12.3);compare(mission.panelWatts,2300);
  var rows=mission.comparisonRows();compare(rows.length,10);verify(rows[0].saved);compare(rows[0].config.watts,2300);verify(rows[0].result.valid);
  mission.loadMission(1);compare(mission.selectedSite,2);
  for(var i=0;i<22;i++){mission.panelWatts=3000+i;mission.saveMission();}compare(mission.savedMissions.length,20);
  mission.readHistory();compare(mission.savedMissions.length,20);compare(mission.savedMissions[0].watts,3021);
 }
}
