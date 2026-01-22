pragma ComponentBehavior: Bound

import qs.services
import qs.common
import qs.common.widgets
import qs.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import org.kde.syntaxhighlighting

ColumnLayout {
    id: root
    // These are needed on the parent loader
    property bool editing: parent?.editing ?? false
    property bool renderMarkdown: parent?.renderMarkdown ?? true
    property bool enableMouseSelection: parent?.enableMouseSelection ?? false
    property var segmentContent: parent?.segmentContent ?? ({})
    property var segmentLang: parent?.segmentLang ?? "txt"
    property bool isCommandRequest: segmentLang === "command"
    property var displayLang: (isCommandRequest ? "bash" : segmentLang)
    property var messageData: parent?.messageData ?? {}

    property real codeBlockBackgroundRounding: Rounding.small
    property real codeBlockHeaderPadding: 3
    property real codeBlockComponentSpacing: 2

    spacing: codeBlockComponentSpacing
    // anchors.left: parent.left
    // anchors.right: parent.right

    Rectangle {
        // Code background
        Layout.fillWidth: true
        topLeftRadius: codeBlockBackgroundRounding
        topRightRadius: codeBlockBackgroundRounding
        bottomLeftRadius: Rounding.tiny
        bottomRightRadius: Rounding.tiny
        color: Colors.colSurfaceContainerHighest
        implicitHeight: codeBlockTitleBarRowLayout.implicitHeight + codeBlockHeaderPadding * 2

        RowLayout { // Language and buttons
            id: codeBlockTitleBarRowLayout
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: codeBlockHeaderPadding
            anchors.rightMargin: codeBlockHeaderPadding
            spacing: 5

            StyledText {
                id: codeBlockLanguage
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: false
                Layout.topMargin: 7
                Layout.bottomMargin: 7
                Layout.leftMargin: 10
                font.pixelSize: Fonts.sizes.small
                font.weight: Font.DemiBold
                color: Colors.colOnLayer2
                text: root.displayLang ? Repository.definitionForName(root.displayLang).name : "plain"
            }

            Item {
                Layout.fillWidth: true
            }

            ButtonGroup {
                AiMessageControlButton {
                    id: copyCodeButton
                    buttonIcon: activated ? "inventory" : "content_copy"

                    onClicked: {
                        Quickshell.clipboardText = segmentContent;
                        copyCodeButton.activated = true;
                        copyIconTimer.restart();
                    }

                    Timer {
                        id: copyIconTimer
                        interval: 1500
                        repeat: false
                        onTriggered: {
                            copyCodeButton.activated = false;
                        }
                    }
                    StyledToolTip {
                        text: qsTr("Copy code")
                    }
                }
                AiMessageControlButton {
                    id: saveCodeButton
                    buttonIcon: activated ? "check" : "save"

                    onClicked: {
                        const downloadPath = FileUtils.trimFileProtocol(Directories.standard.downloads);
                        NoonUtils.execDetached(`echo '${StringUtils.shellSingleQuoteEscape(segmentContent)}' > '${downloadPath}/code.${segmentLang || "txt"}'`);
                        Quickshell.execDetached(["notify-send", qsTr("Code saved to file"), qsTr("Saved to %1").arg(`${downloadPath}/code.${segmentLang || "txt"}`), "-a", "Shell"]);
                        saveCodeButton.activated = true;
                        saveIconTimer.restart();
                    }

                    Timer {
                        id: saveIconTimer
                        interval: 1500
                        repeat: false
                        onTriggered: {
                            saveCodeButton.activated = false;
                        }
                    }
                    StyledToolTip {
                        text: qsTr("Save to Downloads")
                    }
                }
            }
        }
    }

    RowLayout {
        // Line numbers and code
        spacing: codeBlockComponentSpacing

        Rectangle {
            // Line numbers
            implicitWidth: 40
            implicitHeight: lineNumberColumnLayout.implicitHeight
            Layout.fillHeight: true
            Layout.fillWidth: false
            topLeftRadius: Rounding.tiny
            bottomLeftRadius: codeBlockBackgroundRounding
            topRightRadius: Rounding.tiny
            bottomRightRadius: Rounding.tiny
            color: Colors.colLayer2

            ColumnLayout {
                id: lineNumberColumnLayout
                anchors {
                    left: parent.left
                    right: parent.right
                    rightMargin: 5
                    top: parent.top
                    topMargin: 6
                }
                spacing: 0

                Repeater {
                    model: codeTextArea.text.split("\n").length
                    Text {
                        required property int index
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        font.family: Fonts.family.monospace
                        font.pixelSize: Fonts.sizes.small
                        color: Colors.colSubtext
                        horizontalAlignment: Text.AlignRight
                        text: index + 1
                    }
                }
            }
        }

        Rectangle {
            // Code background
            Layout.fillWidth: true
            topLeftRadius: Rounding.tiny
            bottomLeftRadius: Rounding.tiny
            topRightRadius: Rounding.tiny
            bottomRightRadius: codeBlockBackgroundRounding
            color: Colors.colLayer2
            implicitHeight: codeColumnLayout.implicitHeight

            ColumnLayout {
                id: codeColumnLayout
                anchors.fill: parent
                spacing: 0
                ScrollView {
                    id: codeScrollView
                    Layout.fillWidth: true
                    // Layout.fillHeight: true
                    implicitWidth: parent.width
                    implicitHeight: codeTextArea.implicitHeight + 1
                    contentWidth: codeTextArea.width - 1
                    // contentHeight: codeTextArea.contentHeight
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                    ScrollBar.horizontal: ScrollBar {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        padding: 5
                        policy: ScrollBar.AsNeeded
                        opacity: visualSize == 1 ? 0 : 1
                        visible: opacity > 0

                        Behavior on opacity {
                            FAnim {}
                        }

                        contentItem: Rectangle {
                            implicitHeight: 6
                            radius: Rounding.small
                            color: Colors.colLayer2Active
                        }
                    }

                    TextArea { // Code
                        id: codeTextArea
                        Layout.fillWidth: true
                        readOnly: !editing
                        selectByMouse: enableMouseSelection || editing
                        renderType: Text.NativeRendering
                        font.family: Fonts.family.monospace
                        font.hintingPreference: Font.PreferNoHinting // Prevent weird bold text
                        font.pixelSize: Fonts.sizes.small
                        selectedTextColor: Colors.m3.m3onSecondaryContainer
                        selectionColor: Colors.colSecondaryContainer
                        // wrapMode: TextEdit.Wrap
                        color: messageData.thinking ? Colors.colSubtext : Colors.colOnLayer1

                        text: segmentContent
                        onTextChanged: {
                            segmentContent = text;
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Tab) {
                                // Insert 4 spaces at cursor
                                const cursor = codeTextArea.cursorPosition;
                                codeTextArea.insert(cursor, "    ");
                                codeTextArea.cursorPosition = cursor + 4;
                                event.accepted = true;
                            } else if ((event.key === Qt.Key_C) && event.modifiers == Qt.ControlModifier) {
                                codeTextArea.copy();
                                event.accepted = true;
                            }
                        }

                        SyntaxHighlighter {
                            id: highlighter
                            textEdit: codeTextArea
                            repository: Repository
                            definition: Repository.definitionForName(root.displayLang || "plaintext")
                            theme: Colors.m3.darkmode ? "Monokai" : "ayu Light"
                        }
                    }
                }
                Loader {
                    active: root.isCommandRequest && root.messageData.functionPending
                    visible: active
                    Layout.fillWidth: true
                    Layout.margins: 6
                    Layout.topMargin: 0
                    sourceComponent: RowLayout {
                        Item {
                            Layout.fillWidth: true
                        }
                        ButtonGroup {
                            GroupButton {
                                contentItem: StyledText {
                                    text: qsTr("Reject")
                                    font.pixelSize: Fonts.sizes.small
                                    color: Colors.colOnLayer2
                                }
                                onClicked: Ai.rejectCommand(root.messageData)
                            }
                            GroupButton {
                                toggled: true
                                contentItem: StyledText {
                                    text: qsTr("Approve")
                                    font.pixelSize: Fonts.sizes.small
                                    color: Colors.colOnPrimary
                                }
                                onClicked: Ai.approveCommand(root.messageData)
                            }
                        }
                    }
                }
            }

            // MouseArea to block scrolling
            // MouseArea {
            //     id: codeBlockMouseArea
            //     anchors.fill: parent
            //     acceptedButtons: editing ? Qt.NoButton : Qt.LeftButton
            //     cursorShape: (enableMouseSelection || editing) ? Qt.IBeamCursor : Qt.ArrowCursor
            //     onWheel: (event) => {
            //         event.accepted = false
            //     }
            // }
        }
    }
}
