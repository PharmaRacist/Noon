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
        text: qsTr("KDE Connect")
    }

    WindowDialogSeparator {}

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 16
        anchors.margins: Rounding.large

        // Connection Status
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MaterialSymbol {
                text: KdeConnectService.availableDevices.length > 0 ? "phonelink" : "phonelink_off"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("%1 device(s) connected").arg(KdeConnectService.availableDevices.length)
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                text: KdeConnectService.isRefreshing ? qsTr("Refreshing...") : ""
                color: Colors.colOnSurfaceVariant
                opacity: 0.7
            }
        }

        WindowDialogSeparator {}

        // Paired Devices Section
        StyledText {
            text: qsTr("Paired Devices")
            color: Colors.colOnSurfaceVariant
            font.pixelSize: Fonts.sizes.small
            opacity: 0.7
        }

        Repeater {
            model: KdeConnectService.devices

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MaterialSymbol {
                    text: {
                        if (KdeConnectService.isDeviceAvailable(modelData.id)) {
                            return "phone_android";  // Online
                        } else {
                            return "phone_disabled";  // Offline
                        }
                    }
                    font.pixelSize: Fonts.sizes.verylarge
                    color: KdeConnectService.isDeviceAvailable(modelData.id) ? Colors.colPrimaryActive : Colors.colOnSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: modelData.name + (KdeConnectService.isDeviceAvailable(modelData.id) ? "" : qsTr(" (offline)"))
                    color: Colors.colOnSurfaceVariant
                    opacity: KdeConnectService.isDeviceAvailable(modelData.id) ? 1.0 : 0.6
                }

                StyledSwitch {
                    checked: modelData.id === KdeConnectService.selectedDeviceId
                    enabled: KdeConnectService.isDeviceAvailable(modelData.id)
                    onToggled: {
                        if (checked) {
                            KdeConnectService.selectDevice(modelData.id);
                        }
                    }
                }
            }
        }

        // Empty state for paired devices
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: KdeConnectService.devices.length === 0

            MaterialSymbol {
                text: "info"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
                opacity: 0.5
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("No paired devices")
                color: Colors.colOnSurfaceVariant
                opacity: 0.7
            }
        }

        WindowDialogSeparator {}

        // Discoverable Devices Section
        StyledText {
            text: qsTr("Available to Pair")
            color: Colors.colOnSurfaceVariant
            font.pixelSize: Fonts.sizes.small
            opacity: 0.7
        }

        Repeater {
            model: KdeConnectService.discoverableDevices

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MaterialSymbol {
                    text: "phone_in_talk"  // New device icon
                    font.pixelSize: Fonts.sizes.verylarge
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: modelData.name
                    color: Colors.colOnSurfaceVariant
                }

                RippleButtonWithIcon {
                    materialIcon: "link"
                    onClicked: KdeConnectService.pairDevice(modelData.id)
                }
            }
        }

        // Empty state for discoverable
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: KdeConnectService.discoverableDevices.length === 0

            MaterialSymbol {
                text: "info"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
                opacity: 0.5
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("No new devices found. Make sure KDE Connect is running and visible on your phone.")
                color: Colors.colOnSurfaceVariant
                opacity: 0.7
                wrapMode: Text.WordWrap
            }
        }

        WindowDialogSeparator {}

        // Quick Actions
        StyledText {
            text: qsTr("Quick Actions")
            color: Colors.colOnSurfaceVariant
            font.pixelSize: Fonts.sizes.small
            opacity: 0.7
            visible: KdeConnectService.selectedDeviceId !== ""
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: KdeConnectService.selectedDeviceId !== ""

            MaterialSymbol {
                text: "notifications_active"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Ring Device")
                color: Colors.colOnSurfaceVariant
            }

            RippleButtonWithIcon {
                materialIcon: "play_arrow"
                onClicked: KdeConnectService.ringDevice()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: KdeConnectService.selectedDeviceId !== ""

            MaterialSymbol {
                text: "notifications"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Send Ping")
                color: Colors.colOnSurfaceVariant
            }

            RippleButtonWithIcon {
                materialIcon: "play_arrow"
                onClicked: KdeConnectService.pingDevice()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: KdeConnectService.selectedDeviceId !== ""

            MaterialSymbol {
                text: "lock"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Lock Device")
                color: Colors.colOnSurfaceVariant
            }

            RippleButtonWithIcon {
                materialIcon: "play_arrow"
                onClicked: KdeConnectService.lockDevice()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: KdeConnectService.selectedDeviceId !== ""

            MaterialSymbol {
                text: "content_paste"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Send Clipboard")
                color: Colors.colOnSurfaceVariant
            }

            RippleButtonWithIcon {
                materialIcon: "play_arrow"
                onClicked: KdeConnectService.sendClipboard()
            }
        }

        WindowDialogSeparator {
            visible: KdeConnectService.selectedDeviceId !== ""
        }

        // Device Management
        StyledText {
            text: qsTr("Device Management")
            color: Colors.colOnSurfaceVariant
            font.pixelSize: Fonts.sizes.small
            opacity: 0.7
            visible: KdeConnectService.selectedDeviceId !== ""
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: KdeConnectService.selectedDeviceId !== ""

            MaterialSymbol {
                text: "link"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Send Media")
                color: Colors.colOnSurfaceVariant
            }

            RippleButtonWithIcon {
                materialIcon: "play_arrow"
                onClicked: {
                    const deviceId = KdeConnectService.selectedDeviceId;
                    KdeConnectService.shareFile(deviceId);
                    Noon.callIpc("sidebar_launcher hide");
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: KdeConnectService.selectedDeviceId !== ""

            MaterialSymbol {
                text: "link_off"
                font.pixelSize: Fonts.sizes.verylarge
                color: Colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Unpair Device")
                color: Colors.colOnSurfaceVariant
            }

            RippleButtonWithIcon {
                materialIcon: "delete"
                onClicked: {
                    const deviceId = KdeConnectService.selectedDeviceId;
                    KdeConnectService.unpairDevice(deviceId);
                    KdeConnectService.selectDevice("");
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    WindowDialogSeparator {}

    WindowDialogButtonRow {
        implicitHeight: 48
        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: qsTr("Refresh")
            onClicked: KdeConnectService.refresh()
        }

        DialogButton {
            buttonText: qsTr("Done")
            onClicked: root.dismiss()
        }
    }
}
