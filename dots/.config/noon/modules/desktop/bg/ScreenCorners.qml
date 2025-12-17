import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: screenCorners
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    Variants {
        model: Quickshell.screens

        PanelWindow {
            visible: Mem.options.desktop.screenCorners > 0

            property var modelData
            WlrLayershell.layer: WlrLayer.Overlay
            screen: modelData
            exclusionMode: ExclusionMode.Ignore
            mask: Region {}
            WlrLayershell.namespace: "noon:screenCorners"
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            RoundCorner {
                id: topLeftCorner
                anchors.top: parent.top
                anchors.left: parent.left
                size: Rounding.verylarge
                corner: cornerEnum.topLeft
                color: "black"
            }
            RoundCorner {
                id: topRightCorner
                anchors.top: parent.top
                anchors.right: parent.right
                size: Rounding.verylarge
                corner: cornerEnum.topRight
                color: "black"
            }
            RoundCorner {
                id: bottomLeftCorner
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                size: Rounding.verylarge
                corner: cornerEnum.bottomLeft
                color: "black"
            }
            RoundCorner {
                id: bottomRightCorner
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                size: Rounding.verylarge
                corner: cornerEnum.bottomRight
                color: "black"
            }
        }
    }
}
