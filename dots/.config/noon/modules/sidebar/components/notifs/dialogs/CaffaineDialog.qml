import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services

SidebarDialog {
    id: root

    WindowDialogTitle {
        text: qsTr("Caffaine")
    }

    WindowDialogSeparator {
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Padding.verylarge
        anchors.margins: Rounding.large

        RowLayout {
            Layout.fillWidth: true
            spacing: Padding.normal

            MaterialSymbol {
                text: "coffee"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Awake")
                color: Colors.colOnSurfaceVariant
            }

            StyledSwitch {
                checked: Mem.options.services.idle.inhibit
                onToggled: Mem.options.services.idle.inhibit = checked
            }

        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Padding.normal

            MaterialSymbol {
                text: "timer"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Idle Timeout")
                color: Colors.colOnSurfaceVariant
            }

            MaterialTextField {
                Layout.preferredHeight: 45
                Layout.preferredWidth: 120
                text: Mem.options.services.idle.timeOut
                placeholderText: Mem.options.services.idle.timeOut
                inputMethodHints: Qt.ImhDigitsOnly
                onEditingFinished: {
                    const val = parseInt(text);
                    Mem.options.services.idle.timeOut = val;
                }
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

        DialogButton {
            buttonText: qsTr("Done")
            onClicked: root.dismiss()
        }

    }

}
