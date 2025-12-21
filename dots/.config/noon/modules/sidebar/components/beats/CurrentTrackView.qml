import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

StyledRect {
    id: root
    clip: true
    radius: Rounding.verylarge
    property int coverArtSize: 300
    readonly property MprisPlayer player: MusicPlayerService.player
    property bool playing: player && player.playbackState === MprisPlaybackState.Playing
    property bool displayingLyrics: LyricsService.lyrics.length > 0
    property bool showTracks: false
    property bool expandDialog: false
    // gradient: Gradient {
    //     GradientStop {
    //         position: 0.9
    //         color: "transparent"
    //     }
    //     GradientStop {
    //         position: 1.0
    //         color: !showTracks && Mem.options.mediaPlayer.enableGrad ? TrackColorsService.gradColor : "transparent"
    //         Behavior on color {
    //             CAnim {}
    //         }
    //     }
    // }
    color: "transparent"

    Keys.onPressed: event => {
        // ── Ctrl+Shift shortcuts ──
        if ((event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
            switch (event.key) {
            case Qt.Key_R:
                LyricsService.fetchLyrics(MusicPlayerService.artist || "", MusicPlayerService.title || "");
                event.accepted = true;
                break;
            case Qt.Key_Right:
                if (player?.canControl)
                    player.next();
                event.accepted = true;
                break;
            case Qt.Key_Left:
                if (player?.canControl)
                    player.previous();
                event.accepted = true;
                break;
            case Qt.Key_D:
                MusicPlayerService.downloadCurrentSong();
                event.accepted = true;
                break;
            case Qt.Key_S:
                if (player)
                    player.shuffle = !player.shuffle;
                event.accepted = true;
                break;
            }
        } else
        // ── Ctrl-only shortcuts ──
        if (event.modifiers & Qt.ControlModifier) {
            switch (event.key) {
            case Qt.Key_R:
                MusicPlayerService.cycleRepeat();
                event.accepted = true;
                break;
            }
        } else

        // ── Regular keys ──
        {
            switch (event.key) {
            case Qt.Key_Up:
                if (Audio && Audio.sink && Audio.sink.audio) {
                    Audio.sink.audio.volume = Math.min(1.0, Audio.sink.audio.volume + 0.05);
                }
                event.accepted = true;
                break;
            case Qt.Key_Down:
                if (Audio && Audio.sink && Audio.sink.audio) {
                    Audio.sink.audio.volume = Math.max(0.0, Audio.sink.audio.volume - 0.05);
                }
                event.accepted = true;
                break;
            case Qt.Key_Space:
                player.togglePlaying();
                event.accepted = true;
                break;
            case Qt.Key_Right:
                if (player.canSeek && player.length) {
                    player.position = Math.min(player.length, player.position + 10);
                }
                event.accepted = true;
                break;
            case Qt.Key_Left:
                if (player.canSeek && player.length) {
                    player.position = Math.max(0, player.position - 10);
                }
                event.accepted = true;
                break;
            }
        }
    }

    Loader {
        z: -1
        active: Mem.options.mediaPlayer.useBlur
        anchors.fill: parent
        sourceComponent: Item {
            BlurImage {
                anchors.fill: parent
                source: MusicPlayerService.artUrl
                asynchronous: true
                blur: true
                tint: true
                tintLevel: 0.65
                tintColor: TrackColorsService.colors.colSecondaryContainer
            }
        }
    }

    Loader {
        anchors.fill: parent
        active: Mem.options.mediaPlayer.showVisualizer && root.playing
        sourceComponent: Visualizer {
            active: Mem.options.mediaPlayer.showVisualizer && root.playing
            mode: Mem.options.mediaPlayer.visualizerMode
            visualizerSmoothing: 4
            maxVisualizerValue: mode === "atom" ? 500 : 1500
            visualizerColor: TrackColorsService.colors.colPrimary
        }
    }

    BottomDialog {
        id: bottomDialog
        z: 99
        visible: true
        expandedHeight: parent.height * 0.75  // Collapsed: 200px, Expanded: 75% of parent
        collapsedHeight: 100
        show: false  // Changed from root.showDialog which doesn't exist
        expand: false
        contentItem: Item {
            anchors.fill: parent
            ColumnLayout {
                spacing: Padding.large

                anchors {
                    fill: parent
                    margins: Padding.massive
                }

                RowLayout {
                    id: header
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 50
                    Layout.bottomMargin: 0
                    Layout.margins: Padding.normal

                    StyledText {
                        text: MusicPlayerService.filteredIndices.length + " Tracks"
                        font.pixelSize: Fonts.sizes.subTitle
                        color: Colors.colOnLayer2
                        verticalAlignment: Text.AlignVCenter
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    }

                    Spacer {}

                    RippleButtonWithIcon {
                        materialIcon: "close"
                        Layout.alignment: Qt.AlignRight | Qt.AlignTop
                        releaseAction: () => {
                            bottomDialog.show = false;
                            root.expandDialog = false;  // Reset expansion state when closing
                        }
                    }
                }

                Separator {
                    visible: musicListView.visible
                }

                SearchBar {
                    id: searchBar
                    visible: musicListView.visible  // Only show search when expanded
                    show: true
                    Layout.preferredHeight: 40
                    searchInput.placeholderText: "Search Tracks"
                    color: "transparent"
                    onSearchTextChanged: MusicPlayerService.updateSearchFilter(searchText)
                }

                StyledListView {
                    id: musicListView
                    visible: bottomDialog.expand  // Only show list when expanded
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    clip: true
                    model: MusicPlayerService.filteredTracksCount

                    Component.onCompleted: MusicPlayerService.initializeTracks()

                    delegate: StyledDelegateItem {
                        required property int index
                        parent: musicListView

                        readonly property var trackInfo: MusicPlayerService.getFilteredTrackInfo(index)
                        readonly property string trackPath: trackInfo.path || ""
                        readonly property bool currentlyPlaying: trackPath && trackPath === MusicPlayerService.currentTrackPath

                        title: trackInfo.name || "Unknown Track"
                        subtext: trackInfo.extension ? trackInfo.extension + qsTr(" Audio") : ""

                        colActiveColor: currentlyPlaying ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colSecondaryContainer

                        colActiveItemColor: currentlyPlaying ? TrackColorsService.colors.colPrimary : TrackColorsService.colors.colSecondary

                        colBackground: currentlyPlaying ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colLayer1

                        TrackContextMenu {
                            id: trackContextMenu
                            trackPath: parent.trackPath
                            trackName: parent.title
                            parentButton: parent
                        }

                        releaseAction: () => {
                            if (trackPath)
                                MusicPlayerService.playTrackByPath(trackPath);
                        }

                        altAction: () => {
                            if (trackPath)
                                trackContextMenu.showMenu();
                        }
                    }
                }
            }
        }
    }

    SpotifyLyrics {
        id: lyrics
        coverArtSize: root.coverArtSize
    }
    ColumnLayout {
        z: -1
        anchors.fill: parent
        anchors.margins: Padding.large
        spacing: Padding.large

        Spacer {}
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Padding.large
            layoutDirection: !root.displayingLyrics ? Qt.RightToLeft : Qt.LeftToRight
            Spacer {}
            PlayerSelector {}
        }

        ColumnLayout {
            id: bottomDash
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Padding.large
            spacing: Padding.huge

            RowLayout {
                spacing: Padding.large
                Layout.fillWidth: true
                Layout.bottomMargin: Padding.small
                Revealer {
                    reveal: LyricsService.state !== LyricsService.NoLyricsFound
                    Layout.maximumWidth: root.coverArtSize / 4
                    Layout.maximumHeight: root.coverArtSize / 4

                    CroppedImage {
                        id: cover
                        opacity: 1
                        anchors.centerIn: parent
                        z: 99
                        visible: parent.reveal
                        source: MusicPlayerService?.artUrl
                        sourceSize: Qt.size(width, height)
                        mipmap: true
                        radius: Rounding.normal
                        tint: true
                        tintLevel: 0.8
                        tintColor: TrackColorsService.colors.colSecondaryContainer
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    StyledText {
                        Layout.maximumWidth: parent.width * 0.8
                        Layout.fillWidth: true
                        font.pixelSize: Fonts.sizes.huge
                        font.family: Fonts.family.main
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        color: TrackColorsService.colors.colOnLayer0
                        text: {
                            if (player?.trackTitle)
                                return player.trackTitle;
                            else
                                return "No players available";
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        font.pixelSize: 17
                        color: TrackColorsService.colors.colSubtext
                        font.family: Fonts.family.main
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                        text: {
                            if (player?.trackArtist)
                                return player.trackArtist;
                            else
                                return "No players available";
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width * 0.92
                Layout.preferredHeight: 18
                Layout.topMargin: 5

                StyledProgressBar {
                    anchors.fill: parent
                    value: MusicPlayerService.currentTrackProgressRatio
                    highlightColor: TrackColorsService.colors.colPrimary
                    trackColor: TrackColorsService.colors.colSecondaryContainer
                    sperm: true
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: player && player.canSeek && player.length > 0
                    hoverEnabled: true
                    property bool isDragging: false
                    onPressed: function (mouse) {
                        isDragging = true;
                        seek(mouse.x);
                    }
                    onPositionChanged: function (mouse) {
                        if (isDragging)
                            seek(mouse.x);
                    }

                    onReleased: function () {
                        isDragging = false;
                    }

                    function seek(x) {
                        if (!player || !player.canSeek || !player.length)
                            return;
                        let r = Math.max(0, Math.min(1, x / width));
                        player.position = r * player.length;
                    }
                }
            }

            MediaPlayerControls {
                id: controls
                Layout.alignment: Qt.AlignHCenter
                showDownload: !(player && player.dbusName?.includes("vlc"))
            }
        }
    }
}
