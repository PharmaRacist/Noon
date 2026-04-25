import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root

    property var songData

    readonly property bool _playing: player?.playbackState === MprisPlaybackState.Playing
    readonly property var player: {
        if (!songData?.url)
            return;
        return BeatsService?.meaningfulPlayers?.find(p => p.metadata["xesam:url"] === normalizeUrl(songData.url));
    }

    clip: true
    radius: Rounding.verylarge
    color: "transparent"

    function normalizeUrl(inputUrl) {
        let url = new URL(inputUrl);
        let params = new URLSearchParams(url.search);
        if (url.hostname.includes("music.youtube.com"))
            url.hostname = "www.youtube.com";
        if (params.has("list"))
            params.set("list", params.get("list").replace(/^VL/, ""));
        url.search = params.toString();
        return url.toString();
    }

    onSongDataChanged: Qt.callLater(() => {
        if (!player)
            BeatsService.previewURL(root.songData.url);
    })

    Visualizer {
        z: 0
        active: true
    }

    RowLayout {
        z: 1
        anchors.fill: parent
        spacing: Padding.massive

        MusicCoverArt {
            implicitSize: 136
            source: songData?.thumbnail ?? ""
        }

        ColumnLayout {
            Layout.fillWidth: true

            StyledText {
                font.weight: 800
                font.pixelSize: Fonts.sizes.large
                Layout.fillWidth: true
                truncate: true
                wrapMode: Text.Wrap
                maximumLineCount: 3
                text: songData?.title ?? "No Title"
            }

            StyledText {
                font.pixelSize: Fonts.sizes.verysmall
                Layout.fillWidth: true
                text: songData?.artist ?? "No Artist"
                color: Colors.colSubtext
            }

            ButtonGroup {
                Layout.topMargin: Padding.large
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                Layout.fillWidth: false
                Layout.fillHeight: false

                Repeater {
                    model: [
                        {
                            icon: "close",
                            action: () => root.dismiss()
                        },
                        {
                            icon: "download",
                            action: () => {
                                BeatsService.downloadSong(songData?.url);
                                root.dismiss();
                            }
                        },
                        {
                            toggled: root._playing,
                            icon: (!root.player?.metadata["xesam:artist"] || !root.player?.trackArtist) ? "circle_circle" : root._playing ? "pause" : "play_arrow",
                            action: () => root.player?.togglePlaying()
                        }
                    ]

                    delegate: GroupButtonWithIcon {
                        baseSize: 45
                        buttonRadius: Rounding.small
                        buttonRadiusPressed: Rounding.large
                        toggled: modelData?.toggled ?? false
                        materialIcon: modelData.icon
                        releaseAction: () => modelData.action()
                    }
                }
            }
        }
    }
}
