import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Quickshell.Hyprland

Item {
    id: root
    implicitHeight: mediaControls.height
    implicitWidth: mediaControls.width

    property bool showDownload: true
    readonly property MprisPlayer player: MusicPlayerService.player

    RowLayout {
        id: mediaControls
        spacing: Padding.small


        DockMediaButton {
            iconName: "shuffle"
            enabled: !!root.player && root.player.canControl
            opacity: root.player ? 1 : 0.5
            isToggled: root.player ? root.player.shuffle : false
            onClicked: {
                if (root.player?.canControl)
                    root.player.shuffle = !root.player.shuffle;
            }
        }

        DockMediaButton {
            iconName: "skip_previous"
            enabled: !!root.player && root.player.canGoPrevious
            opacity: root.player?.canGoPrevious ? 1 : 0.5
            onClicked: {
                if (root.player?.canGoPrevious)
                    root.player.previous();
            }
        }

        RippleButton {
            implicitWidth: root.player && root.player.playbackState === MprisPlaybackState.Playing ? 80 : 40
            implicitHeight: 40
            buttonRadius: 16
            Layout.rightMargin: 6
            Layout.leftMargin: 6
            enabled: true
            opacity: root.player?.canPause ? 1 : 0.5

            colBackground: root.player && root.player.playbackState === MprisPlaybackState.Playing ? TrackColorsService.colors.colPrimary : TrackColorsService.colors.colSecondaryContainer
            colBackgroundHover: root.player && root.player.playbackState === MprisPlaybackState.Playing ? TrackColorsService.colors.colPrimaryHover : TrackColorsService.colors.colSecondaryContainerHover
            colRipple: root.player && root.player.playbackState === MprisPlaybackState.Playing ? TrackColorsService.colors.colPrimaryActive : TrackColorsService.colors.colSecondaryContainerActive

            onClicked: {
                if (root.player?.canPause)
                    root.player.togglePlaying();
                else
                    GlobalStates.playlistOpen = true;
            }

            Behavior on buttonRadius {
                Anim {}
            }

            Behavior on implicitWidth {
                Anim {}
            }

            contentItem: MaterialSymbol {
                font.pixelSize: Fonts.sizes.normal
                fill: 1
                horizontalAlignment: Text.AlignHCenter
                color: root.player && root.player.playbackState === MprisPlaybackState.Playing ? TrackColorsService.colors.colOnPrimary : TrackColorsService.colors.colOnSecondaryContainer
                text: root.player && root.player.playbackState === MprisPlaybackState.Playing ? "pause" : "play_arrow"
            }
        }

        DockMediaButton {
            iconName: "skip_next"
            enabled: !!root.player && root.player.canGoNext
            opacity: root.player?.canGoNext ? 1 : 0.5
            onClicked: {
                if (root.player?.canGoNext)
                    root.player.next();
            }
        }

        DockMediaButton {
            iconName: {
                switch (root.player?.loopState) {
                case MprisLoopState.Track:
                    return "repeat_one";
                case MprisLoopState.Playlist:
                    return "repeat";
                default:
                    return "repeat";
                }
            }
            enabled: !!root.player && root.player.canControl
            opacity: root.player ? 1 : 0.5
            isToggled: root.player ? root.player.loopState !== MprisLoopState.None : false

            onClicked: MusicPlayerService.cycleRepeat()
            StyledToolTip {
                content: {
                    switch (root.player?.loopState) {
                    case MprisLoopState.Track:
                        return "Repeat Track";
                    case MprisLoopState.Playlist:
                        return "Repeat Playlist";
                    default:
                        return "Repeat Off";
                    }
                }
            }
        }

        DockMediaButton {
            visible: MusicPlayerService.isCurrentPlayer()
            iconName: "close"
            enabled: true
            opacity: 1
            onClicked: MusicPlayerService.stopPlayer()
        }

        DockMediaButton {
            visible: root.showDownload && !MusicPlayerService.isCurrentPlayer()
            iconName: "download"
            enabled: !YtDLP.isDownloading
            opacity: 1
            onClicked: MusicPlayerService.downloadCurrentSong()
        }
    }
    component DockMediaButton: RippleButton {
        id: root
        implicitWidth: 30
        implicitHeight: 30
        buttonRadius: 99
        property color contentColor: isToggled ? TrackColorsService.colors.colOnPrimary : TrackColorsService.colors.colOnSecondaryContainer
        property string iconName: ""
        property bool isToggled: false

        colBackground: isToggled ? TrackColorsService.colors.colPrimary : TrackColorsService.colors.colSecondaryContainer
        colBackgroundHover: isToggled ? TrackColorsService.colors.colPrimaryHover : TrackColorsService.colors.colSecondaryContainerHover
        colRipple: isToggled ? TrackColorsService.colors.colSecondaryContainer : TrackColorsService.colors.colSecondaryContainerActive

        contentItem: MaterialSymbol {
            fill: 1
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            color: root.contentColor
            text: iconName
        }
    }
}
