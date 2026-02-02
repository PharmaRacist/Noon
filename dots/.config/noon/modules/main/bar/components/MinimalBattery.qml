import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.common
import qs.common.widgets

Item {
    id: root

    width: 26
    height: 26

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true

        BatteryPopup {
            id: batteryPopup
            hoverTarget: mouse
        }
    }

    CircularProgress {
        anchors.centerIn: parent
        size: 26
        lineWidth: 2

        value: UPower.displayDevice.percentage

        readonly property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging
        readonly property bool isLow: value <= (Mem.options.bar.batteryLowThreshold / 100)

        fill: isLow && !isCharging

        primaryColor: (isLow && !isCharging) ? (Colors.m3.darkmode ? Colors.m3.m3errorContainer : Colors.m3.m3error) : Colors.m3.m3onSecondaryContainer
        secondaryColor: (isLow && !isCharging) ? (Colors.m3.darkmode ? Colors.m3.m3error : Colors.m3.m3errorContainer) : Colors.m3.m3secondaryContainer
        Symbol {
            anchors.centerIn: parent
            text: "bolt"
            font.pixelSize: Fonts.sizes.normal
            color: Colors.m3.m3onSecondaryContainer
            visible: parent.isCharging
        }

        Item {
            anchors.centerIn: parent
            visible: !parent.isCharging
            width: parent.width
            height: parent.height

            StyledText {
                anchors.centerIn: parent
                color: Colors.colOnLayer1
                text: `${Math.round(UPower.displayDevice.percentage * 100)}`
                font.pixelSize: Fonts.sizes.normal - 3.6
                visible: Math.round(UPower.displayDevice.percentage * 100) < 100
            }

            Symbol {
                anchors.centerIn: parent
                text: "battery_full"
                font.pixelSize: Fonts.sizes.normal
                color: Colors.colOnLayer1
                visible: Math.round(UPower.displayDevice.percentage * 100) >= 100
            }
        }
    }
}
