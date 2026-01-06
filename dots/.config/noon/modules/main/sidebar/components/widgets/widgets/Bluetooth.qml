import QtQuick
import QtQuick.Layouts
import qs.services
import qs.common
import qs.common.widgets

IslandComponent {
    id: root

    property var currentDevice: BluetoothService.filterConnectedDevices(BluetoothService.pairedDevices)[0]

    ColumnLayout {
        id: columnLayout

        anchors.centerIn: parent
        spacing: Padding.small

        Row {
            id: header

            spacing: Padding.normal

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                fill: 1
                font.weight: Font.Medium
                text: BluetoothService.filterConnectedDevices(BluetoothService.pairedDevices).length > 0 ? BluetoothService.getDeviceIcon(root.currentDevice) : "bluetooth"
                font.pixelSize: Fonts.sizes.large
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentDevice?.name || "No Current Device"
                color: Colors.m3.m3onSurfaceVariant

                font {
                    weight: Font.Medium
                    pixelSize: Fonts.sizes.small
                }
            }

            Spacer {}
        }

        StyledText {
            text: root.currentDevice?.battery ? Math.round(root.currentDevice.battery * 100) + " %" : "100 %"

            font {
                pixelSize: Fonts.sizes.title
                family: Fonts.family.numbers
                variableAxes: Fonts.variableAxes.longNumbers
            }
        }

        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            MaterialSymbol {
                text: BluetoothService.getDeviceStatusIcon(root.currentDevice)
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: {
                    BluetoothService.getDeviceStatus(root.currentDevice);
                }
                color: Colors.m3.m3onSurfaceVariant
            }
        }
    }
}
