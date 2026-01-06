pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property QtObject taskbar
    property QtObject startMenu
    property QtObject run

    run: QtObject {
        property size size: Qt.size(400, 200)
        property size sizeMax: Qt.size(500, 240)
    }

    startMenu: QtObject {
        property size size: Qt.size(500, 600)
        property real rightSideWidth: size.width * 0.435
    }

    taskbar: QtObject {
        property int height: 38
        property int pinnedItemSize: 20
        property int trayItemSize: 20
    }
}
