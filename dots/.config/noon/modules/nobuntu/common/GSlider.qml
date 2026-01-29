import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

Slider {
    id: root

    property real scale: 1.0
    property real trackHeight: 6 * scale
    property real handleSize: 20 * scale
    property real hoverScale: root.hovered ? 1.05 : 1.0

    property color accentColor: Colors.colPrimary
    property color trackBgColor: Colors.m3.m3surfaceVariant
    property color handleColor: "#FFFFFF"

    property real wheelStepSize: 0.05

    Layout.fillWidth: true
    from: 0
    to: 1

    MouseArea {
        anchors.fill: parent
        onPressed: mouse => mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
        onWheel: wheel => {
            var delta = wheel.angleDelta.y / 120;
            var newValue = root.value + (delta * root.wheelStepSize);
            root.value = Math.max(root.from, Math.min(root.to, newValue));
            wheel.accepted = true;
        }
    }

    Behavior on value {
        SmoothedAnimation {
            velocity: 1.0
        }
    }

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: root.trackHeight
        width: root.availableWidth
        height: implicitHeight
        radius: height / 2
        color: root.trackBgColor

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            color: root.accentColor
            radius: parent.radius
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: root.handleSize * root.hoverScale
        implicitHeight: root.handleSize * root.hoverScale
        radius: height / 2
        color: root.handleColor

        border.color: Qt.rgba(0, 0, 0, 0.15)
        border.width: 1

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 100
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: 100
            }
        }
    }
}
