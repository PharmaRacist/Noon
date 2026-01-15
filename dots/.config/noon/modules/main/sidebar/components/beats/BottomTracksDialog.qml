import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

BottomDialog {
    id: root

    property var filteredTracks: []
    property string searchText: ""

    function updateFilteredTracks() {
        let tracks = [];
        const model = BeatsService.tracksModel;
        if (!model) {
            filteredTracks = tracks;
            return;
        }
        const count = model.count;
        const search = searchText.toLowerCase();
        for (let i = 0; i < count; i++) {
            const trackInfo = BeatsService.getTrackInfo(i);
            if (trackInfo && (search === "" || trackInfo.name.toLowerCase().includes(search)))
                tracks.push({
                    "index": i,
                    "info": trackInfo
                });
        }
        filteredTracks = tracks;
    }

    z: 99
    expandedHeight: root.height * 0.95
    collapsedHeight: root.height * 0.65
    bottomAreaReveal: true
    hoverHeight: 200
    revealOnWheel: true
    enableStagedReveal: true
    colors: parent.colors
    Component.onCompleted: updateFilteredTracks()

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Padding.verylarge
        spacing: Padding.large

        BottomDialogHeader {
            title: "Beats"
            subTitle: `There are ${root.filteredTracks.length} Tracks in your playlist !`
        }

        SearchBar {
            id: search

            Layout.fillWidth: true
            implicitHeight: 40
            Layout.leftMargin: Padding.large
            Layout.rightMargin: Padding.large
            searchInput.placeholderText: "Search Tracks"
            color: "transparent"
            onSearchTextChanged: searchTimer.restart()

            Timer {
                id: searchTimer

                interval: 200
                onTriggered: {
                    root.searchText = search.searchText;
                    root.updateFilteredTracks();
                }
            }
        }

        StyledListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Padding.normal
            spacing: 8
            clip: true
            model: root.filteredTracks

            delegate: StyledDelegateItem {
                required property int index
                required property var modelData
                readonly property var trackInfo: modelData.info
                readonly property string trackPath: trackInfo.path || ""
                readonly property bool currentlyPlaying: trackPath === BeatsService.currentTrackPath
                readonly property string fileExtension: trackInfo.fileName.includes('.') ? trackInfo.fileName.split('.').pop().toUpperCase() : ""

                implicitHeight: 70
                title: trackInfo.name || "Unknown Track"
                subtext: fileExtension ? `${fileExtension} Audio` : ""
                colBackground: currentlyPlaying ? colors.colSecondaryContainerActive : colors.colLayer1
                shape: MaterialShape.Bun
                shapePadding: Padding.small
                colors: root.colors
                releaseAction: () => {
                    return BeatsService.playTrackByPath(trackPath);
                }
                altAction: () => {
                    return trackContextMenu.popup();
                }

                TrackContextMenu {
                    id: trackContextMenu

                    trackPath: parent.trackPath
                    trackName: parent.title
                }
            }
        }
    }
}
