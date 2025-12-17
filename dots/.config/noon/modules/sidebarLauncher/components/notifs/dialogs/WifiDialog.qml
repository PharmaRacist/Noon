import qs
import qs.services
import qs.services.network
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

SidebarDialog {
    id: root
    WindowDialogTitle {
        text: qsTr("Connect to Wi-Fi")
    }
    WindowDialogSeparator {
        visible: !Network.wifiScanning
    }
    StyledIndeterminateProgressBar {
        visible: Network.wifiScanning
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
            values: [...Network.wifiNetworks].sort((a, b) => {
                if (a.active && !b.active)
                    return -1;
                if (!a.active && b.active)
                    return 1;
                return b.strength - a.strength;
            })
        }
        delegate: WifiNetworkItem {
            required property WifiAccessPoint modelData
            wifiNetwork: modelData
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
                root.show = true
                let app = Network.ethernet ? Mem.options.apps.networkEthernet : Mem.options.apps.network;
                Noon.exec(app);
                Noon.callIpc("sidebar_launcher hide");
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
