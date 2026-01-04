pragma Singleton
import qs.store
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.common.functions
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Qt.labs.folderlistmodel

Singleton {
    id: root

    readonly property QtObject colors: palette.colors
    readonly property bool filterPlayersEnabled: false
    readonly property int selectedPlayerIndex: Mem.states.services.mediaPlayer.selectedPlayerIndex
    readonly property string artUrl: StringUtils.cleanMusicTitle(player.trackArtUrl)
    readonly property string title: StringUtils.cleanMusicTitle(player.trackTitle)
    readonly property string artist: StringUtils.cleanMusicTitle(player.trackArtist)
    readonly property bool _playing: player.playbackState === MprisPlaybackState.Playing
    readonly property MprisPlayer player: {
        if (!meaningfulPlayers || meaningfulPlayers.length === 0)
            return null;
        const validIndex = Math.max(0, Math.min(selectedPlayerIndex, meaningfulPlayers.length - 1));
        return meaningfulPlayers[validIndex];
    }

    readonly property var meaningfulPlayers: filterDuplicatePlayers(Mpris.players.values.filter(player => isRealPlayer(player)))
    property list<string> excludedPlayers: [".mpd", "org.mpris.MediaPlayer2.", "org.mpris.MediaPlayer2.playerctld", "org.mpris.MediaPlayer2.firefox", "MediaPlayer2.mpd"]

    property string currentTrackPath: ""
    readonly property alias tracksModel: tracksModel

    function isRealPlayer(player) {
        if (!filterPlayersEnabled)
            return true;
        if (!player || !player.dbusName)
            return false;
        return !excludedPlayers.some(pattern => player.dbusName.includes(pattern));
    }

    function filterDuplicatePlayers(players) {
        if (!players || players.length === 0)
            return [];

        const trackMap = new Map();

        // Group by track
        for (let i = 0; i < players.length; i++) {
            const p = players[i];
            const key = `${p.trackTitle?.toLowerCase() || ''}|${p.trackArtist?.toLowerCase() || ''}`;

            if (!trackMap.has(key)) {
                trackMap.set(key, []);
            }
            trackMap.get(key).push(i);
        }

        // Choose best from each group
        const filtered = [];
        trackMap.forEach(indices => {
            let best = indices.find(idx => players[idx].trackArtUrl?.length > 0) ?? indices[0];
            filtered.push(players[best]);
        });

        return filtered;
    }

    // Track info functions
    function getTrackInfo(index) {
        if (index < 0 || index >= tracksModel.count) {
            return null;
        }

        const fileName = tracksModel.get(index, "fileName") || "";
        const fileUrl = tracksModel.get(index, "fileUrl") || "";
        const baseName = tracksModel.get(index, "baseName") || "";
        const fileUrlStr = fileUrl.toString();

        return {
            name: baseName || fileName.replace(/\.[^/.]+$/, ""),
            path: fileUrlStr.startsWith("file://") ? decodeURIComponent(fileUrlStr.substring(7)) : fileUrlStr,
            fileUrl: fileUrlStr,
            fileName: fileName
        };
    }

    function currentTrackProgressRatio() {
        const pos = player?.position ?? 0;
        const len = player?.length ?? 0;
        if (len <= 0)
            return 0.0;
        return Math.max(0.0, Math.min(1.0, pos / len));
    }

    function playTrackByPath(filePath) {
        if (!filePath || tracksModel.count === 0)
            return;

        const cleanFilePath = FileUtils.trimFileProtocol(filePath);
        Mem.states.mediaPlayer.currentTrackPath = filePath;

        const allPaths = [];
        for (let i = 0; i < tracksModel.count; ++i) {
            const url = tracksModel.get(i, "fileUrl");
            if (url && url.toString().startsWith("file://")) {
                allPaths.push(decodeURIComponent(url.toString().substring(7)));
            }
        }

        const startIndex = allPaths.indexOf(cleanFilePath);
        if (startIndex === -1)
            return;

        const reordered = allPaths.slice(startIndex).concat(allPaths.slice(0, startIndex));
        const joined = reordered.map(p => `'${p.replace(/'/g, `'\\''`)}'`).join(" ");
        // No Killall Needed ;)
        Noon.execDetached(`cvlc --one-instance --play-and-exit ${joined}`);
    }

    function cycleRepeat() {
        const p = root.player;
        if (!p?.canControl)
            return;

        let nextState;
        switch (p.loopState || MprisLoopState.None) {
        case MprisLoopState.None:
            nextState = MprisLoopState.Playlist;
            break;
        case MprisLoopState.Playlist:
            nextState = MprisLoopState.Track;
            break;
        case MprisLoopState.Track:
            nextState = MprisLoopState.None;
            break;
        default:
            nextState = MprisLoopState.None;
        }
        p.loopState = nextState;
    }

    function isCurrentPlayer() {
        return player && player.desktopEntry && player.desktopEntry.toLowerCase() === "vlc";
    }
    function stopPlayer() {
        Noon.execDetached("killall vlc");
    }
    function downloadCurrentSong() {
        let cleanedTitle = root.title + " " + root.artist;
        if (cleanedTitle)
            downloadSong(cleanedTitle);
    }
    function downloadSong(query) {
        dlpProc.query = query;
        dlpProc.running = true;
    }

    Process {
        id: dlpProc
        property string query
        command: ["bash", "-c", `yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -P ~/Music 'ytsearch1:${query}'`]
        onStarted: {
            Noon.notify(`Downloading: ${query}`);
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                Noon.notify(`Downloaded: ${query}`);
            } else {
                Noon.notify(`Download failed: ${query}`);
            }
        }
    }

    FolderListModel {
        id: tracksModel
        folder: Qt.resolvedUrl(Directories.beats.tracks)
        nameFilters: NameFilters.audio
        showDirs: false
        showFiles: true
        sortField: FolderListModel.Name
    }

    Timer {
        id: positionTimer
        interval: 100
        repeat: true
        running: root.player && root._playing
        onTriggered: root.player.positionChanged()
    }
    SourceDownloader {
        id: coverFetch
        active: root.artUrl.startsWith("http") || root.artUrl.startsWith("https")
        input: BeatsService.artUrl
    }
    PaletteGenerator {
        id: palette
        active: root._playing && Mem.options.mediaPlayer.adaptiveTheme
        source: coverFetch.output || root.artUrl
    }
}
