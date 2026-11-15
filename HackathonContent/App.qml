import QtQuick

Window {
    width: Math.min(1440, Screen.desktopAvailableWidth - 60)
    height: Math.min(940, Screen.desktopAvailableHeight - 80)
    minimumWidth: 1180
    minimumHeight: 760

    visible: true
    title: "Mission Analysis"

    Screen01 {
        id: mainScreen

        anchors.fill: parent
    }

}



