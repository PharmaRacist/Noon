import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

BottomDialog {
    id: root

    collapsedHeight: parent.height * 0.5
    color: Colors.colLayer1
    Component.onCompleted: KdeConnectService.refresh()

    bgAnchors {
        rightMargin: Padding.large
        leftMargin: Padding.large
    }
    contentItem: Item {
        anchors.fill: parent
        anchors.margins: Padding.normal

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Padding.large
            spacing: Padding.large

            BottomDialogHeader {
                title: "Phone Actions"
                subTitle: KdeConnectService.devices.filter(d => d.state !== KdeConnectService.State.Unreachable).length + " Devices Available"
                target: root
            }

            DevicesSection {}
            BottomDialogSeparator {}

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Padding.small
                visible: KdeConnectService.selectedDeviceId !== ""

                StyledText {
                    text: qsTr("Quick Actions")
                    color: Colors.colOnSurfaceVariant
                    font.pixelSize: Fonts.sizes.small
                    opacity: 0.7
                }

                Repeater {
                    model: [
                        {
                            "icon": "notifications_active",
                            "text": qsTr("Ring Device"),
                            "action": () => KdeConnectService.ringDevice()
                        },
                        {
                            "icon": "content_paste",
                            "text": qsTr("Send Clipboard"),
                            "action": () => KdeConnectService.sendClipboard()
                        }
                    ]

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Padding.small

                        Symbol {
                            text: modelData.icon
                            font.pixelSize: Fonts.sizes.verylarge
                            color: Colors.colOnSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.text
                            color: Colors.colOnSurfaceVariant
                        }

                        RippleButtonWithIcon {
                            materialIcon: "play_arrow"
                            onClicked: modelData.action()
                        }
                    }
                }

                BottomDialogSeparator {}

                StyledText {
                    text: qsTr("Device Management")
                    color: Colors.colOnSurfaceVariant
                    font.pixelSize: Fonts.sizes.small
                    opacity: 0.7
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Padding.small

                    Symbol {
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
                            KdeConnectService.shareFile();
                            NoonUtils.callIpc("sidebar hide");
                        }
                    }
                }
            }

            Spacer {}

            RowLayout {
                Layout.preferredHeight: 50
                Layout.fillWidth: true

                Spacer {}

                DialogButton {
                    buttonText: qsTr("Refresh")
                    onClicked: KdeConnectService.refresh()
                }

                DialogButton {
                    buttonText: qsTr("Done")
                    onClicked: root.show = false
                }
            }
        }
    }

    component DevicesSection: ColumnLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true

        StyledText {
            text: "Devices"
            color: Colors.colOnSurfaceVariant
            font.pixelSize: Fonts.sizes.small
            opacity: 0.7
        }

        Repeater {
            model: KdeConnectService.devices

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: Padding.small

                readonly property bool reachable: modelData.state !== KdeConnectService.State.Unreachable
                readonly property bool paired: modelData.state === KdeConnectService.State.Paired

                Symbol {
                    text: reachable ? "phone_android" : "phone_disabled"
                    font.pixelSize: Fonts.sizes.verylarge
                    color: paired ? Colors.colPrimaryActive : Colors.colOnSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: modelData.name + (reachable ? "" : qsTr(" (offline)"))
                    color: Colors.colOnSurfaceVariant
                    opacity: reachable ? 1 : 0.6
                }

                RippleButtonWithIcon {
                    materialIcon: modelData.paired ? "delete" : "link"
                    releaseAction: () => {
                        if (modelData.paired) {
                            KdeConnectService.unpairDevice(KdeConnectService.selectedDeviceId);
                            KdeConnectService.selectDevice("");
                        } else {
                            KdeConnectService.pairDevice(modelData.id);
                        }
                    }
                }
            }
        }
    }
}
