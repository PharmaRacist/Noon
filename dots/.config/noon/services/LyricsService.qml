pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import qs.common.functions
import qs.services

Singleton {
    id: root

    enum State {
        Idle,
        Loading,
        HasSyncedLyrics,
        HasPlainLyrics,
        NoLyricsFound,
        NetworkError
    }

    property int state: LyricsService.Idle
    property string lyrics: ""
    property var onlineLyricsData: null

    readonly property string cacheDir: Directories.beats.lyrics
    readonly property string userAgent: Mem.options.networking.userAgent

    property string _currentHash: ""
    property string _currentTitle: ""
    property string _currentArtist: ""

    function normalizeTitle(str) {
        return str ? str.replace(/\s*[\(\[].*?[\)\]]\s*/g, ' ').replace(/\s*-\s*(Official|Lyric|Audio|Video|Music Video|Visualizer|Remaster(?:ed)?)\s*$/gi, '').replace(/\s+/g, ' ').trim().toLowerCase() : "";
    }

    function normalizeArtist(str) {
        return str ? str.replace(/\s+(?:feat\.|featuring|ft\.|with|x|&)\s+.*/gi, '').replace(/\s*[\(\[].*?[\)\]]\s*/g, ' ').replace(/\s+/g, ' ').trim().toLowerCase() : "";
    }

    function getCacheFilePath(hash) {
        return `${cacheDir}/${hash}.json`;
    }

    function loadLyrics(data) {
        onlineLyricsData = data;
        if (data.syncedLyrics) {
            state = LyricsService.HasSyncedLyrics;
            lyrics = "Synced lyrics ready";
        } else if (data.plainLyrics) {
            state = LyricsService.HasPlainLyrics;
            lyrics = data.plainLyrics;
        } else {
            state = LyricsService.NoLyricsFound;
            lyrics = "No lyrics found for this song";
        }
    }

    function saveToCache(hash, data) {
        const filePath = getCacheFilePath(hash);
        shellExec.execute(`mkdir -p ${JSON.stringify(cacheDir)} && printf '%s' ${JSON.stringify(JSON.stringify(data))} > ${JSON.stringify(filePath)}`);
    }

    function fetchLyrics(title, artist) {
        if (!title || title === "No Title") {
            state = LyricsService.Idle;
            lyrics = "";
            return;
        }

        _currentTitle = title;
        _currentArtist = artist || "";
        _currentHash = Qt.md5(title + "|" + artist);

        state = LyricsService.Loading;
        lyrics = "Loading";

        shellExec.execute(`cat ${JSON.stringify(getCacheFilePath(_currentHash))} 2>/dev/null`, output => {
            if (output?.trim()) {
                try {
                    loadLyrics(JSON.parse(output));
                    return;
                } catch (e) {}
            }
            fetchFromAPI(0);
        });
    }

    function buildUrl(strategy) {
        const t = normalizeTitle(_currentTitle);
        const a = normalizeArtist(_currentArtist);
        const base = "https://lrclib.net/api/search";

        if (strategy === 0 && a)
            return `${base}?track_name=${encodeURIComponent(t)}&artist_name=${encodeURIComponent(a)}`;
        if (strategy === 1)
            return `${base}?q=${encodeURIComponent(t + " " + a)}`;
        if (strategy === 2)
            return `${base}?q=${encodeURIComponent(t)}`;
        return null;
    }

    function fetchFromAPI(strategy) {
        const url = buildUrl(strategy);
        if (!url) {
            state = LyricsService.NoLyricsFound;
            lyrics = "No lyrics found for this song";
            onlineLyricsData = null;
            return;
        }

        shellExec.execute(`curl -s -A ${JSON.stringify(userAgent)} ${JSON.stringify(url)}`, output => {
            try {
                const data = JSON.parse(output);
                if (data.statusCode >= 400) {
                    fetchFromAPI(strategy + 1);
                    return;
                }

                const result = Array.isArray(data) ? data[0] : data;
                if (result && (result.syncedLyrics || result.plainLyrics)) {
                    saveToCache(_currentHash, result);
                    loadLyrics(result);
                } else {
                    fetchFromAPI(strategy + 1);
                }
            } catch (e) {
                fetchFromAPI(strategy + 1);
            }
        }, () => {
            state = LyricsService.NetworkError;
            lyrics = "Network error occurred";
            onlineLyricsData = null;
        });
    }

    function getSyncedLyrics(position) {
        if (state !== LyricsService.HasSyncedLyrics || !onlineLyricsData?.syncedLyrics)
            return "";

        const lines = onlineLyricsData.syncedLyrics.split('\n');
        let currentLine = "";
        for (const line of lines) {
            const match = line.match(/\[(\d+):(\d+\.\d+)\](.*)/);
            if (match) {
                const timestamp = parseInt(match[1]) * 60 + parseFloat(match[2]);
                if (timestamp <= position)
                    currentLine = match[3].trim();
                else
                    break;
            }
        }
        return currentLine;
    }

    QtObject {
        id: shellExec

        property var queue: []
        property bool busy: false

        function execute(command, onSuccess, onError) {
            queue.push({
                command,
                onSuccess,
                onError
            });
            processQueue();
        }

        function processQueue() {
            if (busy || queue.length === 0)
                return;
            busy = true;
            const task = queue.shift();
            proc.command = ["sh", "-c", task.command];
            proc.userData = task;
            proc.running = true;
        }
    }

    Process {
        id: proc
        running: false
        property var userData: null

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (proc.userData?.onSuccess)
                    proc.userData.onSuccess(text);
                shellExec.busy = false;
                Qt.callLater(shellExec.processQueue);
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text?.trim() && proc.userData?.onError)
                    proc.userData.onError(text);
                shellExec.busy = false;
                Qt.callLater(shellExec.processQueue);
            }
        }
    }

    Timer {
        id: fetchDelayTimer
        interval: 50
        onTriggered: fetchLyrics(BeatsService.title, BeatsService.artist)
    }

    Connections {
        target: BeatsService
        function onTitleChanged() {
            fetchDelayTimer.restart();
        }
    }

    Component.onCompleted: {
        if (BeatsService.title)
            fetchLyrics(BeatsService.title, BeatsService.artist);
    }
}
