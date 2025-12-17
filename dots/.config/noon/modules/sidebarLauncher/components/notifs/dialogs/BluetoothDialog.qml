import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

SidebarDialog {
    id: root

    WindowDialogTitle {
        text: qsTr("Bluetooth devices")
    }
    WindowDialogSeparator {
        visible: !(Bluetooth.defaultAdapter?.discovering ?? false)
    }
    StyledIndeterminateProgressBar {
        visible: Bluetooth.defaultAdapter?.discovering ?? false
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Rounding.large
        Layout.rightMargin: -Rounding.large
    }
    StyledListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Rounding.large
        Layout.rightMargin: -Rounding.large

        clip: true
        spacing: 0

        model: ScriptModel {
            values: [...Bluetooth.devices.values].sort((a, b) => {
                // Connected -> paired -> others
                let conn = (b.connected - a.connected) || (b.paired - a.paired);
                if (conn !== 0)
                    return conn;

                // Ones with meaningful names before MAC addresses
                const macRegex = /^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$/;
                const aIsMac = macRegex.test(a.name);
                const bIsMac = macRegex.test(b.name);
                if (aIsMac !== bIsMac)
                    return aIsMac ? 1 : -1;

                // Alphabetical by name
                return a.name.localeCompare(b.name);
            })
        }
        delegate: BluetoothDeviceItem {
            required property BluetoothDevice modelData
            device: modelData
            anchors {
                left: parent?.left
                right: parent?.right
            }
        }
    }
    WindowDialogSeparator {}
    WindowDialogButtonRow {
        DialogButton {
            buttonText: qsTr("Details")
            onClicked: {
                Noon.exec(Mem.options.apps.bluetooth);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: qsTr("Done")
            onClicked: root.dismiss()
        }
    }
}
