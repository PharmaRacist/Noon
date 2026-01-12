import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.services
import qs.store

StyledPanel {
    name: "no_anim"
    shell: "noon"
    visible: GlobalStates.main.showScreenshot
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    Item {
        id: content
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Sizes.elevationMargin
        }
        implicitWidth: controlsRow.implicitWidth + Padding.verylarge * 4
        implicitHeight: Sizes.screenshot.size.height
        StyledRectangularShadow {
            target: bg
        }
        StyledRect {
            id: bg
            color: Colors.colLayer0
            enableBorders: true
            radius: Rounding.verylarge
            anchors.fill: parent
            anchors.margins: Padding.verylarge
            RowLayout {
                id: controlsRow
                anchors.centerIn: parent
                spacing: Padding.large
                Repeater {
                    model: [
                        {
                            "name": "full",
                            "icon": "screenshot_frame_2",
                            "hint": "Take a full screenshot",
                            "action": () => {
                            // Implement full screenshot action here
                            }
                        },
                        {
                            "name": "window",
                            "icon": "ad",
                            "hint": "Take a screenshot of an active window",
                            "action": () => {
                            // Implement area screenshot action here
                            }
                        },
                        {
                            "name": "area",
                            "icon": "screenshot_region",
                            "hint": "Take a screenshot of a selected area",
                            "action": () => {
                            // Implement area screenshot action here
                            }
                        }
                    ]
                    RippleButtonWithIcon {
                        materialIcon: modelData.icon
                        releaseAction: () => modelData.action()
                        StyledToolTip {
                            extraVisibleCondition: parent.hovered
                            content: modelData.hint
                        }
                    }
                }
            }
        }
    }
    mask: Region {
        item: content
    }
}
