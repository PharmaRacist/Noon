import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services

SidebarDialog {
    id: root

    WindowDialogTitle {
        text: qsTr("Nightlight")
    }

    WindowDialogSeparator {}

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 16
        anchors.margins: Rounding.large

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MaterialSymbol {
                text: "nightlight"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Enable Nightlight")
                color: Colors.colOnSurfaceVariant
            }

            StyledSwitch {
                checked: NightLightService.enabled
                onToggled: NightLightService.enabled = checked
            }
        }

        RowLayout {
            Layout.fillWidth: true

            MaterialSymbol {
                text: "night_sight_auto"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }
            StyledText {
                Layout.fillWidth: true
                text: qsTr("Auto")
                color: Colors.colOnSurfaceVariant
            }
            StyledSwitch {
                checked: Mem.options.services.time.autoNightLightCycle
                onToggled: Mem.options.services.time.autoNightLightCycle = checked
            }
        }

        RowLayout {
            Layout.fillWidth: true

            MaterialSymbol {
                text: "nightlight"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Temperature")
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                text: NightLightService.temperature + "K"
                color: Colors.colOnSurfaceVariant
                opacity: 0.7
            }
        }

        StyledSlider {
            Layout.fillWidth: true
            from: 3000
            to: 6500
            value: NightLightService.temperature
            enabled: NightLightService.temperature
            onMoved: NightLightService.temperature = value
            enableTooltip: false
        }

        Item {
            Layout.fillHeight: true
        }
    }

    WindowDialogSeparator {}

    WindowDialogButtonRow {
        implicitHeight: 48

        DialogButton {
            buttonText: qsTr("Done")
            onClicked: root.dismiss()
        }
    }
}
