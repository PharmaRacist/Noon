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
        text: qsTr("Transparency")
    }

    WindowDialogSeparator {}

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 16
        anchors.margins: Rounding.large

        //
        // --- Toggle: Enable Transparency
        //
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MaterialSymbol {
                text: "opacity"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Enable Transparency")
                color: Colors.colOnSurfaceVariant
            }

            StyledSwitch {
                checked: Mem.options.appearance.transparency.enabled
                onToggled: Mem.options.appearance.transparency.enabled = checked
            }
        }

        //
        // --- Toggle: Blur Background
        //
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MaterialSymbol {
                text: "blur_on"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Blur Background")
                color: Colors.colOnSurfaceVariant
            }

            StyledSwitch {
                checked: Mem.options.appearance.transparency.blur
                onToggled: Mem.options.appearance.transparency.blur = checked
                enabled: Mem.options.appearance.transparency
            }
        }

        //
        // --- Slider: Transparency Amount
        //
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                MaterialSymbol {
                    text: "tune"
                    font.pixelSize: Fonts.sizes.verylarge
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Transparency Amount")
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    text: (Mem.options.appearance.transparency.scale).toFixed(2) + "%"
                    color: Colors.colOnSurfaceVariant
                    opacity: 0.7
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                from: 0
                to: 1
                value: Mem.options.appearance.transparency.scale
                onMoved: Mem.options.appearance.transparency.scale = value
            }
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
