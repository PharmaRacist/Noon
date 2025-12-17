import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import QtQuick.Controls.Material
import QtQuick
import QtMultimedia
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

Item {
    id: root
    property string searchQuery: ""
    property int mode: 0
    property bool verticalMode: true
    property bool expanded: false
    readonly property int itemSpacing: 8
    property int gridItemWidth: width / gridColumns
    property int gridItemHeight: gridItemWidth * (9 / 16)
    property int gridColumns: expanded ? 5 : 1

    signal searchFocusRequested
    signal contentFocusRequested

    function updateGridModel() {
        if (!WallpaperService?.wallpaperModel) {
            Qt.callLater(updateGridModel);
            return;
        }

        const model = WallpaperService.wallpaperModel;
        gridView.model = model.count;
    }

    Component.onCompleted: updateGridModel()
    onSearchQueryChanged: {
        if (!WallpaperService?.wallpaperModel)
            return;

        const model = WallpaperService.wallpaperModel;
        if (root.searchQuery.length > 0) {
            model.filterWallpapers(root.searchQuery);
        } else {
            model.clearFilter();
        }
    }

    StyledRect {
        anchors.fill: parent
        color: "transparent"
        clip: true
        radius: Rounding.verylarge

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            StyledGridView {
                id: gridView
                property int currentIndex: -1

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: root.gridItemWidth
                cellHeight: root.gridItemHeight
                model: WallpaperService.folderModel.count
                focus: true

                // Auto-focus first item when model changes
                onCountChanged: {
                    if (count > 0 && currentIndex === -1 && activeFocus) {
                        currentIndex = 0;
                    }
                }

                Keys.onPressed: event => {
                    if (!gridView.model || gridView.model === 0)
                        return;

                    const columnsPerRow = root.gridColumns;
                    const shiftPressed = event.modifiers & Qt.ShiftModifier;
                    const jumpSize = shiftPressed ? 5 : 1; // Jump 5 rows/columns when Shift is held
                    const pageSize = Math.floor(gridView.height / root.gridItemHeight) * columnsPerRow;

                    switch (event.key) {
                    case Qt.Key_Down:
                        if (gridView.currentIndex === -1 && gridView.model > 0) {
                            gridView.currentIndex = 0;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        } else if (gridView.currentIndex + columnsPerRow * jumpSize < gridView.model) {
                            gridView.currentIndex += columnsPerRow * jumpSize;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        } else {
                            gridView.currentIndex = gridView.model - 1;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_Up:
                        if (gridView.currentIndex === -1 && gridView.model > 0) {
                            gridView.currentIndex = gridView.model - 1;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        } else if (gridView.currentIndex >= columnsPerRow * jumpSize) {
                            gridView.currentIndex -= columnsPerRow * jumpSize;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        } else if (gridView.currentIndex >= 0) {
                            if (shiftPressed) {
                                gridView.currentIndex = 0;
                                gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                            } else {
                                gridView.currentIndex = -1;
                                root.searchFocusRequested();
                            }
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_Left:
                        if (gridView.currentIndex === -1 && gridView.model > 0) {
                            gridView.currentIndex = 0;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        } else if (gridView.currentIndex >= jumpSize) {
                            gridView.currentIndex -= jumpSize;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        } else if (gridView.currentIndex > 0) {
                            gridView.currentIndex = 0;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_Right:
                        if (gridView.currentIndex === -1 && gridView.model > 0) {
                            gridView.currentIndex = 0;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        } else if (gridView.currentIndex + jumpSize < gridView.model) {
                            gridView.currentIndex += jumpSize;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        } else {
                            gridView.currentIndex = gridView.model - 1;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_PageDown:
                        if (gridView.currentIndex === -1) {
                            gridView.currentIndex = 0;
                        } else if (gridView.currentIndex + pageSize < gridView.model) {
                            gridView.currentIndex += pageSize;
                        } else {
                            gridView.currentIndex = gridView.model - 1;
                        }
                        gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        event.accepted = true;
                        break;
                    case Qt.Key_PageUp:
                        if (gridView.currentIndex === -1) {
                            gridView.currentIndex = gridView.model - 1;
                        } else if (gridView.currentIndex >= pageSize) {
                            gridView.currentIndex -= pageSize;
                        } else {
                            gridView.currentIndex = 0;
                        }
                        gridView.positionViewAtIndex(gridView.currentIndex, GridView.Contain);
                        event.accepted = true;
                        break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        if (gridView.currentIndex >= 0 && gridView.currentIndex < gridView.model) {
                            const fileUrl = WallpaperService.wallpaperModel.getFile(gridView.currentIndex);
                            if (fileUrl) {
                                WallpaperService.applyWallpaper(fileUrl);
                            }
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_Home:
                        if (gridView.model > 0) {
                            gridView.currentIndex = 0;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.Beginning);
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_End:
                        if (gridView.model > 0) {
                            gridView.currentIndex = gridView.model - 1;
                            gridView.positionViewAtIndex(gridView.currentIndex, GridView.End);
                        }
                        event.accepted = true;
                        break;
                    }
                }

                delegate: Item {
                    id: delegateItem
                    required property int index
                    width: root.gridItemWidth
                    height: root.gridItemHeight

                    WallpaperItem {
                        property int delegateIndex: index
                        isKeyboardSelected: delegateIndex === gridView.currentIndex && gridView.activeFocus
                        isCurrentWallpaper: fileUrl === WallpaperService.currentWallpaper
                        anchors.fill: parent
                        anchors.margins: isKeyboardSelected ? 3 * root.itemSpacing : root.itemSpacing
                        fileUrl: WallpaperService.wallpaperModel?.getFile(delegateIndex) ?? ""
                        onClicked: {
                            if (!fileUrl)
                                return;
                            WallpaperService.applyWallpaper(fileUrl);
                            gridView.currentIndex = delegateIndex;
                        }

                        Behavior on anchors.margins {
                            Anim {}
                        }
                    }
                }
            }
        }

        Connections {
            target: WallpaperService?.wallpaperModel ?? null
            ignoreUnknownSignals: true

            function onModelUpdated() {
                root.updateGridModel();
            }
        }

        Connections {
            target: root

            function onContentFocusRequested() {
                if (gridView.model > 0) {
                    gridView.currentIndex = 0;
                    gridView.forceActiveFocus();
                    gridView.positionViewAtIndex(0, GridView.Beginning);
                }
            }
        }

        PagePlaceholder {
            anchors.centerIn: parent
            visible: gridView.model === 0 && root.searchQuery !== ""
            icon: "block"
            shape: MaterialShape.Clover4Leaf
            title: "Nothing found"
        }

        WallpaperControls {
            id: controls
            expanded: root.expanded
            onBrowserOpened: {
                GlobalStates.sidebarLauncherOpen = false;
                dashboardOpen = false;
            }
        }
    }
    component WallpaperItem: StyledRect {
        id: wallpaperItem

        // Public properties
        property string fileUrl
        property bool isKeyboardSelected: false
        property bool isCurrentWallpaper: false
        property int mainRounding: Rounding.large
        clip: true

        // Signals
        signal clicked

        radius: mainRounding
        color: ColorUtils.transparentize(Colors.colLayer0, (isKeyboardSelected ? 0 : 0.8))
        enableShadows: isKeyboardSelected
        enableBorders: isKeyboardSelected

        readonly property bool isVideoFile: {
            if (!fileUrl)
                return false;
            const fileName = fileUrl.toString().toLowerCase();
            return fileName.endsWith(".mp4") || fileName.endsWith(".mov") || fileName.endsWith(".m4v") || fileName.endsWith(".avi") || fileName.endsWith(".mkv") || fileName.endsWith(".webm");
        }

        readonly property bool usingThumbnail: {
            const thumbPath = WallpaperService.getThumbnailPath(wallpaperItem.fileUrl, "large");
            return thumbPath !== wallpaperItem.fileUrl;
        }

        // Image for static wallpapers
        CroppedImage {
            id: imageObject
            anchors.fill: parent
            source: isVideoFile ? "" : WallpaperService.getThumbnailPath(wallpaperItem.fileUrl, "large")
            radius: wallpaperItem.mainRounding
            asynchronous: true
            visible: !isVideoFile
        }

        // Video player for video wallpapers
        VideoPreview {
            id: videoPlayer
            anchors.fill: parent
            source: isVideoFile ? wallpaperItem.fileUrl : ""
            visible: isVideoFile
        }

        // Video indicator overlay
        Rectangle {
            visible: isVideoFile
            anchors {
                top: parent.top
                right: parent.right
                margins: 8
            }
            width: 40
            height: 40
            radius: 20
            color: ColorUtils.transparentize(Colors.colLayer0, 0.3)

            MaterialSymbol {
                anchors.centerIn: parent
                text: "play_circle"
                fill: 1
                color: Colors.m3.m3onSurface
                font.pixelSize: 24
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            acceptedButtons:Qt.RightButton|Qt.LeftButton
            onPressed: (event) => {
                  if (event.button === Qt.RightButton){
                      wallpaperMenu.popup(event.x, event.y);
                  } else if (event.button === Qt.LeftButton){
                      wallpaperItem.clicked();
                  }
            }

            onEntered: {
                if (isVideoFile && videoPlayer.playbackState !== MediaPlayer.PlayingState) {
                    videoPlayer.play();
                }
            }

            onExited: {
                if (isVideoFile && videoPlayer.playbackState === MediaPlayer.PlayingState) {
                    videoPlayer.pause();
                }
            }
        }

        RoundCorner {
            id: currentWallpaperIndicator
            corner: cornerEnum.bottomRight
            size: 70
            color: Colors.m3.m3primary
            visible: isCurrentWallpaper
            z: 99
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
        }

        MaterialSymbol {
            z: 999
            visible: currentWallpaperIndicator.visible
            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: 0
            }
            text: "check"
            fill: 1
            color: Colors.m3.m3onPrimary
            font.pixelSize: 25
        }
        Menu {
            id: wallpaperMenu
            Material.theme: Material.Dark
            Material.primary: Colors.colPrimaryContainer
            Material.accent: Colors.colSecondaryContainer
            Material.roundedScale: Rounding.normal
            Material.elevation: 8

            background: StyledRect {
                implicitWidth: 240
                implicitHeight: 26 * (parent.contentItem.children.length)
                color: Colors.colLayer0
                radius: Rounding.verylarge
                enableShadows:true
            }

            enter: Transition {
                Anim {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Animations.durations.small
                }
                Anim {
                    property: "scale"
                    from: 0.95
                    to: 1
                    duration: Animations.durations.small
                }
            }

            exit: Transition {
                Anim {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: Animations.durations.small
                }
                Anim {
                    property: "scale"
                    from: 1
                    to: 0.95
                    duration: Animations.durations.small
                }
            }

            MenuItem {
                text: " Delete"
                Material.foreground: Colors.colOnLayer2
                Material.accent: Colors.colPrimary
                background: Rectangle {
                    color: parent.hovered ? Colors.colOnSurface : "transparent"
                    radius: Rounding.verylarge
                    anchors.leftMargin: Padding.normal
                    anchors.rightMargin: Padding.normal
                    anchors.fill: parent
                    opacity: parent.hovered ? 0.08 : 0
                }
                onTriggered: if (wallpaperItem.fileUrl)
                        FileUtils.deleteItem(wallpaperItem.fileUrl);
            }
        }
    }
}
