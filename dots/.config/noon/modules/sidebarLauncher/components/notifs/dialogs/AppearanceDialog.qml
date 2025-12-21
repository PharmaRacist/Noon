import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services

SidebarDialog {
    id: root

    WindowDialogTitle {
        text: qsTr("Appearance")
    }

    WindowDialogSeparator {
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 16
        anchors.margins: Rounding.large

        // Shell Mode (Light/Dark)
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MaterialSymbol {
                text: Mem.states.desktop.appearance.mode === "dark" ? "dark_mode" : "light_mode"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Dark Mode")
                color: Colors.colOnSurfaceVariant
            }

            StyledSwitch {
                checked: Mem.states.desktop.appearance.mode === "dark"
                onToggled: {
                    Mem.states.desktop.appearance.mode = checked ? "dark" : "light";
                    WallpaperService.toggleShellMode();
                }
            }

        }

        // Auto Shell Mode
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MaterialSymbol {
                text: "schedule"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Auto Mode (Time-based)")
                color: Colors.colOnSurfaceVariant
            }

            StyledSwitch {
                checked: Mem.states.desktop.appearance.autoShellMode
                onToggled: Mem.states.desktop.appearance.autoShellMode = checked
            }

        }

        WindowDialogSeparator {
        }

        // Auto Scheme Selection
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MaterialSymbol {
                text: "auto_awesome"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Auto Color Scheme")
                color: Colors.colOnSurfaceVariant
            }

            StyledSwitch {
                checked: Mem.states.desktop.appearance.autoSchemeSelection
                onToggled: Mem.states.desktop.appearance.autoSchemeSelection = checked
            }

        }

        WindowDialogSeparator {
        }

        // Chroma Slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                MaterialSymbol {
                    text: "colorize"
                    font.pixelSize: Fonts.sizes.verylarge
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Color Intensity (Chroma)")
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    text: Math.round(Mem.states.desktop.Colors.chroma * 100) + "%"
                    color: Colors.colOnSurfaceVariant
                    opacity: 0.7
                }

            }

            StyledSlider {
                Layout.fillWidth: true
                from: 0
                to: 2
                value: Mem.states.desktop.Colors.chroma
                onMoved: Mem.states.desktop.Colors.chroma = value
            }

        }

        // Tone Slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                MaterialSymbol {
                    text: "contrast"
                    font.pixelSize: Fonts.sizes.verylarge
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Tone Adjustment")
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    text: Math.round(Mem.states.desktop.Colors.tone * 100) + "%"
                    color: Colors.colOnSurfaceVariant
                    opacity: 0.7
                }

            }

            StyledSlider {
                Layout.fillWidth: true
                from: 0
                to: 2
                value: Mem.states.desktop.Colors.tone
                onMoved: Mem.states.desktop.Colors.tone = value
            }

        }

        Item {
            Layout.fillHeight: true
        }

    }

    WindowDialogSeparator {
    }

    WindowDialogButtonRow {
        implicitHeight: 48

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: qsTr("Pick Accent Color")
            onClicked: WallpaperService.pickAccentColor()
        }

        DialogButton {
            buttonText: qsTr("Done")
            onClicked: root.dismiss()
        }

    }

}
