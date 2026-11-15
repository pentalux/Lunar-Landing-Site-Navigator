import QtQuick

Item {
    property string label: ""
    property string value: ""
    property color valueColor: "#263741"
    height: 26
    Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: parent.label; font.family: "Segoe UI"; font.pixelSize: 11; color: "#687681" }
    Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: parent.value; font.family: "Consolas"; font.pixelSize: 12; color: parent.valueColor }
}
