pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Mission.js" as Mission

Rectangle {
    id: root
    required property MissionController mission
    signal inspectSite(int index)
    color: "#25292c"
    ScrollView {
        id: scroll
        anchors.fill: parent
        anchors.margins: 26
        contentWidth: availableWidth
        clip: true
    ColumnLayout {
        width: scroll.availableWidth
        spacing: 0
        Text { text: "Compare landing sites"; font.family: "Segoe UI"; font.pixelSize: 25; font.weight: Font.Light; color: "#c4d1d8" }
        Text { Layout.topMargin: 8; text: "Same date range. Same constraints. Select a row to inspect the site."; font.family: "Segoe UI"; font.pixelSize: 11; color: "#7c8992" }
        Text { Layout.topMargin: 18; Layout.bottomMargin: 18; text: Mission.utcLabel(root.mission.startUtc)+"  /  "+root.mission.durationHours/24+" DAYS  /  1 H SAMPLE"; font.family: "Consolas"; font.pixelSize: 10; color: "#637f90" }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 39; color: "#3d4449"
            Row {
                anchors.fill: parent
                Repeater { model: ["CANDIDATE SITE","SUNLIGHT","EARTH LINK","JOINT / H","DARK / H"]
                    Text { required property string modelData; required property int index; width: index===0?parent.width*.34:parent.width*.165; height: 39; leftPadding: 10; verticalAlignment: Text.AlignVCenter; text: modelData; font.family: "Segoe UI"; font.pixelSize: 9; font.weight: Font.DemiBold; color: "#647782" }
                }
            }
        }
        Repeater {
            model: Mission.sites
            Rectangle {
                id: row
                required property var modelData
                required property int index
                readonly property var result: root.mission.comparisons[index]
                Layout.fillWidth: true; Layout.preferredHeight: 67; color: root.mission.selectedSite===index?"#344c59":mouse.containsMouse?"#354047":"#2b3034"
                Row {
                    anchors.fill: parent
                    Column { width: parent.width*.34; topPadding: 15; leftPadding: 10; spacing: 5
                        Text { text: row.modelData.name; font.family: "Segoe UI"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#c4d1d8" }
                        Text { text: row.modelData.code; font.family: "Consolas"; font.pixelSize: 10; color: "#82939e" }
                    }
                    Repeater { model: [row.result.sunPct.toFixed(1)+"%",row.result.earthPct.toFixed(1)+"%",row.result.jointHours.toString(),row.result.maxDark.toString()]
                        Text { required property string modelData; width: parent.width*.165; height: 67; leftPadding: 10; text: modelData; verticalAlignment: Text.AlignVCenter; font.family: "Consolas"; font.pixelSize: 17; color: "#9cc3d9" }
                    }
                }
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#4b5359" }
                MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.inspectSite(row.index); cursorShape: Qt.PointingHandCursor }
            }
        }
        Text { Layout.fillWidth: true; Layout.topMargin: 20; text: "Sunlight = Sun above terrain. Earth link = Earth above terrain + clearance margin.\nJoint = simultaneous availability. Dark = longest continuous darkness inside this interval."; font.family: "Segoe UI"; font.pixelSize: 11; color: "#7b8993"; lineHeight: 1.5; wrapMode: Text.Wrap }
        Item { Layout.fillHeight: true }
        Text { Layout.fillWidth: true; Layout.topMargin: 12; text: "NASA LOLA / SPICE DE421  ·  Regional screening, not landing certification."; font.family: "Consolas"; font.pixelSize: 10; color: "#947d56"; wrapMode: Text.Wrap }
    }
    }
}



