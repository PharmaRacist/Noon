import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets

Rectangle {
    id: root

    property bool show: false
    default property alias data: contentColumn.data
    property real backgroundHeight: dialogBackground.implicitHeight
    property real backgroundWidth: 350
    property real backgroundAnimationMovementDistance: 60

    signal dismiss()

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            root.dismiss();
            event.accepted = true;
        }
    }
    color: root.show ? Colors.colScrim : ColorUtils.transparentize(Colors.colScrim)
    visible: dialogBackground.implicitHeight > 0
    onShowChanged: {
        dialogBackgroundHeightAnimation.easing.bezierCurve = (show ? Animations.curves.emphasizedDecel : Animations.curves.emphasizedAccel);
        dialogBackground.implicitHeight = show ? backgroundHeight : 0;
    }
    radius: Rounding.verylarge - Sizes.hyprland.gapsOut + 1

    MouseArea {
        // Clicking outside the dialog should dismiss
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        onPressed: root.dismiss()
    }

    StyledRect {
        id: dialogBackground

        property real targetY: root.height / 2 - root.backgroundHeight / 2

        anchors.horizontalCenter: parent.horizontalCenter
        radius: Rounding.verylarge
        color: Colors.m3.m3surface // Use opaque version of layer3
        y: root.show ? targetY : (targetY - root.backgroundAnimationMovementDistance)
        implicitWidth: root.backgroundWidth
        implicitHeight: contentColumn.implicitHeight + dialogBackground.radius * 2

        MouseArea {
            // So clicking inside the dialog won't dismiss
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
        }

        ColumnLayout {
            id: contentColumn

            spacing: Padding.verylarge
            opacity: root.show ? 1 : 0

            anchors {
                fill: parent
                margins: Padding.small
            }

            Behavior on opacity {
                Anim {
                }

            }

        }

        Behavior on implicitHeight {
            Anim {
                id: dialogBackgroundHeightAnimation
            }

        }

        Behavior on y {
            Anim {
                duration: dialogBackgroundHeightAnimation.duration
            }

        }

    }

    Behavior on color {
        CAnim {
        }

    }

}
