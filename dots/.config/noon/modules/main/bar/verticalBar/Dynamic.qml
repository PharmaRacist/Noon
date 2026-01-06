import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.store

Item {
    id: root

    property var barRoot
    property var modelData
    readonly property int mode: Mem.options.bar.appearance.mode
    readonly property bool rightMode: Mem.options.bar.behavior.position === "right"
    readonly property int barRadius: Rounding.verylarge
    readonly property int barMargins: Sizes.hyprland.gapsOut

    anchors.fill: parent
    StyledRectangularShadow {
        target: bg
    }
    StyledRect {
        id: bg

        enableBorders: false
        color: Mem.options.bar.appearance.useBg ? Colors.colLayer0 : "transparent"
        anchors.fill: parent
        states: [
            State {
                name: "floating"
                when: mode === 0

                PropertyChanges {
                    target: bg
                    anchors.rightMargin: rightMode ? Sizes.barElevation : 0
                    anchors.leftMargin: !rightMode ? Sizes.barElevation : 0
                    anchors.topMargin: barMargins
                    anchors.bottomMargin: barMargins
                    radius: barRadius
                    enableBorders: Mem.options.bar.appearance.outline
                }

                PropertyChanges {
                    target: c1
                    visible: false
                }

                PropertyChanges {
                    target: c2
                    visible: false
                }
            },
            State {
                name: "docked"
                when: mode === 1

                PropertyChanges {
                    target: bg
                    anchors.margins: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    radius: 0
                    enableBorders: false
                }

                PropertyChanges {
                    target: c1
                    visible: false
                }

                PropertyChanges {
                    target: c2
                    visible: false
                }
            },
            State {
                name: "dockedCornered"
                when: mode === 2

                PropertyChanges {
                    target: bg
                    anchors.margins: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    anchors.leftMargin: !rightMode ? 0 : Rounding.verylarge
                    anchors.rightMargin: rightMode ? 0 : Rounding.verylarge
                    radius: 0
                    enableBorders: false
                }

                PropertyChanges {
                    target: c1
                    visible: true
                    corner: rightMode ? cornerEnum.topRight : cornerEnum.topLeft
                    anchors.top: bg.top
                    anchors.left: rightMode ? undefined : bg.right
                    anchors.right: rightMode ? bg.left : undefined
                    anchors.topMargin: Sizes.frameThickness
                }

                PropertyChanges {
                    target: c2
                    visible: true
                    corner: rightMode ? cornerEnum.bottomRight : cornerEnum.bottomLeft
                    anchors.bottom: bg.bottom
                    anchors.left: rightMode ? undefined : bg.right
                    anchors.right: rightMode ? bg.left : undefined
                    anchors.bottomMargin: Sizes.frameThickness
                }
            },
            State {
                name: "notch"
                when: mode === 3

                PropertyChanges {
                    target: bg
                    anchors.margins: 0
                    anchors.topMargin: barMargins
                    anchors.bottomMargin: barMargins
                    radius: 0
                    topLeftRadius: rightMode ? barRadius : undefined
                    topRightRadius: !rightMode ? barRadius : undefined
                    bottomLeftRadius: rightMode ? barRadius : undefined
                    bottomRightRadius: !rightMode ? barRadius : undefined
                    enableBorders: false
                }

                PropertyChanges {
                    target: c1
                    visible: false
                }

                PropertyChanges {
                    target: c2
                    visible: false
                }
            }
        ]
        transitions: [
            Transition {
                Anim {
                    properties: "radius,topLeftRadius,topRightRadius,bottomLeftRadius,bottomRightRadius,anchors.rightMargin,anchors.leftMargin,anchors.topMargin,anchors.bottomMargin,anchors.margins,anchors.leftMargin,anchors.rightMargin"
                }

                // Anim {
                //     properties: "anchors.topMargin,anchors.bottomMargin"
                //     target: [c1, c2]
                // }
            }
        ]

        Content {}

        RoundCorner {
            id: c1

            parent: bg.parent || barRoot
            visible: false
        }

        RoundCorner {
            id: c2

            parent: bg.parent || barRoot
            visible: false
        }
    }
}
