import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.modules.main.bar.components
import qs.store

StyledRect {
    id: barBackground

    property var barRoot
    property int commonSpacing: 8
    property bool bottomMode: Mem.options.bar.behavior.position === "bottom"
    readonly property bool shouldShow: Screen.width > 1080 ?? false
    readonly property int barRadius: Mem.options.bar.appearance.radius
    readonly property int mode: Mem.options.bar.appearance.mode

    enableShadows: true
    enableBorders: true
    radius: barRadius
    color: ColorUtils.transparentize(Colors.m3.m3background, 0.7)
    states: [
        State {
            name: "floating"
            when: mode === 0

            PropertyChanges {
                target: barBackground.anchors
                topMargin: Sizes.elevationMargin
                bottomMargin: Sizes.elevationMargin
            }

            PropertyChanges {
                target: barBackground
                topMargin: Sizes.elevationMargin
                bottomMargin: Sizes.elevationMargin
                topRightRadius: barBackground.barRadius
                topLeftRadius: barBackground.barRadius
                bottomRightRadius: barBackground.barRadius
                bottomLeftRadius: barBackground.barRadius
            }

        },
        State {
            name: "notched"
            when: mode === 1

            PropertyChanges {
                target: barBackground.anchors
                topMargin: barBackground.bottomMode ? Sizes.elevationMargin : 0
                bottomMargin: !barBackground.bottomMode ? Sizes.elevationMargin : 0
            }

            PropertyChanges {
                target: barBackground
                topRightRadius: barBackground.bottomMode ? barBackground.barRadius : 0
                topLeftRadius: barBackground.bottomMode ? barBackground.barRadius : 0
                bottomRightRadius: !barBackground.bottomMode ? barBackground.barRadius : 0
                bottomLeftRadius: !barBackground.bottomMode ? barBackground.barRadius : 0
            }

        }
    ]

    Visualizer {
        anchors.leftMargin: Padding.normal
        anchors.rightMargin: Padding.normal
        active: Mem.options.bar.modules.visualizer
    }

    RowLayout {
        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Padding.normal
        anchors.leftMargin: Padding.normal

        TimeWidget {
            id: clock

            onReveal: revealer.reveal = !revealer.reveal
            showDate: false
        }

        Revealer {
            id: revealer

            reveal: false

            TimeWidget {
                showTime: false
            }

        }

        Spacer {
        }

        UnicodeWs {
            bar: barRoot
            Layout.alignment: Qt.AlignCenter
        }

        Spacer {
        }

        BatteryIndicator {
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 10
        }

        StatusIcons {
        }

    }

    anchors {
        rightMargin: 540
        leftMargin: 540
        fill: parent
        topMargin: Sizes.elevationMargin
        bottomMargin: Sizes.elevationMargin
    }

    component TimeWidget: RippleButton {
        property alias showDate: clock.showDate
        property alias showTime: clock.showTime

        signal reveal()

        clip: true
        releaseAction: () => {
            return reveal();
        }

        contentItem: StackedClockWidget {
            id: clock

            timeFont: Mem.options.desktop.clock.font
            fontScale: 2
            anchors.centerIn: parent
        }

    }

}
