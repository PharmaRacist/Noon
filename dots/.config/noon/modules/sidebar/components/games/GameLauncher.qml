import Qt5Compat.GraphicalEffects
// GameLauncher.qml - Main UI Component with File Dialog
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root

    property string searchQuery: ""
    property bool sidebarMode: false

    signal gameStarted()

    Rectangle {
        id: gameLauncher

        color: "transparent" //Colors.colLayer0
        anchors.fill: parent

        FileDialog {
            id: executableFileDialog

            title: "Select Game Executable"
            nameFilters: ["Executable files (*.exe *.AppImage *.sh)", "All files (*)"]
            onAccepted: {
                // Fix: Use currentFile instead of selectedFile for Qt6/newer versions
                let filePath = currentFile ? currentFile.toString() : selectedFile.toString();
                pathInput.text = filePath.replace("file://", "");
            }
        }

        FileDialog {
            id: coverImageFileDialog

            title: "Select Cover Image"
            nameFilters: ["Image files (*.jpg *.jpeg *.png *.gif *.bmp)", "All files (*)"]
            onAccepted: {
                // Fix: Use currentFile instead of selectedFile for Qt6/newer versions
                let filePath = currentFile ? currentFile.toString() : selectedFile.toString();
                coverInput.text = filePath.replace("file://", "");
            }
        }

        StyledText {
            visible: true
            font.pixelSize: 600
            text: "stadia_controller"
            font.family: Fonts.family.iconMaterial
            color: Colors.m3.m3secondaryContainer
            opacity: 0.2

            anchors {
                bottomMargin: -600
                right: parent.right
                bottom: parent.bottom
            }

            transform: Rotation {
                angle: -45
            }

        }

        RippleButton {
            z: 1
            implicitWidth: 45
            implicitHeight: 45
            buttonRadius: Rounding.small
            colBackground: Colors.colPrimary
            onPressed: addGameDialog.open()

            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: 15
            }

            contentItem: MaterialSymbol {
                text: "add"
                font.pixelSize: 32
                fill: 1
                color: Colors.colOnPrimary
                horizontalAlignment: Text.AlignHCenter
            }

        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // Search bar
            Rectangle {
                visible: !root.sidebarMode
                radius: Rounding.full
                color: Colors.colLayer2
                implicitHeight: 40
                implicitWidth: 350
                Layout.alignment: Qt.AlignHCenter
                z: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 20

                    MaterialSymbol {
                        text: "search"
                        font.pixelSize: 20
                        color: Colors.colSubtext
                    }

                    TextInput {
                        id: searchInput

                        Layout.fillWidth: true
                        font.pixelSize: Fonts.sizes.normal
                        color: Colors.colOnLayer1
                        onTextChanged: searchQuery = text

                        StyledText {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Search games..."
                            color: Colors.colSubtext
                            font: parent.font
                            visible: parent.text.length === 0
                        }

                    }

                }

            }

            // Games grid
            GridView {
                id: gamesGrid

                Layout.fillWidth: true
                Layout.fillHeight: true
                model: searchQuery.length > 0 ? GameLauncherService.searchGames(searchQuery) : GameLauncherService.gamesList
                cellWidth: 225
                cellHeight: 380
                // Enable smooth click and drag scrolling like wallpaper selector
                clip: true
                boundsBehavior: Flickable.DragAndOvershootBounds
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                flickDeceleration: 1500
                maximumFlickVelocity: 2500
                // Performance optimizations
                cacheBuffer: Math.min(500, cellHeight * 3)
                displayMarginBeginning: cellHeight
                displayMarginEnd: cellHeight
                reuseItems: true

                delegate: Rectangle {
                    property var gameData: modelData

                    width: gamesGrid.cellWidth - 10
                    height: gamesGrid.cellHeight - 10
                    radius: Rounding.large
                    color: Colors.colLayer1

                    StyledRectangularShadow {
                        target: parent
                        radius: parent.radius
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        // Game cover image
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            radius: Rounding.large
                            color: Colors.colLayer2

                            Image {
                                id: coverImage

                                anchors.fill: parent
                                // Fix: Better image source handling
                                source: gameData.coverImage && gameData.coverImage !== "" ? (gameData.coverImage.startsWith("file://") ? gameData.coverImage : "file://" + gameData.coverImage) : ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                                cache: false // Disable cache to ensure fresh loading
                                layer.enabled: true

                                layer.effect: OpacityMask {

                                    maskSource: Rectangle {
                                        width: coverImage.width
                                        height: coverImage.height
                                        radius: Rounding.large
                                    }

                                }

                            }

                            // Fallback icon when no cover image or image failed to load
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: gameData.useWine ? "wine_bar" : "sports_esports"
                                font.pixelSize: 48
                                color: Colors.colOnLayer0
                                visible: !gameData.coverImage || gameData.coverImage === "" || coverImage.status === Image.Error
                            }

                        }

                        // Game info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            StyledText {
                                text: gameData.name
                                font.pixelSize: Fonts.sizes.verylarge
                                font.weight: Font.Medium
                                color: Colors.colOnLayer1
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            StyledText {
                                visible: false
                                text: GameLauncherService.statusNames[gameData.status]
                                font.pixelSize: Fonts.sizes.small
                                color: Colors.colSubtext
                            }

                            StyledText {
                                text: gameData.useWine ? "Wine" : "Native"
                                font.pixelSize: Fonts.sizes.small
                                color: gameData.useWine ? Colors.colSecondary : Colors.colPrimary
                            }

                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        // Action buttons
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            RippleButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 35
                                buttonRadius: Rounding.small
                                colBackground: Colors.colPrimary
                                onPressed: {
                                    root.gameStarted();
                                    GameLauncherService.launchGame(gameData.id);
                                }

                                contentItem: StyledText {
                                    text: "Play"
                                    color: Colors.colOnPrimary
                                    horizontalAlignment: Text.AlignHCenter
                                }

                            }

                            RippleButton {
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 35
                                buttonRadius: Rounding.small
                                colBackground: Colors.colSecondaryContainer
                                onPressed: {
                                    deleteConfirmDialog.gameToDelete = gameData;
                                    deleteConfirmDialog.open();
                                }

                                contentItem: MaterialSymbol {
                                    text: "delete"
                                    font.pixelSize: 18
                                    color: Colors.colOnSecondaryContainer
                                }

                            }

                        }

                    }

                }

            }

        }

        // Delete Confirmation Dialog
        Dialog {
            id: deleteConfirmDialog

            property var gameToDelete: null

            anchors.centerIn: parent
            width: 400
            height: 400

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                MaterialSymbol {
                    text: "warning"
                    font.pixelSize: 48
                    color: Colors.colSecondary
                    Layout.alignment: Qt.AlignHCenter
                }

                StyledText {
                    text: "Delete Game"
                    font.pixelSize: Fonts.sizes.title
                    color: Colors.colOnLayer1
                    Layout.alignment: Qt.AlignHCenter
                }

                StyledText {
                    text: deleteConfirmDialog.gameToDelete ? `Are you sure you want to delete "${deleteConfirmDialog.gameToDelete.name}"?` : "Are you sure you want to delete this game?"
                    font.pixelSize: Fonts.sizes.normal
                    color: Colors.colOnLayer1
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Item {
                    Layout.fillHeight: true
                }

                // Dialog buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    RippleButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        buttonRadius: Rounding.small
                        colBackground: Colors.colSecondaryContainer
                        onPressed: deleteConfirmDialog.close()

                        contentItem: StyledText {
                            text: "Cancel"
                            color: Colors.colOnSecondaryContainer
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                    RippleButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        buttonRadius: Rounding.small
                        colBackground: Colors.colSecondary
                        onPressed: {
                            if (deleteConfirmDialog.gameToDelete)
                                GameLauncherService.deleteGame(deleteConfirmDialog.gameToDelete.id);

                            deleteConfirmDialog.close();
                        }

                        contentItem: StyledText {
                            text: "Delete"
                            color: Colors.colSecondary
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                }

            }

            background: Rectangle {
                color: Colors.colLayer1
                radius: Rounding.large
            }

        }

        // Add Game Dialog
        Dialog {
            id: addGameDialog

            anchors.centerIn: parent
            width: 500
            height: 420 // Increased height for preview

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Add New Game"
                        font.pixelSize: Fonts.sizes.title
                        color: Colors.colOnLayer1
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    MaterialSymbol {
                        font.pixelSize: 38
                        fill: 1
                        text: "stadia_controller"
                        font.family: Fonts.family.iconMaterial
                        color: Colors.colOnLayer0

                        transform: Rotation {
                            angle: 45
                        }

                    }

                }

                // Game name input
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: "Game Name:"
                        color: Colors.colOnLayer1
                        font.pixelSize: Fonts.sizes.normal
                    }

                    TextField {
                        id: nameInput

                        Layout.preferredHeight: 38
                        Layout.fillWidth: true
                        placeholderText: "Enter game name"
                        padding: 12
                        renderType: Text.NativeRendering
                        selectedTextColor: Colors.m3.m3onSecondaryContainer
                        selectionColor: Colors.colSecondaryContainer
                        placeholderTextColor: Colors.m3.m3outline

                        background: Rectangle {
                            color: Colors.colLayer1
                            radius: Rounding.normal
                        }

                    }

                }

                // Executable path input with browse button
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        font.pixelSize: Fonts.sizes.normal
                        text: "Executable Path:"
                        color: Colors.colOnLayer1
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: pathInput

                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            placeholderText: "/path/to/game.exe or /path/to/game"
                            padding: 12
                            renderType: Text.NativeRendering
                            selectedTextColor: Colors.m3.m3onSecondaryContainer
                            selectionColor: Colors.colSecondaryContainer
                            placeholderTextColor: Colors.m3.m3outline

                            background: Rectangle {
                                color: Colors.colLayer1
                                radius: Rounding.normal
                            }

                        }

                        RippleButton {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: pathInput.height
                            buttonRadius: Rounding.normal
                            colBackground: Colors.colSecondaryContainer
                            onPressed: executableFileDialog.open()

                            contentItem: MaterialSymbol {
                                text: "folder"
                                fill: 1
                                font.pixelSize: 18
                                color: Colors.colOnSecondaryContainer
                                horizontalAlignment: Text.AlignHCenter
                            }

                        }

                    }

                }

                RowLayout {
                    spacing: 10

                    StyledSwitch {
                        id: wineCheckbox

                        checked: false
                    }

                    StyledText {
                        font.pixelSize: Sizes.normal
                        color: Colors.colOnLayer0
                        text: "use wine"
                    }

                }

                // Cover image input with browse button and preview
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        font.pixelSize: Fonts.sizes.normal
                        text: "Cover Image (optional):"
                        color: Colors.colOnLayer1
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: coverInput

                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            placeholderText: "/path/to/cover.jpg"
                            padding: 12
                            renderType: Text.NativeRendering
                            selectedTextColor: Colors.m3.m3onSecondaryContainer
                            selectionColor: Colors.colSecondaryContainer
                            placeholderTextColor: Colors.m3.m3outline
                            onTextChanged: {
                                if (text.length > 0)
                                    coverPreview.source = text.startsWith("file://") ? text : "file://" + text;
                                else
                                    coverPreview.source = "";
                            }

                            background: Rectangle {
                                color: Colors.colLayer1
                                radius: Rounding.normal
                            }
                            // Update preview when text changes

                        }

                        RippleButton {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: coverInput.height
                            buttonRadius: Rounding.small
                            colBackground: Colors.colSecondaryContainer
                            onPressed: coverImageFileDialog.open()

                            contentItem: MaterialSymbol {
                                text: "folder"
                                fill: 1
                                font.pixelSize: 18
                                color: Colors.colOnSecondaryContainer
                                horizontalAlignment: Text.AlignHCenter
                            }

                        }

                    }

                    // Image preview
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: Colors.colLayer0
                        radius: Rounding.small
                        visible: coverInput.text.length > 0

                        Image {
                            id: coverPreview

                            anchors.fill: parent
                            anchors.margins: 5
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            asynchronous: true
                        }

                        StyledText {
                            font.pixelSize: Fonts.sizes.normal
                            anchors.centerIn: parent
                            text: "Image preview"
                            color: Colors.colOnLayer1
                            visible: coverPreview.status !== Image.Ready
                        }

                    }

                }

                Item {
                    Layout.fillHeight: true
                }

                // Dialog buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Item {
                        Layout.fillWidth: true
                    }

                    RippleButton {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 35
                        buttonRadius: Rounding.small
                        colBackground: Colors.colSecondaryContainer
                        onPressed: {
                            // Clear inputs when canceling
                            nameInput.text = "";
                            pathInput.text = "";
                            wineCheckbox.checked = false;
                            coverInput.text = "";
                            addGameDialog.close();
                        }

                        contentItem: StyledText {
                            text: "Cancel"
                            font.pixelSize: Fonts.sizes.normal
                            color: Colors.colOnSecondaryContainer
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                    RippleButton {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 35
                        buttonRadius: Rounding.small
                        colBackground: Colors.colPrimary
                        enabled: nameInput.text.length > 0 && pathInput.text.length > 0
                        onPressed: {
                            GameLauncherService.addGame(nameInput.text, pathInput.text, wineCheckbox.checked, coverInput.text, "");
                            // Clear inputs
                            nameInput.text = "";
                            pathInput.text = "";
                            wineCheckbox.checked = false;
                            coverInput.text = "";
                            addGameDialog.close();
                        }

                        contentItem: StyledText {
                            text: "Add"
                            font.pixelSize: Fonts.sizes.normal
                            color: Colors.colOnPrimary
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                }

            }

            background: Rectangle {
                color: Colors.colLayer0
                radius: Rounding.verylarge
            }

        }

    }

}
