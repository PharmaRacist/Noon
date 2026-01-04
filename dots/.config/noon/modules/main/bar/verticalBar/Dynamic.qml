import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.store

StyledRect {
    id: barBackground

    // Enum definitions
    enum BarMode {
        Floating,
        Docked,
        DockedCornered,
        Notch
    }

    enum BarPosition {
        Left,
        Right
    }

    property var barRoot
    property var modelData
    readonly property int mode: Mem.options.bar.appearance.mode
    readonly property bool rightMode: Mem.options.bar.behavior.position === "right"
    readonly property int barRadius: Rounding.verylarge
    readonly property int barMargins: Sizes.hyprland.gapsOut
    readonly property int barElevation: Sizes.barElevation

    enableShadows: true
    enableBorders: false
    color: Mem.options.bar.appearance.useBg ? Colors.colLayer0 : "transparent"
    anchors.fill: parent
    states: [
        State {
            name: "floating"
            when: mode === Dynamic.BarMode.Floating

            PropertyChanges {
                target: barBackground
                anchors.rightMargin: rightMode ? barElevation : 0
                anchors.leftMargin: !rightMode ? barElevation : 0
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
            when: mode === Dynamic.BarMode.Docked

            PropertyChanges {
                target: barBackground
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
            when: mode === Dynamic.BarMode.DockedCornered

            PropertyChanges {
                target: barBackground
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
                anchors.top: barBackground.top
                anchors.left: rightMode ? undefined : barBackground.right
                anchors.right: rightMode ? barBackground.left : undefined
                anchors.topMargin: Sizes.frameThickness
            }

            PropertyChanges {
                target: c2
                visible: true
                corner: rightMode ? cornerEnum.bottomRight : cornerEnum.bottomLeft
                anchors.bottom: barBackground.bottom
                anchors.left: rightMode ? undefined : barBackground.right
                anchors.right: rightMode ? barBackground.left : undefined
                anchors.bottomMargin: Sizes.frameThickness
            }
        },
        State {
            name: "notch"
            when: mode === Dynamic.BarMode.Notch

            PropertyChanges {
                target: barBackground
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

        parent: barBackground.parent || barRoot
        visible: false
    }

    RoundCorner {
        id: c2

        parent: barBackground.parent || barRoot
        visible: false
    }
}
