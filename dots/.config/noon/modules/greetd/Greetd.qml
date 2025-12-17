import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Greetd
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        StyledPanel {
            id: loginWindow
            required property var modelData
            screen: modelData
            name: "greetd"
            anchors {
                left: true
                top: true
                bottom: true
                right: true
            }

            color: Colors.colScrim
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            StyledRect {
                id: background
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }
                color: Colors.colLayer1
                topRightRadius: Rounding.verylarge
                bottomRightRadius: Rounding.verylarge
                enableShadows: true
                implicitWidth: 450
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GreetdService.cancel();
                    }
                }

                function submit() {
                    if (usernameField.visible && usernameField.text !== "") {
                        usernameField.visible = false;
                        passwordField.visible = true;
                        passwordField.text = "";
                        Qt.callLater(() => passwordField.forceActiveFocus());
                    } else if (passwordField.visible && passwordField.text !== "") {
                        GreetdService.authenticate(usernameField.text, passwordField.text);
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Padding.veryhuge
                    spacing: Padding.veryhuge

                    Spacer {}

                    MaterialShapeWrappedMaterialSymbol {
                        Layout.alignment: Qt.AlignHCenter
                        iconSize: 180
                        text: "lock_person"
                        shape: MaterialShape.Cookie6Sided
                    }

                    WindowDialogTitle {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Login")
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.margins: Padding.huge
                        spacing: Padding.normal

                        WindowDialogParagraph {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            text: usernameField.visible ? qsTr("Enter your username") : qsTr("Enter your password")
                        }

                        MaterialTextField {
                            id: usernameField
                            Layout.fillWidth: true
                            focus: true
                            visible: true
                            placeholderText: qsTr("Username")
                            echoMode: TextInput.Normal
                            onAccepted: background.submit()
                            onVisibleChanged: {
                                if (visible) {
                                    Qt.callLater(() => forceActiveFocus());
                                }
                            }
                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    GreetdService.cancel();
                                }
                            }
                        }

                        MaterialTextField {
                            id: passwordField
                            Layout.fillWidth: true
                            visible: false
                            placeholderText: qsTr("Password")
                            echoMode: TextInput.Password
                            onAccepted: background.submit()
                            onVisibleChanged: {
                                if (visible) {
                                    Qt.callLater(() => forceActiveFocus());
                                }
                            }
                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    GreetdService.cancel();
                                }
                            }
                        }

                        WindowDialogParagraph {
                            id: errorText
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            color: Colors.colError
                            visible: text !== ""
                            text: ""
                        }
                    }

                    Spacer {}

                    WindowDialogButtonRow {
                        Item {
                            Layout.fillWidth: true
                        }

                        DialogButton {
                            buttonText: qsTr("Shutdown")
                            onClicked: GreetdService.shutdown()
                        }

                        DialogButton {
                            buttonText: qsTr("Reboot")
                            onClicked: GreetdService.reboot()
                        }

                        DialogButton {
                            visible: passwordField.visible
                            buttonText: qsTr("Back")
                            onClicked: {
                                passwordField.visible = false;
                                usernameField.visible = true;
                                passwordField.text = "";
                                Qt.callLater(() => usernameField.forceActiveFocus());
                            }
                        }

                        DialogButton {
                            enabled: (usernameField.visible && usernameField.text !== "") || (passwordField.visible && passwordField.text !== "")
                            buttonText: passwordField.visible ? qsTr("Login") : qsTr("Next")
                            onClicked: background.submit()
                        }
                    }
                }
                Connections {
                    target: GreetdService

                    function onAuthenticationSuccess() {
                        errorText.text = "";
                        GreetdService.launchSession(); // Uses default session
                    }

                    function onAuthenticationFailed(error) {
                        errorText.text = error || qsTr("Authentication failed");
                        passwordField.text = "";
                        passwordField.visible = false;
                        usernameField.visible = true;
                        Qt.callLater(() => usernameField.forceActiveFocus());
                    }
                }

                Component.onCompleted: {
                    Qt.callLater(() => usernameField.forceActiveFocus());
                }
            }
        }
    }
}
