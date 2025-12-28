import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root

    clip: true
    radius: Rounding.verylarge
    color: "transparent"

    readonly property bool playing: BeatsService.player?.playbackState === MprisPlaybackState.Playing
    readonly property bool displayingLyrics: LyricsService.lyrics.length > 0
    property QtObject colors: BeatsService.colors
    Keys.onPressed: event => {
        const ctrl = event.modifiers & Qt.ControlModifier;
        const shift = event.modifiers & Qt.ShiftModifier;
        const player = BeatsService.player;

        if (ctrl && shift) {
            switch (event.key) {
            case Qt.Key_R:
                LyricsService.fetchLyrics(BeatsService.artist || "", BeatsService.title || "");
                break;
            case Qt.Key_Right:
                player?.canControl && player.next();
                break;
            case Qt.Key_Left:
                player?.canControl && player.previous();
                break;
            case Qt.Key_D:
                BeatsService.downloadCurrentSong();
                break;
            case Qt.Key_S:
                player && (player.shuffle = !player.shuffle);
                break;
            default:
                return;
            }
        } else if (ctrl && event.key === Qt.Key_R) {
            BeatsService.cycleRepeat();
        } else {
            switch (event.key) {
            case Qt.Key_Up:
                AudioService?.sink?.audio && (AudioService.sink.audio.volume = Math.min(1.0, AudioService.sink.audio.volume + 0.05));
                break;
            case Qt.Key_Down:
                AudioService?.sink?.audio && (AudioService.sink.audio.volume = Math.max(0.0, AudioService.sink.audio.volume - 0.05));
                break;
            case Qt.Key_Space:
                player?.togglePlaying();
                break;
            case Qt.Key_Right:
                player?.canSeek && player.length && (player.position = Math.min(player.length, player.position + 10));
                break;
            case Qt.Key_Left:
                player?.canSeek && player.length && (player.position = Math.max(0, player.position - 10));
                break;
            default:
                return;
            }
        }
        event.accepted = true;
    }

    Loader {
        z: -2
        active: Mem.options.mediaPlayer.useBlur
        anchors.fill: parent
        sourceComponent: BlurImage {
            anchors.fill: parent
            source: BeatsService.artUrl
            asynchronous: true
            blur: true
            tint: true
            tintLevel: 0.65
            tintColor: root.colors.colSecondaryContainer
        }
    }

    Visualizer {
        active: Mem.options.mediaPlayer.showVisualizer && root.playing
        mode: Mem.options.mediaPlayer.visualizerMode
        visualizerColor: root.colors.colPrimary
    }

    ColumnLayout {
        id: content
        spacing: Padding.massive

        anchors {
            fill: parent
            margins: Padding.massive
        }

        Spacer {}
        PlayerSelector {}
        MediaPlayerControls {}
    }

    SpotifyLyrics {}
    BottomTracksDialog {}
    gradient: Gradient {
        GradientStop {
            color: "transparent"
            Anim on position {
                from: 0
                to: 0.95
                duration: Animations.durations.verylarge
            }
        }
        GradientStop {
            position: 0.05
            color: root.colors.colSecondaryContainer
            CAnim on color {
                from: "transparent"
                to: Mem.options.mediaPlayer.enableGrad ? root.colors.colSecondaryContainer : "transparent"
                duration: Animations.durations.small
            }
        }
    }
}
