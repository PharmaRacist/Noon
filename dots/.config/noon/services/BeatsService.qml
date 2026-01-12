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

    property int selectedPlayerIndex: 0
    readonly property QtObject colors: palette.colors
    readonly property bool filterPlayersEnabled: true

    readonly property string artUrl: player ? StringUtils.cleanMusicTitle(player.trackArtUrl) : ""
    readonly property string title: player ? StringUtils.cleanMusicTitle(player.trackTitle) : "No Title"
    readonly property string artist: player ? StringUtils.cleanMusicTitle(player.trackArtist) : "No Artist"
    readonly property bool _playing: player && player.playbackState === MprisPlaybackState.Playing

    readonly property MprisPlayer player: {
        const list = meaningfulPlayers;
        if (!list || list.length === 0)
            return null;
        const validIndex = Math.max(0, Math.min(selectedPlayerIndex, list.length - 1));
        return list[validIndex] || null;
    }

    readonly property var meaningfulPlayers: {
        const source = Mpris.players.values;
        if (!source)
            return [];

        const bestPlayersMap = new Map();

        for (let i = 0; i < source.length; i++) {
            const p = source[i];

            // Fix: Strict DBus and Validity Check
            if (!p || !p.dbusName || p.dbusName === "" || !isRealPlayer(p))
                continue;

            const t = p.trackTitle || "";
            const a = p.trackArtist || "";
            const key = `${t}|${a}`.toLowerCase();

            if (!bestPlayersMap.has(key)) {
                bestPlayersMap.set(key, p);
            } else {
                const existing = bestPlayersMap.get(key);
                const hasArt = p.trackArtUrl && p.trackArtUrl.length > 0;
                const existingHasArt = existing.trackArtUrl && existing.trackArtUrl.length > 0;

                if (hasArt && !existingHasArt) {
                    bestPlayersMap.set(key, p);
                }
            }
        }
        return Array.from(bestPlayersMap.values());
    }

    // Fix: Removed generic "org.mpris.MediaPlayer2." to prevent hiding all players
    property list<string> excludedPlayers: [".mpd", "playerctld", "firefox", "chromium", "kdeconnect"]

    property string currentTrackPath: ""
    readonly property alias tracksModel: tracksModel

    function isRealPlayer(player) {
        if (!player || !player.dbusName)
            return false;
        if (!filterPlayersEnabled)
            return true;
        const name = player.dbusName.toLowerCase();
        return !excludedPlayers.some(pattern => name.includes(pattern.toLowerCase()));
    }

    function getTrackInfo(index) {
        if (index < 0 || index >= tracksModel.count)
            return null;

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
        Noon.execDetached(`cvlc --one-instance --play-and-exit ${joined}`);
    }

    function cycleRepeat() {
        const p = root.player;
        if (!p?.canControl)
            return;

        const nextState = {
            [MprisLoopState.None]: MprisLoopState.Playlist,
            [MprisLoopState.Playlist]: MprisLoopState.Track,
            [MprisLoopState.Track]: MprisLoopState.None
        }[p.loopState] ?? MprisLoopState.None;

        p.loopState = nextState;
    }

    function isCurrentPlayer() {
        return player && player.desktopEntry && player.desktopEntry.toLowerCase() === "vlc";
    }

    function stopPlayer() {
        Noon.execDetached("killall vlc");
    }

    function downloadCurrentSong() {
        downloadSong(root.title + " " + root.artist);
    }

    function downloadSong(query) {
        dlpProc.query = query;
        dlpProc.running = true;
    }

    Process {
        id: dlpProc
        property string query
        command: ["bash", "-c", `yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -P "${Directories.beats.downloads}" 'ytsearch1:${query.replace(/'/g, "")}'`]

        onStarted: Noon.notify(`Started Downloading: ${query}`)
        onExited: exitCode => {
            exitCode === 0 ? Noon.notify(`Downloaded: ${query}`) : Noon.notify(`Download failed: ${query}`);
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
        input: root.artUrl
    }

    PaletteGenerator {
        id: palette
        active: root._playing && Mem.options.mediaPlayer.adaptiveTheme
        source: coverFetch.output || root.artUrl
    }
}
