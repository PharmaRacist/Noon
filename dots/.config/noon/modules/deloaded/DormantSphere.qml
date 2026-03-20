import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.common.widgets
import qs.common.utils

Variants {
    model: MonitorsInfo.main
    StyledPanel {
        id: root
        visible: GlobalStates.showDormantSphere
        required property var modelData
        screen: modelData
        name: "dormant"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        mask: Region {
            item: sphere
        }
        exclusiveZone: -1
        WlrLayershell.layer: WlrLayer.Top

        StyledRect {
            id: sphere
            radius: Rounding.huge
            color: Colors.colPrimary
            width: 50
            height: 50

            x: root.width - width - Padding.large
            y: (root.height - height) / 3.25

            Behavior on x {
                Anim {}
            }

            Behavior on y {
                Anim {}
            }

            Symbol {
                id: icon
                anchors.centerIn: parent
                fill: 1
                text: "moon_stars"
                color: Colors.colOnPrimary
                font.pixelSize: Fonts.sizes.huge
            }
            StyledToolTip {
                extraVisibleCondition: eventArea.containsMouse && !eventArea.drag.active
                content: "Dormant State \nDouble Click To Restore Shell"
            }
            MouseArea {
                id: eventArea
                anchors.fill: parent
                cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                hoverEnabled: true
                z: 999
                drag.target: sphere
                drag.axis: Drag.XAndYAxis
                drag.minimumX: 0
                drag.maximumX: root.width - sphere.width
                drag.minimumY: 0
                drag.maximumY: root.height - sphere.height

                onDoubleClicked: {
                    Mem.states.desktop.shell.deload = false;
                }
                onReleased: {
                    const snapLeft = sphere.x + sphere.width / 2 < root.width / 2;
                    const margins = Padding.large;
                    sphere.x = snapLeft ? margins : root.width - sphere.width - margins;
                }
            }
        }
    }
}
