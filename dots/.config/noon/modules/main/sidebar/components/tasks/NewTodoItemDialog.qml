import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

BottomDialog {
    id: root
    collapsedHeight: 360
    enableStagedReveal: false
    bottomAreaReveal: true
    hoverHeight: 300
    color: Colors.colLayer2
    property int _pendingTaskStatus: -1

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Padding.large
        anchors.rightMargin: Padding.massive * 1.5
        anchors.leftMargin: Padding.massive * 1.5
        spacing: Padding.normal
        StyledText {
            text: "New Task"
            font {
                pixelSize: Fonts.sizes.subTitle
                variableAxes: Fonts.variableAxes.title
            }
            Layout.topMargin: Padding.massive
            color: Colors.colOnLayer3
        }
        RLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            StyledText {
                Layout.preferredWidth: 100
                color: Colors.colOnLayer3
                text: "Name: "
            }

            MaterialTextField {
                id: inputArea
                Layout.fillWidth: true
            }
        }

        RLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            StyledText {
                Layout.preferredWidth: 100
                color: Colors.colOnLayer3
                text: "Due: "
            }

            MaterialTextField {
                id: dateInputArea
                Layout.fillWidth: true
            }
        }

        RLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            StyledText {
                text: "Progress: "
                color: Colors.colOnLayer3
                Layout.fillWidth: true
            }

            StyledComboBox {
                implicitHeight: 45
                currentIndex: 0
                model: ["New", "In Progress", "FinalTouches"]
                onActivated: index => {
                    if (index >= 0 && index < model.length && inputArea.text.length > 0) {
                        root._pendingTaskStatus = index;
                    }
                }
            }
        }
        Spacer {}
        RLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            Item {
                Layout.fillWidth: true
            }

            DialogButton {
                buttonText: "Cancel"
                onClicked: {
                    root.show = false;
                }
            }
            DialogButton {
                buttonText: "OK"
                onClicked: {
                    if (inputArea.text.length > 0) {
                        TodoService.addTask(inputArea.text, root._pendingTaskStatus, dateInputArea.text);
                        clear();
                        root.show = false;
                    }
                }
            }
        }
    }
    function clear() {
        root._pendingTaskStatus = -1;
        inputArea.text = "";
    }
}
