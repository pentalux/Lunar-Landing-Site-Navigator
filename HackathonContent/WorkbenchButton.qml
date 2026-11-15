import QtQuick
import QtQuick.Controls

Button {
    id: control
    property bool accent: false
    property bool active: false
    property string hint: ""
    implicitHeight: 30
    implicitWidth: Math.max(30, label.implicitWidth + 22)
    hoverEnabled: true
    padding: 8
    font.family: "Segoe UI"
    font.pixelSize: 12
    contentItem: Text {
        id: label
        text: control.text
        font: control.font
        color: !control.enabled ? "#929ca5" : control.accent ? "#ffffff" : control.active ? "#17577b" : "#33414c"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: 0
        color: control.accent ? (control.down ? "#174f70" : control.hovered ? "#29799e" : "#226b91") : control.active ? "#dceaf2" : control.down ? "#d5dde3" : control.hovered ? "#e6ecf0" : "#d2d3d4"
        Rectangle { x: 1; y: 1; width: parent.width-2; height: 1; color: "#f2f2f2"; opacity: control.accent?.2:1 }
        border.color: control.active ? "#8eafc2" : control.accent ? "#226b91" : "#82878b"
    }
    ToolTip.visible: hovered && hint.length > 0
    ToolTip.text: hint
    ToolTip.delay: 600
    Accessible.name: text
}

