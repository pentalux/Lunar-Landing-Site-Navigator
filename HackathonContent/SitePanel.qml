pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Mission.js" as Mission

Rectangle {
    id: panel
    required property MissionController mission
    property bool gridVisible: true
    property bool landerVisible: true
    property bool slopeVisible: false
    signal showData()
    color: "#f4f6f7"
    ScrollView {
        id: scroll
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
    ColumnLayout {
        width: scroll.availableWidth; spacing: 0
        PanelHeading { Layout.fillWidth: true; text: "MISSION EXPLORER"; trailing: "01" }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 65; color: "#edf1f4"
            Column { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                Text { text: "Lunar south pole"; font.family: "Segoe UI"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#283e4c" }
                Text { text: "Landing site study / Demo mission"; font.family: "Segoe UI"; font.pixelSize: 11; color: "#72818d" }
            }
        }
        PanelHeading { Layout.fillWidth: true; text: "CANDIDATE SITES"; trailing: "04" }
        Repeater {
            model: Mission.sites
            delegate: Rectangle {
                id: siteRow
                required property var modelData
                required property int index
                Layout.fillWidth: true; Layout.preferredHeight: 65
                color: panel.mission.selectedSite===index ? "#dfeaf1" : siteMouse.containsMouse ? "#eaf0f4" : "transparent"
                Rectangle { width: 3; height: parent.height; color: "#27769d"; visible: panel.mission.selectedSite===siteRow.index }
                Text { x: 14; y: 12; text: siteRow.modelData.code; font.family: "Consolas"; font.pixelSize: 10; color: panel.mission.selectedSite===siteRow.index ? "#266c91" : "#8a969e" }
                Text { x: 58; y: 10; text: siteRow.modelData.name; font.family: "Segoe UI"; font.pixelSize: 12; font.weight: panel.mission.selectedSite===siteRow.index ? Font.DemiBold : Font.Normal; color: "#334550" }
                Text { x: 58; y: 32; text: Math.abs(siteRow.modelData.lat).toFixed(2)+"° S  /  "+Math.abs(siteRow.modelData.lon).toFixed(2)+"° "+(siteRow.modelData.lon<0?"W":"E"); font.family: "Consolas"; font.pixelSize: 10; color: "#74828d" }
                Rectangle { anchors.bottom: parent.bottom; x: 12; width: parent.width-24; height: 1; color: "#e1e6e9" }
                MouseArea { id: siteMouse; anchors.fill: parent; hoverEnabled: true; onClicked: {panel.mission.selectedSite=siteRow.index;panel.mission.message="Selected "+siteRow.modelData.name;} }
                Accessible.role: Accessible.Button
                Accessible.name: modelData.name
                Accessible.onPressAction: panel.mission.selectedSite=index
            }
        }
        PanelHeading { Layout.fillWidth: true; text: "SCENE CONTENTS"; trailing: "3D" }
        Column {
            Layout.fillWidth: true; Layout.leftMargin: 9; Layout.topMargin: 8; Layout.bottomMargin: 8
            CheckBox { text: "Landing module · LND-01"; checked: panel.landerVisible; font.family: "Segoe UI"; font.pixelSize: 11; onToggled: panel.landerVisible=checked }
            CheckBox { text: "Reference grid · 18 m"; checked: panel.gridVisible; font.family: "Segoe UI"; font.pixelSize: 11; onToggled: panel.gridVisible=checked }
            CheckBox { text: "Terrain slope overlay"; checked: panel.slopeVisible; font.family: "Segoe UI"; font.pixelSize: 11; onToggled: panel.slopeVisible=checked }
        }
        Item { Layout.preferredHeight: 12 }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 110; Layout.margins: 12
            color: "#e9eef1"; border.color: "#d1dbe1"; radius: 2
            Column {
                anchors.fill: parent; anchors.margins: 12; spacing: 7
                Text { text: "DEMONSTRATION DATA"; font.family: "Segoe UI"; font.pixelSize: 9; font.letterSpacing: 1; font.weight: Font.DemiBold; color: "#7d6b4b" }
                Text { width: parent.width; text: "Synthetic terrain and sky tracks.\nConnect mission data before use."; font.family: "Segoe UI"; font.pixelSize: 10; color: "#77838b"; lineHeight: 1.35 }
                Text { text: "Data sources & method  ↗"; color: "#296e91"; font.family: "Segoe UI"; font.pixelSize: 11
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: panel.showData() }
                }
            }
        }
    }
    }
    Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: "#bec8cf" }
}

