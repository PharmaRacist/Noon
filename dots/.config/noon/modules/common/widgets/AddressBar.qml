import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Rectangle {
    id: root
    required property var directory
    property bool showBreadcrumb: true
    onShowBreadcrumbChanged: {
        addressInput.text = root.directory;
    }

    signal navigateToDirectory(string path)

    property real padding: 6
    implicitWidth: mainLayout.implicitWidth + padding * 2
    implicitHeight: mainLayout.implicitHeight + padding * 2
    color: Colors.colLayer2

    function focusBreadcrumb() {
        root.showBreadcrumb = false;
        addressInput.forceActiveFocus();
    }

    RowLayout {
        id: mainLayout
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: 8

        RippleButton {
            id: parentDirButton
            downAction: () => root.navigateToDirectory(FileUtils.parentDirectory(root.directory))
            contentItem: MaterialSymbol {
                text: "drive_folder_upload"
                iconSize: Fonts.sizes.verylarge
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: directoryEntry
                visible: !root.showBreadcrumb
                anchors.fill: parent
                color: Colors.colLayer1
                radius: Rounding.full
                implicitWidth: addressInput.implicitWidth
                implicitHeight: addressInput.implicitHeight

                Keys.onPressed: event => {
                    if (directoryEntry.visible && event.key === Qt.Key_Escape) {
                        root.showBreadcrumb = true;
                        event.accepted = true;
                        return;
                    }
                    event.accepted = false;
                }

                StyledTextInput {
                    id: addressInput
                    anchors.fill: parent
                    padding: 10
                    text: root.directory

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.navigateToDirectory(text);
                            root.showBreadcrumb = true;
                            event.accepted = true;
                        }
                    }

                    MouseArea {
                        // I-beam cursor
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                    }
                }
            }

            Loader {
                id: breadcrumbLoader
                active: root.showBreadcrumb
                visible: root.showBreadcrumb
                anchors.fill: parent
                sourceComponent: AddressBreadcrumb {
                    directory: root.directory
                    onNavigateToDirectory: dir => {
                        root.navigateToDirectory(dir);
                    }
                }
            }
        }

        RippleButton {
            id: dirEditButton
            toggled: !root.showBreadcrumb
            downAction: () => root.showBreadcrumb = !root.showBreadcrumb
            contentItem: MaterialSymbol {
                text: "edit"
                iconSize: Fonts.sizes.verylarge
                color: dirEditButton.toggled ? Colors.colOnPrimary : Colors.colOnLayer2
            }

            StyledToolTip {
                text: qsTr("Edit directory")
            }
        }
    }
}
