import QtQuick

Rectangle {
    property string text: ""
    property string trailing: ""
    height: 32
    color: "#e9edf0"
    Text { anchors.left: parent.left; anchors.leftMargin: 13; anchors.verticalCenter: parent.verticalCenter; text: parent.text; font.family: "Segoe UI"; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1.1; color: "#52616d" }
    Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: parent.trailing; font.family: "Consolas"; font.pixelSize: 10; color: "#71818c" }
    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#cdd5db" }
}
