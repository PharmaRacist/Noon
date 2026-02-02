import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

BarGroup {
    id: root

    implicitWidth: 80
    implicitHeight: 80

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        BatteryPopup {
            id: batteryPopup
            active: mouseArea.containsMouse
            hoverTarget: mouseArea
        }
    }

    ClippedProgressBar {
        id: batteryProgress
        anchors.margins: Padding.small
        anchors.fill: parent
        vertical: root.verticalMode

        value: BatteryService.percentage
        trackColor: Colors.colLayer3
        highlightColor: (BatteryService.percentage <= Mem.options.battery.low / 100 && !BatteryService.isCharging) ? Colors.m3.m3error : Colors.colPrimary

        Item {
            anchors.centerIn: parent
            width: batteryProgress.valueBarWidth
            height: batteryProgress.valueBarHeight

            RowLayout {
                anchors.centerIn: parent
                spacing: Padding.small

                Symbol {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: -2
                    Layout.rightMargin: -2
                    color: Colors.colOnPrimary
                    fill: 1
                    text: "bolt"
                    font.pixelSize: Fonts.sizes.small
                    visible: BatteryService.isCharging && BatteryService.percentage < 1
                }

                StyledText {
                    visible: !root.vertical
                    color: Colors.colOnPrimary
                    Layout.alignment: Qt.AlignVCenter
                    font.pixelSize: Fonts.sizes.small
                    text: Math.round(BatteryService.percentage * 100)
                }
            }
        }
    }
}
