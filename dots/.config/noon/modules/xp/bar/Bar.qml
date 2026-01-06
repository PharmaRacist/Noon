import "../common"
import "components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import qs.services
import qs.common
import QtQuick.Effects
import qs.common.widgets

StyledPanel {
    id: root

    visible: true
    name: "bar"
    shell: "xp"

    implicitHeight: XSizes.taskbar.height + Padding.normal
    exclusiveZone: XSizes.taskbar.height
    readonly property bool top: false

    anchors {
        top: root.top
        left: true
        right: true
        bottom: !root.top
    }

    StyledRect {
        id: taskbar

        anchors {
            top: root.top ? parent.top : undefined
            bottom: root.top ? undefined : parent.bottom
            right: parent.right
            left: parent.left
        }

        implicitHeight: XSizes.taskbar.height
        color: "#235EDC"

        RLayout {
            anchors.fill: parent
            StartButton {}
            PinnedAppsRow {}
            RunningAppsRow {}
            StatusRow {}
        }

        gradient: Gradient {
            GradientStop {
                position: 0.22
                color: XColors.colors.colPrimaryContainer
            }
            GradientStop {
                position: 0
                color: XColors.colors.colPrimaryBorder
            }
        }
    }
}
