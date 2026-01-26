import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

StyledPopup {
    id: popup

    active: HyprlandService.isHyprland && hoverTarget && hoverTarget.containsMouse

    Item {
        id: root

        readonly property var focusedScreen: GlobalStates.focusedScreen
        readonly property var focusedWindow: Hyprland.focusedWindow
        readonly property var toplevel: Hyprland.toplevelForAddress(focusedWindow.address)
        readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
        readonly property string windowAppId: activeWindow.appId ?? ""
        readonly property var iconPath: DesktopEntries.byId(windowAppId).icon
        readonly property size mainSize: Qt.size(380, 214)

        clip: true
        anchors.fill: parent
        implicitHeight: preview.implicitHeight
        implicitWidth: preview.implicitWidth
        visible: preview.hasContent

        StyledRect {
            clip: true
            color: "transparent"
            radius: Rounding.verylarge

            anchors {
                fill: parent
                margins: Padding.normal
                topMargin: Padding.small
                bottomMargin: Padding.small
            }

            StyledScreencopyView {
                id: preview

                anchors.fill: parent
                constraintSize: root.mainSize
                captureSource: root.focusedScreen
                clip: true
                smooth: true
                radius: Rounding.verylarge

                IconImage {
                    id: appIcon

                    readonly property var iconSize: Math.min(preview.width, preview.height) * 0.13

                    mipmap: true
                    source: root.iconPath
                    width: iconSize
                    height: iconSize

                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        margins: 18
                    }

                }

            }

        }

    }

}
