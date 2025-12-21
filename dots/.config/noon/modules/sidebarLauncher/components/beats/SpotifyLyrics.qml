import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import qs.modules.common.widgets
import qs.services
import qs.modules.common
import qs.modules.common.functions

Item {
    id: root
    z: -1
    anchors.fill: parent
    property real scale: (parent.height + parent.width) / 1000
    property color mainColor: TrackColorsService.colors.colPrimary
    property var syncedLines: []
    property var plainLines: []
    property var displayLines: syncedLines.length > 0 ? syncedLines : plainLines
    property bool loading: state === LyricsService.Loading
    property bool hasError: state === LyricsService.NetworkError
    property bool noLyricsFound: state === LyricsService.NoLyricsFound
    property var state: LyricsService.state
    property int coverArtSize: 220
    property int currentLineIndex: {
        if (!displayLines || displayLines.length === 0)
            return -1;
        if (syncedLines.length === 0)
            return -1; // No highlight for plain lyrics
        let idx = 0;
        for (let i = 0; i < displayLines.length; i++) {
            if (MusicPlayerService.currentTrackProgress >= displayLines[i].lineTime)
                idx = i;
            else
                break;
        }
        return idx;
    }

    onStateChanged: reveal()

    function reveal() {
        Qt.callLater(() => revealer.reveal = true);
        revealTimeoutTimer.restart();
    }

    function parseSyncedLyrics(text) {
        if (!text)
            return [];
        return text.split("\n").map(line => {
            const match = line.match(/\[(\d+):(\d+\.\d+)\](.*)/);
            if (match)
                return {
                    lineTime: parseInt(match[1]) * 60 + parseFloat(match[2]),
                    lineText: match[3].trim()
                };
            return null;
        }).filter(l => l !== null);
    }

    function parsePlainLyrics(text) {
        if (!text)
            return [];
        return text.split("\n").map(line => ({
                    lineTime: 0,
                    lineText: line.trim()
                })).filter(l => l.lineText !== "");
    }

    Connections {
        target: LyricsService
        function onOnlineLyricsDataChanged() {
            if (!LyricsService.onlineLyricsData) {
                root.syncedLines = [];
                root.plainLines = [];
                return;
            }
            if (LyricsService.onlineLyricsData?.syncedLyrics) {
                root.syncedLines = parseSyncedLyrics(LyricsService.onlineLyricsData.syncedLyrics);
                root.plainLines = [];
            } else if (LyricsService.onlineLyricsData?.plainLyrics) {
                root.syncedLines = [];
                root.plainLines = parsePlainLyrics(LyricsService.onlineLyricsData.plainLyrics);
            } else {
                root.syncedLines = [];
                root.plainLines = [];
            }
        }
    }

    Component.onCompleted: {
        if (LyricsService.onlineLyricsData?.syncedLyrics)
            root.syncedLines = parseSyncedLyrics(LyricsService.onlineLyricsData.syncedLyrics);
        else if (LyricsService.onlineLyricsData?.plainLyrics)
            root.plainLines = parsePlainLyrics(LyricsService.onlineLyricsData.plainLyrics);
    }

    RippleButton {
        id: floatRect
        z: 1
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Padding.verylarge
        altAction: LyricsService.fetchFromAPI()
        onClicked: {
            if (root.hasError)
                LyricsService.fetchLyrics(MusicPlayerService.artist || "", MusicPlayerService.title || "");
            else
                revealer.reveal = !revealer.reveal;
        }
        colBackground: TrackColorsService.colors.colSecondaryContainer
        buttonRadius: Rounding.verylarge
        implicitHeight: 40
        implicitWidth: floatingRecRow.implicitWidth + 2 * Padding.large
        clip: true

        Timer {
            id: revealTimeoutTimer
            interval: 1000
            onTriggered: Qt.callLater(() => revealer.reveal = false)
        }

        contentItem: RowLayout {
            id: floatingRecRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Padding.large
            anchors.rightMargin: Padding.large
            spacing: Padding.normal

            Revealer {
                id: revealer
                clip: true
                visible: reveal
                reveal: floatRect.showTitle || root.hasError || root.noLyricsFound

                StyledText {
                    color: icon.color
                    text: switch (root.state) {
                    case LyricsService.Loading:
                        return "Loading";
                    case LyricsService.Idle:
                        return "Enjoy";
                    case LyricsService.NetworkError:
                        return "Network error";
                    case LyricsService.NoLyricsFound:
                        return "No lyrics";
                    case LyricsService.HasSyncedLyrics:
                        return "Synced";
                    case LyricsService.HasPlainLyrics:
                        return "Plain";
                    default:
                        return "Enjoy";
                    }
                    font.pixelSize: Fonts.sizes.normal
                    animateChange: true
                }
            }

            MaterialSymbol {
                id: icon
                fill: 1
                Layout.alignment: Qt.AlignCenter
                color: {
                    if (root.hasError)
                        return Colors.m3.m3error;
                    if (root.noLyricsFound)
                        return TrackColorsService.colors.colTertiary;
                    return TrackColorsService.colors.colSecondary;
                }
                font.pixelSize: Fonts.sizes.normal
                text: switch (root.state) {
                case LyricsService.Idle:
                    return "bedtime";
                case LyricsService.NetworkError:
                    return "cloud_off";
                case LyricsService.NoLyricsFound:
                    return "music_off";
                case LyricsService.Loading:
                    return "hourglass_empty";
                default:
                    return "lyrics";
                }
            }
        }
    }

    MaterialLoadingIndicator {
        anchors.centerIn: parent
        visible: loading
        loading: root.loading
        implicitSize: 240
        color: TrackColorsService.colors.colPrimary
        shapeColor: TrackColorsService.colors.colOnPrimary
    }
    Loader {
        id: coverArtLoader
        height: root.coverArtSize
        width: root.coverArtSize
        anchors.centerIn: parent
        active: !root.loading && displayLines.length === 0
        visible: active
        sourceComponent: MusicCoverArt {
            anchors.fill: parent
            clip: false
            enableShadows: false
            enableBorders: false
            // RectangularShadow {
            //     z: -9999
            //     anchors.fill: parent
            //     radius: parent?.radius
            //     opacity: 0.4
            //     offset.x: -5
            //     offset.y: -2
            //     blur: 70
            //     spread: 5
            //     color: TrackColorsService.gradColor
            // }
        }
    }
    // PagePlaceholder {
    //     shown: !root.loading && displayLines.length === 0
    //     anchors.centerIn: parent
    //     iconSize: 180
    //     colBackground: TrackColorsService.colors.colLayer0
    //     colOnBackground: TrackColorsService.colors.colOnLayer0
    //     icon: root.hasError ? "cloud_off" : "music_off"
    //     shape: MaterialShape.Cookie7Sided
    //     title: {
    //         if (root.hasError)
    //             return "Failed to load lyrics";
    //         if (root.noLyricsFound)
    //             return "No lyrics available";
    //         return "No lyrics";
    //     }
    // }

    StyledFlickable {
        id: flick
        visible: !root.loading && displayLines.length > 0
        anchors.fill: parent
        anchors.leftMargin: Padding.verylarge
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: false
        Column {
            id: column
            width: parent.width
            spacing: 22
            height: displayLines.length * 60 * root.scale + (displayLines.length - 1) * spacing

            Repeater {
                model: displayLines.length
                delegate: Item {
                    width: parent.width
                    height: textItem.implicitHeight

                    StyledText {
                        id: textItem
                        width: parent.width
                        font.family: "Rubik"
                        font.variableAxes: Fonts.variableAxes.lyrics
                        text: displayLines[index].lineText
                        font.pixelSize: index === root.currentLineIndex ? Fonts.sizes.title * root.scale : Fonts.sizes.verylarge * root.scale

                        Behavior on font.pixelSize {
                            Anim {}
                        }

                        // Use synced verse color for plain text too
                        color: TrackColorsService.colors.colOnLayer2
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.Wrap

                        opacity: {
                            const distance = Math.abs(index - root.currentLineIndex);
                            const maxDistance = 4;
                            return Math.max(0.2, 1 - distance / maxDistance);
                        }

                        Behavior on opacity {
                            Anim {}
                        }
                    }
                }
            }
        }

        Timer {
            interval: 25
            running: true
            repeat: true
            onTriggered: {
                if (currentLineIndex >= 0 && column.height > flick.height) {
                    const lineItem = column.children[currentLineIndex];
                    if (lineItem) {
                        const targetY = lineItem.y - flick.height / 2 + lineItem.height / 2;
                        flick.contentY += (targetY - flick.contentY) * 0.4;
                    }
                }
            }
        }
    }
}
