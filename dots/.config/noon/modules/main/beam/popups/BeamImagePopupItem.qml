import QtQuick.Layouts
import QtQuick
import Quickshell

import qs.common
import qs.store
import qs.common.widgets
import qs.services

StyledRect {
    property alias content: img.source
    implicitHeight: 100
    implicitWidth: 175
    clip: true
    radius: Rounding.large
    color: "transparent"
    enableBorders: true
    MouseArea {
        id: eventArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            Ai.pendingFilePath = "";
        }
    }
    Rectangle {
        anchors.fill: parent
        color: Colors.colScrim
        opacity: eventArea.containsMouse ? 0.5 : 0
        z: 999
        Symbol {
            anchors.centerIn: parent
            text: "delete"
            color: Colors.colOnLayer1
            font.pixelSize: 32
            fill: 1
        }
    }
    Image {
        id: img
        anchors.fill: parent
        asynchronous: true
        sourceSize: Qt.size(width, height)
    }
}
