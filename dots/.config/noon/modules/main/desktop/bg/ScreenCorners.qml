import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.common
import qs.common.utils
import qs.common.widgets

Scope {
    id: screenCorners

    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            visible: Mem.options.desktop.screenCorners > 0
            WlrLayershell.layer: WlrLayer.Overlay
            screen: modelData
            exclusionMode: ExclusionMode.Ignore
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

            mask: Region {
            }

        }

    }

}
