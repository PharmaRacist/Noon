import QtQuick
import Quickshell
pragma Singleton

Singleton {
    property QtObject taskbar
    property QtObject startMenu

    startMenu: QtObject {
        property size size: Qt.size(620, 720)
    }

    taskbar: QtObject {
        property int height: 42
        property int trayItemSize: 20
    }

}
