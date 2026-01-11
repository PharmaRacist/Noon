import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import qs.common
import qs.services
import qs.common.utils
import qs.common.widgets

BottomDialog {
    id: root
    focus: true
    collapsedHeight: 560
    revealOnWheel: true
    enableStagedReveal: false
    bottomAreaReveal: true
    hoverHeight: 300
    // scrim: false
    colors: GameLauncherService.colors
    property bool sidebarExpanded
    bgAnchors {
        rightMargin: sidebarExpanded ? 100 : Padding.large
        leftMargin: sidebarExpanded ? 100 : Padding.large
    }
    function clearInput() {
        nameInput.text = "";
        pathInput.text = "";
        coverInput.text = "";
        root.show = false;
    }

    contentItem: ColumnLayout {
        anchors.margins: Padding.massive
        spacing: Padding.verylarge
        BottomDialogHeader {
            title: "Add New Game"
            subTitle: "all games run with gamemode"
            colors: root.colors
        }
        BottomDialogSeparator {}
        EntryArea {
            id: nameInput
            name: "Name:"
            placeholder: "Enter Game's Name"
        }

        EntryArea {
            id: descriptionInput
            name: "Description:"
            placeholder: "Enter Game's Description"
        }

        EntryArea {
            id: pathInput
            materialIcon: "folder"
            action: () => {
                executableFileDialog.open();
                Noon.callIpc("sidebar hide");
            }
            name: "Path:"
            placeholder: "/path/to/game.exe or /path/to/game"
        }

        EntryArea {
            id: coverInput
            materialIcon: "image"
            action: () => {
                coverImageFileDialog.open();
                Noon.callIpc("sidebar hide");
            }
            name: "Cover:"
            placeholder: "/path/to/cover.jpg"
        }
        OptionArea {
            id: optimization
            text: "Optimize"
        }
        Spacer {}

        RowLayout {
            Layout.fillWidth: true
            spacing: Padding.large
            BottomControl {
                enabled: nameInput.text.length > 0 && pathInput.text.length > 0
                materialIcon: "delete"
                hint: "Delete"
                releaseAction: () => {
                    GameLauncherService.deleteGame(root.gameData.id);
                }
            }

            Spacer {}
            BottomControl {
                materialIcon: "close"
                hint: "Cancel"
                releaseAction: () => {
                    root.clearInput();
                }
            }
            BottomControl {
                enabled: nameInput.text.length > 0 && pathInput.text.length > 0
                materialIcon: "add"
                hint: "Add"
                releaseAction: () => {
                    if (nameInput.text.length > 1 && pathInput.text.length > 1) {
                        GameLauncherService.addGame(nameInput.text, pathInput.text, coverInput.text, optimization.checked, descriptionInput.text);
                        root.clearInput();
                    }
                }
            }
        }
    }
    FileDialog {
        id: executableFileDialog

        title: "Select Game Executable"
        nameFilters: ["Executable files (*.exe *.AppImage *.sh)", "All files (*)"]
        onAccepted: {
            let filePath = currentFile ? currentFile.toString() : selectedFile.toString();
            pathInput.text = filePath.replace("file://", "");
            Noon.callIpc("sidebar reveal Games");
        }
    }
    FileDialog {
        id: coverImageFileDialog

        title: "Select Cover Image"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.gif *.bmp)", "All files (*)"]
        onAccepted: {
            let filePath = currentFile ? currentFile.toString() : selectedFile.toString();
            coverInput.text = filePath.replace("file://", "");
            Noon.callIpc("sidebar reveal Games");
        }
    }
    component OptionArea: RowLayout {
        property alias text: title.text
        property alias checked: button.checked
        StyledText {
            id: title
            color: root.colors.colOnSurfaceVariant
        }
        Spacer {}
        StyledSwitch {
            id: button
            colors: GameLauncherService.colors
            checked: false
        }
    }

    component BottomControl: RippleButton {
        id: root
        property string hint
        property string materialIcon
        clip: true
        implicitWidth: hovered ? contentItem.implicitWidth + 2 * Padding.huge : implicitHeight
        implicitHeight: 36
        buttonRadius: Rounding.large
        colBackground: colors.colSecondaryContainer
        colors: GameLauncherService.colors
        contentItem: RowLayout {
            spacing: Padding.normal

            Symbol {
                Layout.fillWidth: !root.hovered
                text: root.materialIcon
                color: colors.colOnSecondaryContainer
                font.pixelSize: Fonts.sizes.verylarge
                fill: 1
            }
            StyledText {
                visible: root.hovered
                Layout.fillWidth: true
                text: root.hint
                color: colors.colOnSecondaryContainer
                font.pixelSize: Fonts.sizes.normal
            }
        }
        Behavior on implicitWidth {
            Anim {}
        }
    }
    component EntryArea: ColumnLayout {
        id: root
        required property string name
        property string materialIcon
        property var action
        property alias text: entry.text
        property string placeholder

        Layout.fillWidth: true
        spacing: Padding.normal

        StyledText {
            text: root.name
            color: colors.colOnLayer1
            font.pixelSize: Fonts.sizes.normal
        }
        RowLayout {
            Layout.preferredHeight: 45
            Layout.fillWidth: true
            spacing: Padding.verylarge
            StyledTextField {
                id: entry
                focus: true
                Layout.preferredHeight: 42
                Layout.fillWidth: true
                placeholderText: root.placeholder
                padding: Padding.large
                renderType: Text.NativeRendering
                color: colors.colOnSecondaryContainer
                selectedTextColor: colors.colOnSecondaryContainer
                selectionColor: colors.colSecondaryContainer
                placeholderTextColor: colors.colOnSecondaryContainer

                background: Rectangle {
                    color: colors.colLayer2
                    radius: Rounding.large
                }
            }
            RippleButtonWithIcon {
                colors: GameLauncherService.colors
                visible: materialIcon.length > 0
                materialIcon: root.materialIcon
                implicitSize: 36
                colBackground: colors.colSecondaryContainer
                releaseAction: root.action
            }
        }
    }
}
