import QtQuick
import QtTest
import "../HackathonContent"
TestCase {
 name: "MissionControllerPro"
 MissionController { id: mission; settingsLocation: Qt.resolvedUrl("../build/controller-pro-test.ini") }
 function test_saveAndRestore(){mission.selectedSite=3;mission.durationHours=2160;mission.observerHeight=3.5;mission.clearance=2.5;mission.panelWatts=2000;mission.saveMission();mission.selectedSite=0;mission.loadMission();compare(mission.selectedSite,3);compare(mission.durationHours,2160);compare(mission.panelWatts,2000);}
 function test_customAndDate(){verify(mission.setCustom(26.13,3.63));compare(mission.site.name,"Custom Site");compare(mission.selectedSite,-1);verify(!mission.setCustom(100,0));verify(!mission.setDate("2026-02-30"));verify(!mission.setDate("2028-01-01"));verify(mission.setDate("2026-11-15"));mission.seek(1e9);compare(mission.cursorHour,mission.durationHours);mission.seek(-1);compare(mission.cursorHour,0);}
 function test_realData(){mission.selectedSite=0;verify(mission.instant.valid);compare(mission.assessment.rows.length,mission.durationHours);compare(mission.comparisons.length,8);}
}
