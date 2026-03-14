import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets

StyledRect {
    id: root

    property bool show: false
    default property alias data: contentColumn.data
    property real backgroundHeight: 600
    property real backgroundAnimationMovementDistance: 60

    signal dismiss()

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            root.dismiss();
            event.accepted = true;
        }
    }
    color: ColorUtils.transparentize(Colors.colScrim, 0.5)
    visible: dialogBackground.implicitHeight > 0
    onShowChanged: {
        dialogBackground.implicitHeight = show ? backgroundHeight : 0;
    }
    radius: Rounding.verylarge

    // Clicking outside the dialog should dismiss
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        onPressed: root.dismiss()
    }

    Rectangle {
        id: dialogBackground

        property real targetY: root.height / 2 - root.backgroundHeight / 2

        anchors.horizontalCenter: parent.horizontalCenter
        radius: parent.radius
        color: Colors.m3.m3surfaceContainerHigh // Use opaque version of layer3
        y: root.show ? targetY : (targetY - root.backgroundAnimationMovementDistance)
        anchors.fill: parent
        anchors.margins: Padding.large

        // So clicking inside the dialog won't dismiss
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
        }

        ColumnLayout {
            id: contentColumn

            spacing: 16
            opacity: root.show ? 1 : 0

            anchors {
                fill: parent
                margins: 2 * Padding.huge
            }

            Behavior on opacity {
                Anim {
                }

            }

        }

        Behavior on implicitHeight {
            Anim {
            }

        }

        Behavior on y {
            Anim {
            }

        }

    }

    Behavior on color {
        CAnim {
        }

    }

}
