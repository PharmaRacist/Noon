pragma Singleton
pragma ComponentBehavior: Bound
import qs.store
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.common.functions
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Qt.labs.folderlistmodel

Singleton {
    id: root

    property int selectedPlayerIndex: 0
    property list<string> excludedPlayers: [".mpd", "playerctld", "firefox", "chromium", "kdeconnect"]
    property string currentTrackPath: ""
    property var tracksMetadata: ({})

    readonly property QtObject colors: palette.colors
    readonly property bool filterPlayersEnabled: false
    readonly property bool _playing: player && player.playbackState === MprisPlaybackState.Playing
    readonly property string artUrl: player ? StringUtils.cleanMusicTitle(player.trackArtUrl) : ""
    readonly property string title: player ? StringUtils.cleanMusicTitle(player.trackTitle) : "No Title"
    readonly property string artist: player ? StringUtils.cleanMusicTitle(player.trackArtist) : "No Artist"
    property bool hasMetadata: false
    readonly property string _tracksDir: Qt.resolvedUrl(Mem.states.mediaPlayer?.currentTrackPath ?? Directories.beats.tracks)
    readonly property string _metadataPath: _tracksDir + "/.metadata"
    readonly property string _playlistPath: _tracksDir + "/.playlist.m3u"

    readonly property var tracksInfo: {
        const map = {};
        for (const key in root.tracksMetadata) {
            const entry = root.tracksMetadata[key];
            if (entry?.filename)
                map[entry.filename] = entry;
        }
        return map;
    }

    readonly property var tracksList: Object.values(root.tracksMetadata)

    readonly property var currentTrackMeta: {
        if (!root.currentTrackPath)
            return null;
        const fileName = root.currentTrackPath.split("/").pop();
        return root.tracksInfo[fileName] ?? null;
    }

    readonly property MprisPlayer player: {
        const list = meaningfulPlayers;
        if (!list || list.length === 0)
            return null;
        return list[Math.max(0, Math.min(selectedPlayerIndex, list.length - 1))] || null;
    }

    readonly property var meaningfulPlayers: {
        const source = Mpris.players.values;
        if (!source)
            return [];

        const map = new Map();
        for (let i = 0; i < source.length; i++) {
            const p = source[i];
            if (!p || !p.dbusName || p.dbusName === "" || !isRealPlayer(p))
                continue;

            const key = `${p.trackTitle || ""}|${p.trackArtist || ""}`.toLowerCase();
            if (!map.has(key)) {
                map.set(key, p);
            } else {
                const existing = map.get(key);
                if (p.trackArtUrl?.length > 0 && !(existing.trackArtUrl?.length > 0))
                    map.set(key, p);
            }
        }
        return Array.from(map.values());
    }

    function rebuildMetadata() {
        let cmd = ["python3", Directories.scriptsDir + "/build_metadata.py", FileUtils.trimFileProtocol(_tracksDir)];
        rebuildMetaProc.command = cmd;
        rebuildMetaProc.running = false;
        rebuildMetaProc.running = true;

        createPlaylistProc.running = false;
        createPlaylistProc.running = true;
    }

    function getTrackMeta(fileName) {
        return root.tracksInfo[fileName] ?? null;
    }

    function coverArtUrl(entry) {
        if (!entry?.cover_art)
            return "";
        return "file://" + root._tracksDir + "/" + entry.cover_art.replace(/^\.\//, "");
    }

    function initPlaylist() {
        NoonUtils.execDetached(`cvlc --one-instance --rc-fake-tty "${FileUtils.trimFileProtocol(root._playlistPath)}"`, true);
    }

    function playTrack(index) {
        vlcSocket.send("goto " + index);
    }

    function currentTrackProgressRatio() {
        const pos = player?.position ?? 0;
        const len = player?.length ?? 0;
        return len > 0 ? Math.max(0.0, Math.min(1.0, pos / len)) : 0.0;
    }

    function cycleRepeat() {
        const p = root.player;
        if (!p?.canControl)
            return;
        p.loopState = ({
                [MprisLoopState.None]: MprisLoopState.Playlist,
                [MprisLoopState.Playlist]: MprisLoopState.Track,
                [MprisLoopState.Track]: MprisLoopState.None
            })[p.loopState] ?? MprisLoopState.None;
    }

    function isRealPlayer(player) {
        if (!player || !player.dbusName)
            return false;
        if (!filterPlayersEnabled)
            return true;
        const name = player.dbusName.toLowerCase();
        return !excludedPlayers.some(p => name.includes(p.toLowerCase()));
    }

    function isCurrentPlayer() {
        return player?.desktopEntry?.toLowerCase() === "vlc";
    }

    function stopPlayer() {
        NoonUtils.execDetached("killall vlc");
    }

    function downloadCurrentSong() {
        downloadSong(root.title + " " + root.artist);
    }

    function downloadSong(query) {
        dlpProc.query = query;
        dlpProc.running = true;
    }

    function downloadByCommand(command) {
        dlpProc._cmd = command;
        dlpProc.running = true;
    }

    Process {
        id: dlpProc
        property string query
        property string _cmd

        command: _cmd ? ["bash", "-c", _cmd] : ["yt-dlp", "-f", "bestaudio", "--extract-audio", "--audio-format", "mp3", "--audio-quality", "0", "--embed-thumbnail", "--add-metadata", "-o", "%(artist,creator,uploader)s - %(title)s.%(ext)s", "-P", Directories.beats.downloads, `ytsearch1:${query}`]
        onStarted: NoonUtils.toast(`Started Downloading ${query}`, "download")
        onExited: exitCode => {
            exitCode === 0 ? NoonUtils.toast(`Downloaded ${query}`, "check", "success") : NoonUtils.toast(`Download failed ${query}`, "close", "error");
        }
    }

    Process {
        id: rebuildPlaylistProc
        command: ["bash", "-c", Directories.scriptsDir + `/create_playlist.sh ${FileUtils.trimFileProtocol(root._tracksDir)}`]
    }

    Process {
        id: rebuildMetaProc
        // onStarted: NoonUtils.toast("Started rebuilding metadata", "music_note")
        // onExited: exitCode => {
        //     exitCode === 0 ? NoonUtils.toast("Metadata rebuilt", "check", "success") : NoonUtils.toast("Metadata rebuild failed", "close", "error");
        // }
    }

    FileView {
        id: metadataFile
        path: root._metadataPath
        blockWrites: false
        onTextChanged: root.tracksMetadata = JSON.parse(metadataFile.text())
        onLoaded: root.hasMetadata = true
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                rebuildMetadata();
            }
        }
    }

    Socket {
        id: vlcSocket
        path: "/tmp/vlc.sock"
        connected: false

        parser: SplitParser {
            onRead: msg => console.log("vlc:", msg)
        }

        function send(cmd) {
            vlcSocket.write(cmd + "\n");
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: vlcSocket.connected = true
    }

    FolderListModel {
        folder: root._tracksDir
        showDirs: false
        showFiles: true
        onCountChanged: rebuildMetadata()
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
