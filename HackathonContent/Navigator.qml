pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Mission.js" as Mission
Pane {
 id: root
 property alias controller: mission
 property int activeView: 1
 font.family: "Segoe UI"
 font.pixelSize: 14
 padding: 8
 MissionController { id: mission }
 Shortcut { sequence: "Space"; onActivated: mission.playing=!mission.playing }
 ColumnLayout { anchors.fill: parent; spacing: 8
 RowLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 10
 SetupPanel { Layout.preferredWidth: 300; Layout.fillHeight: true; mission: root.controller; onCalculate: {mission.playing=false;mission.seek(0);scene.land();} onRestoreRequested: historyDialog.open() }
 ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 8
 RowLayout { Layout.fillWidth: true
 Button { objectName: "orbitButton"; text: "Orbit view"; onClicked: scene.orbit() }
 Button { text: "Lander"; onClicked: scene.inspectLander() }
 Button { text: "Region"; onClicked: scene.topView() }
 CheckBox { text: "Slope overlay"; checked: scene.slopeVisible; onToggled: scene.slopeVisible=checked }
 Item { Layout.fillWidth: true }
 Button { objectName: "compareButton"; text: "Compare sites"; onClicked: comparison.open() }
 Button { objectName: "reportButton"; text: "Report"; onClicked: {reportArea.text=mission.reportText();reportDialog.open();} }
 Button { objectName: "methodButton"; text: "Data and method"; onClicked: dataDialog.open() }
 }
 SceneView { id: scene; objectName: "sceneView"; Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 250; mission: root.controller }
 RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 190; Layout.maximumHeight: 190
 GroupBox { title: "Solar and power"; Layout.preferredWidth: 225; Layout.fillHeight: true
 ColumnLayout { anchors.fill: parent
 Label { text: (mission.instant.solarFactor*mission.panelWatts).toFixed(0)+" W"; font.family: "Consolas"; font.pixelSize: 24 }
 Label { text: "Sunset: "+mission.sunset; font.family: "Consolas" }
 Label { text: "Availability: "+mission.assessment.sunPct.toFixed(1)+"%\nLongest night: "+mission.assessment.maxDark+" h\nSun elevation: "+mission.instant.sunEl.toFixed(2)+"Â°"; font.family: "Consolas" }
 }
 }
 GroupBox { title: "Earth communication"; Layout.preferredWidth: 225; Layout.fillHeight: true
 ColumnLayout { anchors.fill: parent
 Label { text: mission.instant.earthVisible?"Visible":"Blocked"; font.pixelSize: 24 }
 Label { text: "Earthset: "+mission.earthset; font.family: "Consolas" }
 Label { text: "Availability: "+mission.assessment.earthPct.toFixed(1)+"%\nJoint window: "+mission.assessment.jointHours+" h\nEarth elevation: "+mission.instant.earthEl.toFixed(2)+"Â°"; font.family: "Consolas" }
 }
 }
 GroupBox { title: "Local horizon"; Layout.fillWidth: true; Layout.fillHeight: true
 HorizonPlot { anchors.fill: parent; site: mission.site; sample: mission.instant; observerHeight: mission.observerHeight }
 }
 }
 }
 }
 GroupBox { title: "Mission timeline"; Layout.fillWidth: true; Layout.preferredHeight: 208
 ColumnLayout { anchors.fill: parent; spacing: 2
 RowLayout { Button { text: mission.playing?"Pause":"Play"; onClicked: mission.playing=!mission.playing } Button { text: "+6 h"; onClicked: mission.seek(mission.cursorHour+6) } Button { text: "+24 h"; onClicked: mission.seek(mission.cursorHour+24) } Button { text: "Start"; onClicked: mission.seek(0) } Label { text: "Drag the cursor to inspect time" } }
 Timeline { Layout.fillWidth: true; Layout.fillHeight: true; assessment: mission.assessment; startUtc: mission.startUtc; cursorHour: mission.cursorHour; durationHours: mission.durationHours; onSeek: hour => mission.seek(hour) }
 }
 }
 Label { Layout.fillWidth: true; text: mission.message; elide: Text.ElideRight }
 }
 Dialog { id: historyDialog; objectName: "historyDialog"; title: "Saved missions"; anchors.centerIn: parent; width: Math.min(850,root.width-40); height: Math.min(650,root.height-40); modal: true; standardButtons: Dialog.Close
 ScrollView { anchors.fill: parent; contentWidth: availableWidth
 ColumnLayout { width: historyDialog.availableWidth; spacing: 12
 Label { Layout.fillWidth: true; text: "Restore a saved location and its mission settings. Save keeps the 20 most recent configurations."; wrapMode: Text.WordWrap; font.pixelSize: 16 }
 Label { visible: mission.savedMissions.length===0; text: "No saved missions yet. Choose a location and press Save."; font.pixelSize: 16 }
 Repeater { model: mission.savedMissions
 Frame { required property var modelData; required property int index; Layout.fillWidth: true
 RowLayout { anchors.fill: parent
 ColumnLayout { Layout.fillWidth: true
 Label { text: mission.recordName(modelData); font.pixelSize: 20; font.bold: true }
 Label { text: mission.recordDetails(modelData); font.pixelSize: 16; wrapMode: Text.WordWrap; Layout.fillWidth: true }
 Label { text: "Observer "+modelData.height+" m | Earth margin "+modelData.margin+" deg | Panel "+modelData.watts+" W"; font.pixelSize: 15; wrapMode: Text.WordWrap; Layout.fillWidth: true }
 }
 Button { text: "Restore"; font.pixelSize: 16; onClicked: {mission.loadMission(index);historyDialog.close();} }
 }
 }
 }
 }
 }
 }
 Dialog { id: comparison; objectName: "comparisonDialog"; title: "Compare sites"; anchors.centerIn: parent; width: Math.min(1120,root.width-40); height: Math.min(800,root.height-40); modal: true; standardButtons: Dialog.Close
 property var rows: []
 onOpened: rows=mission.comparisonRows()
 onClosed: rows=[]
 ScrollView { anchors.fill: parent; contentWidth: availableWidth
 ColumnLayout { width: comparison.availableWidth; spacing: 12
 Label { Layout.fillWidth: true; font.pixelSize: 16; wrapMode: Text.WordWrap; text: "Saved missions use their own dates and hardware settings. Reference presets below use the current settings. Different timeframes may produce different results." }
 Label { visible: mission.savedMissions.length===0; text: "Press Save to include your custom locations here."; font.pixelSize: 16 }
 Repeater { model: comparison.rows
 Frame { required property var modelData; Layout.fillWidth: true
 readonly property var config: modelData.config
 readonly property var result: modelData.result
 ColumnLayout { anchors.fill: parent; spacing: 8
 Label { text: (modelData.saved?"Saved mission: ":"Reference: ")+mission.recordName(config); font.pixelSize: 21; font.bold: true; Layout.fillWidth: true; wrapMode: Text.WordWrap }
 Label { text: mission.recordDetails(config); font.pixelSize: 16; Layout.fillWidth: true; wrapMode: Text.WordWrap }
 Label { text: "Sunlight: "+result.sunPct.toFixed(1)+"%    |    Earth visibility: "+result.earthPct.toFixed(1)+"%"; font.pixelSize: 18; Layout.fillWidth: true; wrapMode: Text.WordWrap }
 Label { text: "Favorable window: "+result.jointHours+" h ("+(100*result.jointHours/config.hours).toFixed(1)+"%)    |    Longest darkness: "+result.maxDark+" h"; font.pixelSize: 18; Layout.fillWidth: true; wrapMode: Text.WordWrap }
 Label { text: "Mean solar power: "+(result.meanFactor*config.watts).toFixed(0)+" W    |    Estimated energy: "+(result.meanFactor*config.watts*config.hours/1000).toFixed(1)+" kWh"; font.pixelSize: 18; Layout.fillWidth: true; wrapMode: Text.WordWrap }
 Label { text: "Observer "+config.height+" m | Earth margin "+config.margin+" deg | Panel "+config.watts+" W"; font.pixelSize: 15; Layout.fillWidth: true; wrapMode: Text.WordWrap }
 }
 }
 }
 }
 }
 }
 Dialog { id: reportDialog; objectName: "reportDialog"; title: "Simulation report"; anchors.centerIn: parent; width: 740; height: 590; modal: true; standardButtons: Dialog.Close
 ScrollView { anchors.fill: parent; TextArea { id: reportArea; readOnly: true; selectByMouse: true; wrapMode: TextEdit.Wrap; font.family: "Consolas" } }
 }
 Dialog { id: dataDialog; objectName: "dataDialog"; title: "Data and method"; anchors.centerIn: parent; width: Math.min(900,root.width-40); height: Math.min(780,root.height-40); modal: true; standardButtons: Dialog.Close
 ScrollView { anchors.fill: parent; contentWidth: availableWidth
 Label { width: dataDialog.availableWidth; font.pixelSize: 17; padding: 12; wrapMode: Text.WordWrap; text:
 "DATA COVERAGE\nOffline NASA LOLA heights and SPICE-derived JPL DE421 / MOON_ME Sun and Earth vectors for 2026-2027. Mission windows: 28, 45, 60 or 90 days, fully inside coverage. Python prepares the bundled data; JavaScript performs runtime calculations.\n\nTERRAIN AND DISPLAY\nGlobal DEM spacing is approximately 474 m at the equator; bundled south-polar coverage uses 80 m heights. The local mesh uses 75 m cells near the lander, which does not increase source resolution. NASA LROC albedo provides surface appearance. The globe and local patch are separate scenes. Fill lighting, compressed orbital distances and visual surface detail are presentation aids.\n\nVISIBILITY\nSun and Earth directions use hourly geometric vectors with linear interpolation and an observer-position correction. A sampled 360-degree terrain horizon includes lunar curvature: preset profiles reach 100 km; custom profiles reach up to 150 km. Observer height changes the horizon; Earth clearance adds an angular margin above it. Visibility uses body centers, without finite-disc, eclipse, relay or radio-link models.\n\nTIMELINE AND POWER\nAvailability, longest darkness, mean power and energy use hourly midpoint samples. Favorable Window means Sun and Earth are both visible. Horizontal-panel power equals rated power times max(0, sin(Sun elevation)), and is zero when terrain blocks the Sun. Batteries, thermal effects and electrical losses are excluded. Sunset and Earthset search up to 40 days ahead; displayed minutes are estimates.\n\nSAVED MISSIONS AND COMPARISON\nSave keeps up to 20 recent configurations locally. Restore opens this history. Saved comparisons retain their own dates and hardware settings; reference presets use the current settings. Identical configurations are moved to the top instead of duplicated.\n\nLIMITATIONS\nTerrain cannot resolve small rocks or certify landing safety. The lander uses a simplified vertical controller and scripted touchdown, without a full flight or suspension solver. This is a preliminary mission-planning prototype. Source provenance and further limitations: docs/DATA_SOURCES.md." }
 }
 }
}
