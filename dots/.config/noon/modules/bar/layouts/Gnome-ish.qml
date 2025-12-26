import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs.common
import qs.common.widgets
import qs.modules.bar.components
import qs.services

Rectangle {
    id: barBackground

    property var barRoot
    readonly property int mode: Mem.options.bar.appearance.mode
    readonly property bool bottomMode: Mem.options.bar.behavior.position === "bottom"
    readonly property bool centerNotch: true

    anchors.fill: parent
    implicitHeight: 35
    color: "transparent"

    GnomeWs {
        bar: barRoot

        anchors {
            left: parent.left
            leftMargin: Padding.huge
        }

    }

    RoundCorner {
        size: Rounding.normal
        corner: !bottomMode ? cornerEnum.topRight : cornerEnum.bottomRight
        color: Colors.colLayer0
        visible: centerNotch

        anchors {
            top: bottomMode ? undefined : centerNotchBg.top
            bottom: !bottomMode ? undefined : centerNotchBg.bottom
            right: centerNotchBg.left
        }

    }

    RoundCorner {
        size: Rounding.normal
        corner: !bottomMode ? cornerEnum.topLeft : cornerEnum.bottomLeft
        color: Colors.colLayer0
        visible: centerNotch

        anchors {
            top: bottomMode ? undefined : centerNotchBg.top
            bottom: !bottomMode ? undefined : centerNotchBg.bottom
            left: centerNotchBg.right
        }

    }

    Rectangle {
        id: centerNotchBg

        color: centerNotch ? Colors.colLayer0 : "transparent"
        anchors.top: parent.top
        topLeftRadius: bottomMode ? Rounding.verylarge : 0
        topRightRadius: bottomMode ? Rounding.verylarge : 0
        bottomLeftRadius: bottomMode ? 0 : Rounding.verylarge
        bottomRightRadius: bottomMode ? 0 : Rounding.verylarge
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height - anchors.topMargin
        width: centerContent.width + 36

        RowLayout {
            id: centerContent

            anchors.centerIn: parent
            spacing: 20

            Logo {
            }

            GnomeClock {
            }

            StyledText {
                text: WeatherService.weatherData.currentTemp + "  &  " + WeatherService.weatherData.currentCondition
                font.family: "Rubik"
                font.pixelSize: Fonts.sizes.normal
                color: Colors.m3.m3onSurfaceVariant
            }

        }

    }

    RowLayout {
        spacing: 10

        anchors {
            right: parent.right
            rightMargin: Padding.huge
            verticalCenter: parent.verticalCenter
        }

        SysTray {
            bar: barRoot
        }

        SystemBattery {
        }

        SystemStatusIcons {
            id: statusIcons
        }

    }

}
