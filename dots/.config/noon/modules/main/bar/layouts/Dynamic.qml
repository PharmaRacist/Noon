import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.store

StyledRect {
    id: root

    property var barRoot
    property var modelData
    readonly property int mode: Mem.options.bar.appearance.mode
    readonly property bool bottomMode: Mem.options.bar.behavior.position === "bottom"
    readonly property int barRadius: Rounding.verylarge
    readonly property int barMargins: Sizes.hyprland.gapsOut

    enableBorders: mode === 0
    enableShadows: mode === 0
    color: Mem.options.bar.appearance.useBg ? Colors.colLayer0 : "transparent"
    anchors.fill: parent
    states: [
        State {
            name: "floating"
            when: mode === 0

            PropertyChanges {
                target: root
                anchors.margins: Sizes.barElevation
                anchors.leftMargin: barMargins
                anchors.rightMargin: barMargins
                anchors.topMargin: root.bottomMode ? 0 : Sizes.barElevation
                anchors.bottomMargin: root.bottomMode ? Sizes.barElevation : 0
                radius: barRadius
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
                target: root
                anchors.margins: 0
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                radius: 0
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
                target: root
                anchors.margins: 0
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.topMargin: root.bottomMode ? Rounding.verylarge : 0
                anchors.bottomMargin: root.bottomMode ? 0 : Rounding.verylarge
                radius: 0
            }

            PropertyChanges {
                target: c1
                visible: true
                corner: root.bottomMode ? cornerEnum.bottomLeft : cornerEnum.topLeft
                anchors.left: root.left
                anchors.leftMargin: Sizes.frameThickness
                anchors.top: root.bottomMode ? undefined : root.bottom
                anchors.bottom: root.bottomMode ? root.top : undefined
            }

            PropertyChanges {
                target: c2
                visible: true
                corner: root.bottomMode ? cornerEnum.bottomRight : cornerEnum.topRight
                anchors.right: root.right
                anchors.rightMargin: Sizes.frameThickness
                anchors.top: root.bottomMode ? undefined : root.bottom
                anchors.bottom: root.bottomMode ? root.top : undefined
            }

        },
        State {
            name: "notch"
            when: mode === 3

            PropertyChanges {
                target: root
                anchors.margins: 0
                anchors.leftMargin: barMargins
                anchors.rightMargin: barMargins
                anchors.topMargin: root.bottomMode ? Rounding.verylarge : 0
                anchors.bottomMargin: root.bottomMode ? 0 : Rounding.verylarge
                radius: 0
                topLeftRadius: !root.bottomMode ? undefined : barRadius
                topRightRadius: !root.bottomMode ? undefined : barRadius
                bottomLeftRadius: !root.bottomMode ? barRadius : undefined
                bottomRightRadius: !root.bottomMode ? barRadius : undefined
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
            name: "notchCorners"
            when: mode === 4

            PropertyChanges {
                target: root
                anchors.margins: 0
                anchors.leftMargin: barMargins
                anchors.rightMargin: barMargins
                anchors.topMargin: root.bottomMode ? Rounding.verylarge : 0
                anchors.bottomMargin: root.bottomMode ? 0 : Rounding.verylarge
                radius: 0
                topLeftRadius: !root.bottomMode ? undefined : barRadius
                topRightRadius: !root.bottomMode ? undefined : barRadius
                bottomLeftRadius: !root.bottomMode ? barRadius : undefined
                bottomRightRadius: !root.bottomMode ? barRadius : undefined
            }

            PropertyChanges {
                target: c1
                visible: true
                corner: root.bottomMode ? cornerEnum.bottomLeft : cornerEnum.bottomLeft
                anchors.left: root.right
                anchors.bottom: !root.bottomMode ? undefined : root.bottom
                anchors.top: root.bottomMode ? undefined : root.top
            }

            PropertyChanges {
                target: c2
                visible: true
                corner: root.bottomMode ? cornerEnum.bottomRight : cornerEnum.topRight
                anchors.right: root.left
                anchors.top: root.bottomMode ? root.top : undefined
                anchors.bottom: !root.bottomMode ? undefined : root.bottom
            }

        }
    ]
    transitions: [
        Transition {
            Anim {
                properties: "anchors.margins,anchors.leftMargin,anchors.rightMargin,anchors.topMargin,anchors.bottomMargin,radius,topLeftRadius,topRightRadius,bottomLeftRadius,bottomRightRadius"
            }

            Anim {
                properties: "anchors.leftMargin,anchors.rightMargin,anchors.topMargin,anchors.bottomMargin,opacity"
                targets: [c1, c2]
            }

        }
    ]

    // Content area of bar
    Content {
    }

    // Rounded corner shapes
    RoundCorner {
        id: c1

        color: root.color
        visible: false
    }

    RoundCorner {
        id: c2

        color: root.color
        visible: false
    }

}
