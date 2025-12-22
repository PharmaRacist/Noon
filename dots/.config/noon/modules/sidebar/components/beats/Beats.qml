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
    color: "transparent"
    property bool expandDialog: false
    property int coverArtSize: 300
    readonly property MprisPlayer player: MusicPlayerService.player
    property bool playing: player && player.playbackState === MprisPlaybackState.Playing
    property bool displayingLyrics: LyricsService.lyrics.length > 0

    Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
            switch (event.key) {
            case Qt.Key_R:
                LyricsService.fetchLyrics(MusicPlayerService.artist || "", MusicPlayerService.title || "");
                event.accepted = true;
                break;
            case Qt.Key_Right:
                player?.canControl && player.next();
                event.accepted = true;
                break;
            case Qt.Key_Left:
                player?.canControl && player.previous();
                event.accepted = true;
                break;
            case Qt.Key_D:
                MusicPlayerService.downloadCurrentSong();
                event.accepted = true;
                break;
            case Qt.Key_S:
                player && (player.shuffle = !player.shuffle);
                event.accepted = true;
                break;
            }
        } else if (event.modifiers & Qt.ControlModifier) {
            if (event.key === Qt.Key_R) {
                MusicPlayerService.cycleRepeat();
                event.accepted = true;
            }
        } else {
            switch (event.key) {
            case Qt.Key_Up:
                Audio?.sink?.audio && (Audio.sink.audio.volume = Math.min(1.0, Audio.sink.audio.volume + 0.05));
                event.accepted = true;
                break;
            case Qt.Key_Down:
                Audio?.sink?.audio && (Audio.sink.audio.volume = Math.max(0.0, Audio.sink.audio.volume - 0.05));
                event.accepted = true;
                break;
            case Qt.Key_Space:
                player?.togglePlaying();
                event.accepted = true;
                break;
            case Qt.Key_Right:
                player?.canSeek && player.length && (player.position = Math.min(player.length, player.position + 10));
                event.accepted = true;
                break;
            case Qt.Key_Left:
                player?.canSeek && player.length && (player.position = Math.max(0, player.position - 10));
                event.accepted = true;
                break;
            }
        }
    }

    Loader {
        z: -1
        active: Mem.options.mediaPlayer.useBlur
        anchors.fill: parent
        sourceComponent: BlurImage {
            anchors.fill: parent
            source: MusicPlayerService.artUrl
            asynchronous: true
            blur: true
            tint: true
            tintLevel: 0.65
            tintColor: TrackColorsService.colors.colSecondaryContainer
        }
    }

    Loader {
        anchors.fill: parent
        active: Mem.options.mediaPlayer.showVisualizer && root.playing
        sourceComponent: Visualizer {
            active: true
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
        expandedHeight: parent.height * 0.75
        collapsedHeight: 100
        expand: root.expandDialog

        contentItem: ColumnLayout {
            spacing: Padding.large
            anchors {
                fill: parent
                margins: Padding.massive
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                StyledText {
                    text: MusicPlayerService.filteredIndices.length + " Tracks"
                    font.pixelSize: Fonts.sizes.subTitle
                    color: Colors.colOnLayer2
                }

                Spacer {}

                RippleButtonWithIcon {
                    materialIcon: "close"
                    releaseAction: () => bottomDialog.expand = false
                }
            }

            Separator {
                visible: musicListView.visible
            }

            SearchBar {
                visible: musicListView.visible
                Layout.preferredHeight: 40
                searchInput.placeholderText: "Search Tracks"
                color: "transparent"
                onSearchTextChanged: MusicPlayerService.updateSearchFilter(searchText)
            }

            StyledListView {
                id: musicListView
                visible: bottomDialog.expand
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8
                clip: true
                model: MusicPlayerService.filteredTracksCount

                Component.onCompleted: MusicPlayerService.initializeTracks()

                delegate: StyledDelegateItem {
                    required property int index

                    readonly property var trackInfo: MusicPlayerService.getFilteredTrackInfo(index)
                    readonly property string trackPath: trackInfo.path || ""
                    readonly property bool currentlyPlaying: trackPath === MusicPlayerService.currentTrackPath

                    title: trackInfo.name || "Unknown Track"
                    subtext: trackInfo.extension ? trackInfo.extension + " Audio" : ""
                    colActiveColor: currentlyPlaying ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colSecondaryContainer
                    colActiveItemColor: currentlyPlaying ? TrackColorsService.colors.colPrimary : TrackColorsService.colors.colSecondary
                    colBackground: currentlyPlaying ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colLayer1

                    TrackContextMenu {
                        id: trackContextMenu
                        trackPath: parent.trackPath
                        trackName: parent.title
                        parentButton: parent
                    }

                    releaseAction: () => trackPath && MusicPlayerService.playTrackByPath(trackPath)
                    altAction: () => trackPath && trackContextMenu.showMenu()
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
        anchors {
            fill: parent
            margins: Padding.large
        }
        spacing: Padding.large

        Spacer {}

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Padding.large
            layoutDirection: !root.displayingLyrics ? Qt.RightToLeft : Qt.LeftToRight

            Spacer {}
        }
            PlayerSelector {}

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Padding.large
            spacing: Padding.huge

            RowLayout {
                spacing: Padding.large
                Layout.fillWidth: true

                Revealer {
                    reveal: LyricsService.state !== LyricsService.NoLyricsFound
                    Layout.maximumWidth: root.coverArtSize / 4
                    Layout.maximumHeight: root.coverArtSize / 4

                    CroppedImage {
                        visible:parent.reveal
                        anchors.centerIn: parent
                        z: 99
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
                        Layout.fillWidth: true
                        font.pixelSize: Fonts.sizes.huge
                        font.weight: Font.Medium
                        color: TrackColorsService.colors.colOnLayer0
                        elide: Text.ElideRight
                        text: player?.trackTitle || "No players available"
                    }

                    StyledText {
                        Layout.fillWidth: true
                        font.pixelSize: 17
                        color: TrackColorsService.colors.colSubtext
                        elide: Text.ElideRight
                        text: player?.trackArtist || "No players available"
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 18

                StyledProgressBar {
                    sperm:true
                    anchors.fill: parent
                    value: MusicPlayerService.currentTrackProgressRatio
                    highlightColor: TrackColorsService.colors.colPrimary
                    trackColor: TrackColorsService.colors.colSecondaryContainer
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: player?.canSeek && player.length > 0
                    hoverEnabled: true
                    property bool isDragging: false

                    onPressed: mouse => {
                        isDragging = true;
                        seek(mouse.x);
                    }
                    onPositionChanged: mouse => isDragging && seek(mouse.x)
                    onReleased: isDragging = false

                    function seek(x) {
                        if (!player?.canSeek || !player.length) return;
                        player.position = Math.max(0, Math.min(1, x / width)) * player.length;
                    }
                }
            }

            MediaPlayerControls {
                Layout.alignment: Qt.AlignHCenter
                showDownload: !(player?.dbusName?.includes("vlc"))
            }
        }
    }
}
