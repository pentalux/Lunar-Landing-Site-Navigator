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
 SetupPanel { Layout.preferredWidth: 300; Layout.fillHeight: true; mission: root.controller; onCalculate: {mission.playing=false;mission.seek(0);scene.land();} onOrbit: scene.orbit() }
 ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 8
 RowLayout { Layout.fillWidth: true
 Button { objectName: "orbitButton"; text: "â—„ Orbit view"; onClicked: scene.orbit() }
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
 Dialog { id: comparison; objectName: "comparisonDialog"; title: "Compare sites"; anchors.centerIn: parent; width: Math.min(950,root.width-40); height: Math.min(740,root.height-40); modal: true; standardButtons: Dialog.Close
 ScrollView { anchors.fill: parent; contentWidth: availableWidth
 ColumnLayout { width: parent.width
 Repeater { model: Mission.sites
 Label { required property var modelData; required property int index; Layout.fillWidth: true; text: modelData.name+"    Sun "+mission.comparisons[index].sunPct.toFixed(1)+"%    Earth "+mission.comparisons[index].earthPct.toFixed(1)+"%"; font.family: "Consolas"; padding: 8 }
 }
 }
 }
 }
 Dialog { id: reportDialog; objectName: "reportDialog"; title: "Simulation report"; anchors.centerIn: parent; width: 740; height: 590; modal: true; standardButtons: Dialog.Close
 ScrollView { anchors.fill: parent; TextArea { id: reportArea; readOnly: true; selectByMouse: true; wrapMode: TextEdit.Wrap; font.family: "Consolas" } }
 }
 Dialog { id: dataDialog; objectName: "dataDialog"; title: "Data and method"; anchors.centerIn: parent; width: 650; height: 350; modal: true; standardButtons: Dialog.Close
 Label { anchors.fill: parent; wrapMode: Text.Wrap; text: "NASA LOLA terrain and SPICE DE421 / MOON_ME ephemerides for 2026–2027. Global height source: approximately 474 m at the equator. South-polar coverage uses 80 m heights. The globe and local terrain share geographic coordinates and NASA LROC albedo.\n\nThe local mesh samples 75 m cells near the lander; this does not add detail beyond the height source. Fine rocks and footpad hazards require local stereo DEMs.\n\nVisibility is geometric. Power assumes horizontal panels. Descent uses a simplified vertical controller. The viewer includes fill lighting; globe distances are compressed.\n\nSee docs/DATA_SOURCES.md for sources and limits." }
 }
}

