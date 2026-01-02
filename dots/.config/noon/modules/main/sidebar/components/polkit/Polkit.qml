import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.common
import qs.common.widgets

StyledRect {
    id: root
    readonly property bool usePasswordChars: !PolkitService.flow?.responseVisible ?? true

    signal searchFocusRequested

    onSearchFocusRequested: {
        Qt.callLater(() => inputField.forceActiveFocus());
    }

    anchors.fill: parent
    color: Colors.colLayer1
    radius: Rounding.verylarge

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            PolkitService.cancel();
        }
    }

    function submit() {
        PolkitService.submit(inputField.text);
    }

    Connections {
        target: PolkitService
        function onInteractionAvailableChanged() {
            if (!PolkitService.interactionAvailable)
                return;
            inputField.text = "";
            Qt.callLater(() => inputField.forceActiveFocus());
        }

        function onFlowChanged() {
            if (PolkitService.flow !== null) {
                Qt.callLater(() => {
                    Qt.callLater(() => inputField.forceActiveFocus());
                });
            }
        }
    }

    Component.onCompleted: {
        if (PolkitService.interactionAvailable) {
            Qt.callLater(() => inputField.forceActiveFocus());
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
            text: "security"
            shape: MaterialShape.Cookie6Sided
        }

        WindowDialogTitle {
            id: titleText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Authentication")
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Padding.huge
            spacing: Padding.normal

            WindowDialogParagraph {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                text: {
                    if (!PolkitService.flow)
                        return "";
                    return PolkitService.flow.message.endsWith(".") ? PolkitService.flow.message.slice(0, -1) : PolkitService.flow.message;
                }
            }

            MaterialTextField {
                id: inputField
                Layout.fillWidth: true
                focus: true
                enabled: PolkitService.interactionAvailable
                placeholderText: {
                    const inputPrompt = PolkitService.flow?.inputPrompt.trim() ?? "";
                    const cleanedInputPrompt = inputPrompt.endsWith(":") ? inputPrompt.slice(0, -1) : inputPrompt;
                    return cleanedInputPrompt || (root.usePasswordChars ? qsTr("Password") : qsTr("Input"));
                }
                echoMode: root.usePasswordChars ? TextInput.Password : TextInput.Normal
                onAccepted: root.submit()

                onVisibleChanged: {
                    if (visible && enabled) {
                        Qt.callLater(() => forceActiveFocus());
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        PolkitService.cancel();
                    }
                }
            }
        }

        Spacer {}

        WindowDialogButtonRow {
            Item {
                Layout.fillWidth: true
            }
            DialogButton {
                buttonText: qsTr("Cancel")
                onClicked: PolkitService.cancel()
            }
            DialogButton {
                enabled: PolkitService.interactionAvailable
                buttonText: qsTr("OK")
                onClicked: root.submit()
            }
        }
    }
}
