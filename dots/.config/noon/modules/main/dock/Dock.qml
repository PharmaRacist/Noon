import qs.services
import qs.common
import qs.common.widgets
import qs.modules.main.dock.components
import qs.modules.main.dock.components.osk
import qs.modules.main.dock
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: root
    property bool pinned: Mem.states.dock.pinned ?? false
    property bool showOsk: GlobalStates.main.oskOpen

    Variants {
        model: [Quickshell.screens[0]]

        StyledPanel {
            id: dockRoot
            name: "dock"
            shell: "nobuntu"
            WlrLayershell.layer: WlrLayer.Top

            screen: modelData

            required property var modelData
            readonly property bool reveal: root.pinned || mouseArea.containsMouse || (!ToplevelManager.activeToplevel?.activated && !GlobalStates.main.sidebar.expanded)

            implicitWidth: bg.implicitWidth + 100
            implicitHeight: bg.implicitHeight + 100
            exclusiveZone: root.pinned ? bg.implicitHeight + Sizes.elevationMargin : -1

            anchors.bottom: true

            mask: Region {
                item: mouseArea
            }

            MouseArea {
                id: mouseArea
                z: 99
                hoverEnabled: true
                height: parent.height
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: {
                    if (dockRoot.reveal && !GlobalStates.main.showBeam && !GlobalStates.main.showOsdValues)
                        return 5;
                    else
                        dockRoot.implicitHeight - 5;
                }
                opacity: anchors.topMargin > dockRoot.implicitHeight - 6 ? 0 : 1

                Behavior on anchors.topMargin {
                    Anim {}
                }
                StyledRectangularShadow {
                    target: bg
                }
                StyledRect {
                    id: bg
                    enableBorders: true
                    implicitWidth: content.implicitWidth
                    implicitHeight: content.implicitHeight
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: Sizes.elevationMargin
                    anchors.bottom: parent.bottom
                    color: Colors.colLayer0
                    radius: Rounding.verylarge

                    RowLayout {
                        id: content
                        spacing: Padding.small
                        anchors.centerIn: parent
                        DockApps {
                            Layout.margins: Padding.normal
                        }
                    }
                }
            }
        }
    }
}
