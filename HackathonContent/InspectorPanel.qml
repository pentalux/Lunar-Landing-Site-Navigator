import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: panel
    required property MissionController mission
    color: "#f7f8f9"
    ColumnLayout {
        anchors.fill: parent; spacing: 0
        PanelHeading { Layout.fillWidth: true; text: "SITE ANALYSIS"; trailing: panel.mission.site.code }
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true
            contentWidth: availableWidth; clip: true
            Column {
                width: parent.width; spacing: 0
                Column {
                    width: parent.width-28; x: 14; spacing: 3
                    Item { width: 1; height: 13 }
                    Text { text: "SUN VISIBILITY"; font.family: "Segoe UI"; font.pixelSize: 10; font.letterSpacing: 1; color: "#7e8991" }
                    Row { spacing: 7
                        Text { text: panel.mission.instant.sunEl.toFixed(2)+"°"; font.family: "Segoe UI"; font.pixelSize: 29; font.weight: Font.Light; color: "#33424d" }
                        Text { anchors.bottom: parent.bottom; anchors.bottomMargin: 5; text: "elevation"; font.family: "Segoe UI"; font.pixelSize: 10; color: "#8a959c" }
                    }
                    PropertyRow { width: parent.width; label: "Azimuth"; value: panel.mission.instant.sunAz.toFixed(2)+"°" }
                    PropertyRow { width: parent.width; label: "Terrain horizon"; value: panel.mission.instant.sunH.toFixed(2)+"°" }
                    PropertyRow { width: parent.width; label: "Line of sight"; value: panel.mission.instant.sunVisible ? "ILLUMINATED" : "OCCLUDED"; valueColor: panel.mission.instant.sunVisible ? "#7e642d" : "#9e6660" }
                    Item { height: 12; width: 1 }
                }
                PanelHeading { width: parent.width; text: "DIRECT TO EARTH" }
                Column {
                    width: parent.width-28; x: 14; spacing: 1
                    Item { width: 1; height: 10 }
                    PropertyRow { width: parent.width; label: "Earth elevation"; value: panel.mission.instant.earthEl.toFixed(2)+"°" }
                    PropertyRow { width: parent.width; label: "Earth azimuth"; value: panel.mission.instant.earthAz.toFixed(2)+"°" }
                    PropertyRow { width: parent.width; label: "Horizon + margin"; value: (panel.mission.instant.earthH+panel.mission.clearance).toFixed(2)+"°" }
                    PropertyRow { width: parent.width; label: "Visibility"; value: panel.mission.instant.earthVisible ? "AVAILABLE" : "BLOCKED"; valueColor: panel.mission.instant.earthVisible ? "#467f70" : "#9e6660" }
                    Item { width: 1; height: 12 }
                }
                PanelHeading { width: parent.width; text: "HORIZON PROFILE"; trailing: "AZ / EL" }
                HorizonPlot { width: parent.width-16; x: 8; height: 132; compact: true; site: panel.mission.site; sample: panel.mission.instant }
                PanelHeading { width: parent.width; text: "ANALYSIS PARAMETERS" }
                Column {
                    width: parent.width-28; x: 14; spacing: 1
                    Item { height: 8; width: 1 }
                    PropertyRow { width: parent.width; label: "Observer height"; value: panel.mission.observerHeight.toFixed(1)+" m" }
                    Slider { width: parent.width; height: 24; from: 0; to: 10; stepSize: .1; value: panel.mission.observerHeight; onMoved: panel.mission.observerHeight=value }
                    PropertyRow { width: parent.width; label: "Earth clearance margin"; value: panel.mission.clearance.toFixed(1)+"°" }
                    Slider { width: parent.width; height: 24; from: 0; to: 5; stepSize: .1; value: panel.mission.clearance; onMoved: panel.mission.clearance=value }
                    Text { width: parent.width; text: "Visibility is geometric only; link budget and panel output are not modeled."; wrapMode: Text.Wrap; color: "#8a959c"; font.family: "Segoe UI"; font.pixelSize: 10; lineHeight: 1.3 }
                    Item { height: 14; width: 1 }
                }
            }
        }
    }
    Rectangle { width: 1; height: parent.height; color: "#bec8cf" }
}
