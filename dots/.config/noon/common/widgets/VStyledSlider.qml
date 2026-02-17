import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

// Material 3 vertical slider. See https://m3.material.io/components/sliders/overview
Slider {
    id: root

    property real scale: 0.85
    property real backgroundDotSize: 4 * scale
    property real backgroundDotMargins: 4 * scale
    property real handleMargins: (root.pressed ? 0 : 2) * scale
    property real handleHeight: (root.pressed ? 3 : 5) * scale   // thickness along the axis
    property real handleWidth: 44 * scale                         // span across the axis
    property real handleLimit: root.backgroundDotMargins
    property real trackWidth: 30 * scale
    property real trackRadius: Rounding.verysmall * scale
    property real unsharpenRadius: Rounding.tiny

    property color highlightColor: Colors.colPrimary
    property color trackColor: Colors.colSecondaryContainer
    property color handleColor: Colors.m3.m3onSecondaryContainer

    property bool enableTooltip: true
    property string tooltipContent: `${Math.round(value * 100)}%`
    property string icon
    property real wheelStepSize: 0.05
    property real limitedHandleRangeHeight: (root.availableHeight - handleHeight - root.handleLimit * 2)
    orientation: Qt.Vertical

    Layout.fillHeight: true
    from: 0
    to: 1

    MouseArea {
        anchors.fill: parent
        onPressed: mouse => {
            return mouse.accepted = false;
        }
        cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        onWheel: wheel => {
            // Positive delta = scroll up = increase value
            var delta = wheel.angleDelta.y / 120;
            var newValue = root.value + (delta * root.wheelStepSize);
            root.value = Math.max(root.from, Math.min(root.to, newValue));
            wheel.accepted = true;
        }
    }

    Behavior on value {
        SmoothedAnimation {
            velocity: Animations.durations.small
        }
    }

    Behavior on handleMargins {
        Anim {}
    }

    background: Item {
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: trackWidth

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            height: root.handleLimit * 2 + (1 - root.visualPosition) * root.limitedHandleRangeHeight - (root.handleMargins + root.handleHeight / 2)
            width: trackWidth
            color: root.trackColor
            topLeftRadius: root.trackRadius
            topRightRadius: root.trackRadius
            bottomLeftRadius: root.unsharpenRadius
            bottomRightRadius: root.unsharpenRadius
            // Symbol {
            //     visible: root.icon.length > 0
            //     anchors {
            //         top: parent.top
            //         topMargin: Padding.large
            //         horizontalCenter: parent.horizontalCenter
            //     }
            //     fill: 1
            //     text: root.icon
            //     color: Colors.highlightColor
            //     font.pixelSize: 18
            // }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            height: root.handleLimit * 2 + root.visualPosition * root.limitedHandleRangeHeight - (root.handleMargins + root.handleHeight / 2)
            width: trackWidth
            color: root.highlightColor
            topLeftRadius: root.unsharpenRadius
            topRightRadius: root.unsharpenRadius
            bottomLeftRadius: root.trackRadius
            bottomRightRadius: root.trackRadius
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.backgroundDotMargins
            width: root.backgroundDotSize
            height: root.backgroundDotSize
            radius: Rounding.full
            color: root.handleColor
        }
    }

    handle: Rectangle {
        id: handle

        x: root.leftPadding + root.availableWidth / 2 - width / 2
        y: root.topPadding + root.handleLimit + (1 - root.visualPosition) * root.limitedHandleRangeHeight

        implicitWidth: root.handleWidth
        implicitHeight: root.handleHeight
        radius: Rounding.full
        color: root.handleColor

        StyledToolTip {
            extraVisibleCondition: root.enableTooltip && root.pressed
            content: root.tooltipContent
        }

        Behavior on implicitHeight {
            Anim {}
        }
    }
}
