import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.common.functions
import qs
import qs.modules.sidebarLauncher

ColumnLayout {
    id: tracksTab
    spacing: Appearance.padding.huge
    property var filteredIndices: []
    property string musicDirectory: MusicPlayerService.musicDirectory
    property string isolatedDirectory: MusicPlayerService.isolatedDirectory
    property string currentFolder: musicDirectory
    property string searchText: ""
    Layout.fillHeight: true
    Layout.fillWidth: true
    property bool shown: GlobalStates.playlistOpen

    Component.onCompleted: {
        MusicPlayerService.shuffleTracks();
        tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
        searchBar.searchInput.forceActiveFocus();
    }

    FolderListModel {
        id: musicModel
        folder: tracksTab.currentFolder
        nameFilters: ["*.mp3", "*.flac", "*.ogg", "*.wav", "*.m4a", "*.aac", "*.wma", "*.opus"]
        showDirs: false
        showFiles: true
        sortField: FolderListModel.Name

        function getTrackInfo(index) {
            if (index < 0 || index >= count) {
                return {
                    name: "",
                    path: "",
                    fileUrl: "",
                    extension: "",
                    fileName: ""
                };
            }

            try {
                const fileName = get(index, "fileName") || "";
                const fileUrl = get(index, "fileUrl") || "";
                const baseName = get(index, "baseName") || "";

                let extension = fileName.includes('.') ? fileName.split('.').pop().toUpperCase() : "";
                let filePath = fileUrl.toString().startsWith("file://") ? decodeURIComponent(fileUrl.toString().replace("file://", "")) : fileUrl.toString();

                return {
                    name: baseName || fileName.replace(/\.[^/.]+$/, "") || "Unknown Track",
                    path: filePath,
                    fileUrl,
                    extension,
                    fileName
                };
            } catch (e) {
                return {
                    name: "Unknown Track",
                    path: "",
                    fileUrl: "",
                    extension: "",
                    fileName: ""
                };
            }
        }
    }

    StyledListView {
        id: musicListView
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 8
        clip: true
        model: tracksTab.filteredIndices.length

        FloatingActionButton {
            id: shuffleButton
            iconText: "shuffle"
            baseSize: 45
            buttonRadius: Appearance.rounding.large
            colBackground: TrackColorsService.colors.colSecondaryContainer
            colBackgroundHover: TrackColorsService.colors.colSecondaryContainerHover
            colRipple: TrackColorsService.colors.colPrimary

            onClicked: {
                MusicPlayerService.shuffleTracks();
                tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
            }

            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 18
            }
            z: 999
        }

        Connections {
            target: tracksTab
            function onSearchTextChanged() {
                tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
            }
            function onCurrentFolderChanged() {
                tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
            }
        }

        Connections {
            target: musicModel
            function onCountChanged() {
                tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: musicListView.width
                height: musicListView.height
                radius: Appearance.rounding.normal
            }
        }
        delegate: StyledDelegateItem {
            required property int index
            parent: musicListView
            // Use a function that gets called AFTER delegate is created
            function getTrackInfo() {
                const originalIndex = tracksTab.filteredIndices[index] || 0;
                return musicModel.getTrackInfo(originalIndex);
            }

            // Reactive properties that update when model changes
            title: {
                const info = getTrackInfo();
                return info.name || "Unknown Track";
            }

            subtext: {
                const info = getTrackInfo();
                return info.extension ? info.extension + qsTr(" Audio") : "";
            }

            // Track path for actions (computed on-demand)
            property string trackPath: {
                const info = getTrackInfo();
                return info.path || "";
            }

            readonly property bool currentlyPlaying: {
                if (!trackPath || !MusicPlayerService.currentTrackPath)
                    return false;
                return trackPath === MusicPlayerService.currentTrackPath;
            }

            // Dynamic colors
            colActiveColor: currentlyPlaying ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colSecondaryContainer

            colActiveItemColor: currentlyPlaying ? TrackColorsService.colors.colPrimary : TrackColorsService.colors.colSecondary

            colBackground: currentlyPlaying ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colLayer1

            // Context Menu
            TrackContextMenu {
                id: trackContextMenu
                trackPath: parent.trackPath
                trackName: parent.title
                musicModel: musicModel
                parentButton: parent
                onRefresh: () => {
                    musicModel.refresh();
                    tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
                }
            }

            releaseAction: () => {
                if (trackPath)
                    MusicPlayerService.playTrack(trackPath, musicModel);
            }

            altAction: () => {
                console.log("[TrackItem] Alt action (right-click) for:", title);
                if (trackPath) {
                    trackContextMenu.showMenu();
                }
            }

            onPressed: event => {
                if (event.button === Qt.MiddleButton && trackPath) {
                    MusicPlayerService.isolateTrack(trackPath, () => {
                        musicModel.refresh();
                        tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
                    });
                }
            }
        }
    }

    SearchBar {
        id: searchBar
        show: true
        Layout.preferredHeight: 40
        searchInput.placeholderText: "Search Tracks"
        color: TrackColorsService.colors.colLayer1
        onSearchTextChanged: tracksTab.searchText = searchText
    }
}
