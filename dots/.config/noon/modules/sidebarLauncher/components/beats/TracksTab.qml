import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.sidebarLauncher
import qs.services

ColumnLayout {
    id: tracksTab

    property var filteredIndices: []
    property string musicDirectory: MusicPlayerService.musicDirectory
    property string isolatedDirectory: MusicPlayerService.isolatedDirectory
    property string currentFolder: musicDirectory
    property string searchText: ""
    property bool shown: GlobalStates.playlistOpen

    spacing: Appearance.padding.huge
    Layout.fillHeight: true
    Layout.fillWidth: true
    Component.onCompleted: {
        MusicPlayerService.shuffleTracks();
        tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
        searchBar.searchInput.forceActiveFocus();
    }

    FolderListModel {
        id: musicModel

        function getTrackInfo(index) {
            if (index < 0 || index >= count)
                return {
                    "name": "",
                    "path": "",
                    "fileUrl": "",
                    "extension": "",
                    "fileName": ""
                };

            try {
                const fileName = get(index, "fileName") || "";
                const fileUrl = get(index, "fileUrl") || "";
                const baseName = get(index, "baseName") || "";
                let extension = fileName.includes('.') ? fileName.split('.').pop().toUpperCase() : "";
                let filePath = fileUrl.toString().startsWith("file://") ? decodeURIComponent(fileUrl.toString().replace("file://", "")) : fileUrl.toString();
                return {
                    "name": baseName || fileName.replace(/\.[^/.]+$/, "") || "Unknown Track",
                    "path": filePath,
                    "fileUrl": fileUrl,
                    "extension": extension,
                    "fileName": fileName
                };
            } catch (e) {
                return {
                    "name": "Unknown Track",
                    "path": "",
                    "fileUrl": "",
                    "extension": "",
                    "fileName": ""
                };
            }
        }

        folder: tracksTab.currentFolder
        nameFilters: ["*.mp3", "*.flac", "*.ogg", "*.wav", "*.m4a", "*.aac", "*.wma", "*.opus"]
        showDirs: false
        showFiles: true
        sortField: FolderListModel.Name
    }

    StyledListView {
        id: musicListView

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 8
        clip: true
        model: tracksTab.filteredIndices.length
        layer.enabled: true

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
            z: 999

            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 18
            }

        }

        Connections {
            function onSearchTextChanged() {
                tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
            }

            function onCurrentFolderChanged() {
                tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
            }

            target: tracksTab
        }

        Connections {
            function onCountChanged() {
                tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
            }

            target: musicModel
        }

        layer.effect: OpacityMask {

            maskSource: Rectangle {
                width: musicListView.width
                height: musicListView.height
                radius: Appearance.rounding.normal
            }

        }

        delegate: StyledDelegateItem {
            required property int index
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

            // Use a function that gets called AFTER delegate is created
            function getTrackInfo() {
                const originalIndex = tracksTab.filteredIndices[index] || 0;
                return musicModel.getTrackInfo(originalIndex);
            }

            parent: musicListView
            // Reactive properties that update when model changes
            title: {
                const info = getTrackInfo();
                return info.name || "Unknown Track";
            }
            subtext: {
                const info = getTrackInfo();
                return info.extension ? info.extension + qsTr(" Audio") : "";
            }
            // Dynamic colors
            colActiveColor: currentlyPlaying ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colSecondaryContainer
            colActiveItemColor: currentlyPlaying ? TrackColorsService.colors.colPrimary : TrackColorsService.colors.colSecondary
            colBackground: currentlyPlaying ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colLayer1
            releaseAction: () => {
                if (trackPath)
                    MusicPlayerService.playTrack(trackPath, musicModel);

            }
            altAction: () => {
                console.log("[TrackItem] Alt action (right-click) for:", title);
                if (trackPath)
                    trackContextMenu.showMenu();

            }
            onPressed: (event) => {
                if (event.button === Qt.MiddleButton && trackPath)
                    MusicPlayerService.isolateTrack(trackPath, () => {
                        musicModel.refresh();
                        tracksTab.filteredIndices = MusicPlayerService.filterTracks(musicModel, tracksTab.searchText);
                    });

            }

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
