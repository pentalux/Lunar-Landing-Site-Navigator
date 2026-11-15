pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Mission.js" as Mission
Pane {
 id: root
 required property MissionController mission
 signal calculate()
 signal orbit()
 padding: 0
 Component.onCompleted: scroll.contentItem.contentY=0
 ColumnLayout { anchors.fill: parent; spacing: 8
 ScrollView { id: scroll; Layout.fillWidth: true; Layout.fillHeight: true; contentWidth: availableWidth; clip: true
 ColumnLayout { width: scroll.availableWidth; spacing: 10
 GroupBox { title: "Landing site"; Layout.fillWidth: true
 ColumnLayout { anchors.fill: parent
 ComboBox { objectName: "sitePreset"; Layout.fillWidth: true; model: Mission.sites.map(function(s){return s.name;}); currentIndex: root.mission.selectedSite; displayText: root.mission.selectedSite<0?"Custom site":currentText; onActivated: root.mission.selectPreset(currentIndex) }
 Label { text: "Latitude (° N) / Longitude (° E)" }
 RowLayout {
 TextField { id: lat; objectName: "latitudeInput"; Layout.fillWidth: true; text: root.mission.site.lat.toFixed(4); validator: DoubleValidator { bottom: -90; top: 90; locale: "en_US" } }
 TextField { id: lon; objectName: "longitudeInput"; Layout.fillWidth: true; text: root.mission.site.lon.toFixed(4); validator: DoubleValidator { bottom: -180; top: 180; locale: "en_US" } }
 }
 Button { text: "Set site"; Layout.fillWidth: true; onClicked: root.mission.setCustom(Number(lat.text),Number(lon.text)) }
 Label { Layout.fillWidth: true; text: "LOLA source resolution: "+root.mission.site.resolution+" m"; wrapMode: Text.Wrap }
 }
 }
 GroupBox { title: "Date and duration"; Layout.fillWidth: true
 ColumnLayout { anchors.fill: parent
 Label { text: "Start date (UTC)" }
 TextField { id: date; objectName: "startDate"; Layout.fillWidth: true; text: Mission.dateLabel(root.mission.startUtc); onEditingFinished: {root.mission.setDate(text);text=Mission.dateLabel(root.mission.startUtc);} }
 Button { objectName: "calendarButton"; text: "Calendar…"; Layout.fillWidth: true; onClicked: calendar.open() }
 ComboBox { Layout.fillWidth: true; model: ["28 days","45 days","60 days","90 days"]; currentIndex: [672,1080,1440,2160].indexOf(root.mission.durationHours); onActivated: {var h=[672,1080,1440,2160][currentIndex];if(root.mission.startUtc+h*3600000<=Date.UTC(2028,0,1)){root.mission.durationHours=h;root.mission.seek(root.mission.cursorHour);}else root.mission.message="Selected window extends beyond ephemeris coverage.";} }
 Label { text: "Data coverage: 2026–2027" }
 }
 }
 GroupBox { title: "Lander hardware"; Layout.fillWidth: true
 ColumnLayout { anchors.fill: parent
 Label { text: "Mast height: "+root.mission.observerHeight.toFixed(1)+" m" }
 Slider { Layout.fillWidth: true; from: 0; to: 10; stepSize: .1; value: root.mission.observerHeight; onMoved: root.mission.observerHeight=value }
 Label { text: "Earth clearance: "+root.mission.clearance.toFixed(1)+"°" }
 Slider { Layout.fillWidth: true; from: 0; to: 5; stepSize: .1; value: root.mission.clearance; onMoved: root.mission.clearance=value }
 Label { text: "Panel rating (W)" }
 SpinBox { Layout.fillWidth: true; from: 100; to: 100000; stepSize: 100; editable: true; value: root.mission.panelWatts; onValueModified: root.mission.panelWatts=value }
 }
 }
 }
 }
 Button { objectName: "calculateButton"; text: "Calculate simulation"; Layout.fillWidth: true; onClicked: root.calculate() }
 Button { text: "Orbit view"; Layout.fillWidth: true; onClicked: root.orbit() }
 RowLayout { Layout.fillWidth: true
 Button { text: "Save"; Layout.fillWidth: true; onClicked: root.mission.saveMission() }
 Button { text: "Restore"; Layout.fillWidth: true; onClicked: root.mission.loadMission() }
 }
 }
 Popup { id: calendar; objectName: "calendarPopup"; x: root.width+5; y: 120; width: 320; height: 320; modal: true
 ColumnLayout { anchors.fill: parent
 RowLayout { Button { text: "‹"; onClicked: {if(month.month===0){month.month=11;month.year--;}else month.month--;} } Label { Layout.fillWidth: true; text: month.title; horizontalAlignment: Text.AlignHCenter } Button { text: "›"; onClicked: {if(month.month===11){month.month=0;month.year++;}else month.month++;} } }
 DayOfWeekRow { Layout.fillWidth: true; locale: Qt.locale("en_US") }
 MonthGrid { id: month; Layout.fillWidth: true; Layout.fillHeight: true; month: 10; year: 2026; locale: Qt.locale("en_US"); onClicked: d => {root.mission.setDate(d.getFullYear()+"-"+('0'+(d.getMonth()+1)).slice(-2)+"-"+('0'+d.getDate()).slice(-2));date.text=Mission.dateLabel(root.mission.startUtc);calendar.close();} }
 }
 }
}
