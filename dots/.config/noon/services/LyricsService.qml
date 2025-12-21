pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: lyricsService

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
    property string currentFetchArtist: ""
    property string currentFetchTitle: ""
    property var cacheIndex: [] // Array of {title, filename} objects

    function normalizeTitle(str) {
        if (!str)
            return "";
        return str.replace(/\s*[\(\[].*?[\)\]]\s*/g, ' ').replace(/\s*-\s*(Official|Lyric|Audio|Video|Music Video|Visualizer|Remaster(ed)?)\s*$/gi, '').replace(/\s+/g, ' ').trim().toLowerCase();
    }

    function normalizeArtist(str) {
        if (!str)
            return "";
        return str.replace(/\s+(feat\.|featuring|ft\.|with|x|&)\s+.*/gi, '').replace(/\s*[\(\[].*?[\)\]]\s*/g, ' ').replace(/\s+/g, ' ').trim().toLowerCase();
    }

    function sanitizeFilename(str) {
        // First try to transliterate or keep original if it's non-Latin
        // Remove only truly problematic characters for filenames
        return str.replace(/[\/\\:*?"<>|]/g, '_') // Remove filesystem-unsafe characters
        .replace(/\s+/g, '_') // Replace spaces with underscores
        .toLowerCase();
    }

    function getCacheFilePath(artist, title) {
        const normalizedArtist = normalizeArtist(artist);
        const normalizedTitle = normalizeTitle(title);
        const sanitizedArtist = sanitizeFilename(normalizedArtist);
        const sanitizedTitle = sanitizeFilename(normalizedTitle);
        return Directories.lyrics + "/" + sanitizedTitle + "_" + sanitizedArtist + ".json";
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

    function saveToCache(artist, title, data) {
        const filePath = getCacheFilePath(artist, title);
        const jsonString = JSON.stringify(data);
        ensureDirProc.command = ["mkdir", "-p", Directories.lyrics];
        ensureDirProc.running = true;
        saveCacheProc.command = ["sh", "-c", "printf '%s' " + JSON.stringify(jsonString) + " > " + JSON.stringify(filePath)];
        saveCacheProc.running = true;
        rebuildCacheIndex();
    }

    function getSyncedLyrics(position) {
        if (state !== LyricsService.HasSyncedLyrics || !onlineLyricsData || !onlineLyricsData.syncedLyrics) {
            return "";
        }
        const lines = onlineLyricsData.syncedLyrics.split('\n');
        let currentLine = "";
        for (let i = 0; i < lines.length; i++) {
            const match = lines[i].match(/\[(\d+):(\d+\.\d+)\](.*)/);
            if (match) {
                const minutes = parseInt(match[1]);
                const seconds = parseFloat(match[2]);
                const timestamp = minutes * 60 + seconds;
                const text = match[3].trim();
                if (timestamp <= position) {
                    currentLine = text;
                } else {
                    break;
                }
            }
        }
        return currentLine;
    }

    function extractTitleFromMetadata(title) {
        let normalized = normalizeTitle(title);

        // Split by dashes to handle "Artist - Title - Arabic" format
        const parts = normalized.split(/[\-–—]/).map(p => p.trim()).filter(p => p.length > 0);

        // Try multiple parts and return the first non-empty one
        const candidates = [];

        if (parts.length >= 2)
            candidates.push(parts[1]); // Second part (usually title)
        if (parts.length >= 1)
            candidates.push(parts[0]); // First part
        candidates.push(normalized); // Full normalized string as fallback

        // For each candidate, try both with and without non-Latin characters
        for (const candidate of candidates) {
            // Try Latin-only version first
            const latinOnly = candidate.replace(/[^\x00-\x7F]+/g, '').trim();
            if (latinOnly.length > 2)
                return latinOnly;

            // If no Latin characters, use the original (for pure Arabic/non-Latin titles)
            if (candidate.length > 0)
                return candidate;
        }

        return normalized;
    }

    function fuzzySearchCache(title) {
        if (cacheIndex.length === 0)
            return null;

        const searchTitle = extractTitleFromMetadata(title);
        const results = Fuzzy.go(searchTitle, cacheIndex, {
            key: 'title',
            threshold: -10000,
            limit: 1
        });

        return results && results.length > 0 ? results[0].obj.filename : null;
    }

    function rebuildCacheIndex() {
        listCacheProc.command = ["sh", "-c", "find " + JSON.stringify(Directories.lyrics) + " -name '*.json' -type f 2>/dev/null || true"];
        listCacheProc.running = true;
    }

    function fetchLyrics(artist, title) {
        if (!artist || !title) {
            state = LyricsService.Idle;
            lyrics = "";
            return;
        }
        currentFetchArtist = artist;
        currentFetchTitle = title;
        state = LyricsService.Loading;
        lyrics = "Loading";

        // Try exact match first
        const exactPath = getCacheFilePath(artist, title);
        readCacheProc.command = ["cat", exactPath];
        readCacheProc.running = true;
    }

    function fetchFromAPI() {
        const normalizedArtist = normalizeArtist(currentFetchArtist);
        const normalizedTitle = normalizeTitle(currentFetchTitle);
        onlineLyricsProc.command = ["curl", "-s", "-A", Mem.options.networking.userAgent, "-S", "https://lrclib.net/api/search?artist_name=" + encodeURI(normalizedArtist) + "&track_name=" + encodeURI(normalizedTitle)];
        onlineLyricsProc.running = true;
    }

    Connections {
        target: MusicPlayerService
        function onTitleChanged() {
            if (MusicPlayerService?.title) {
                fetchDelayTimer.restart();
            }
        }
        function onCurrentTrackProgressChanged() {
            if (state === LyricsService.HasSyncedLyrics) {
                const syncedLine = getSyncedLyrics(MusicPlayerService.currentTrackProgress);
                if (syncedLine && syncedLine !== lyrics) {
                    lyrics = syncedLine;
                }
            }
        }
    }

    Timer {
        id: fetchDelayTimer
        interval: 50
        repeat: false
        onTriggered: {
            lyricsService.fetchLyrics(MusicPlayerService.artist || "", MusicPlayerService.title || "");
        }
    }

    Component.onCompleted: {
        rebuildCacheIndex();
        if (MusicPlayerService?.title) {
            fetchLyrics(MusicPlayerService.artist || "", MusicPlayerService.title || "");
        }
    }

    Process {
        id: ensureDirProc
        running: false
    }

    Process {
        id: saveCacheProc
        running: false
    }

    Process {
        id: listCacheProc
        running: false
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (!text || text.trim() === "")
                    return;

                const files = text.trim().split('\n');
                const newIndex = [];

                files.forEach(filepath => {
                    if (!filepath)
                        return;

                    const filename = filepath.split('/').pop().replace('.json', '');
                    const parts = filename.split('_');

                    if (parts.length >= 2) {
                        // Last 2 parts are artist, rest is title
                        const titleParts = parts.length > 2 ? parts.slice(0, -2) : [parts[0]];
                        newIndex.push({
                            title: titleParts.join(' '),
                            filename: filepath
                        });
                    }
                });

                cacheIndex = newIndex;
            }
        }
    }

    Process {
        id: readCacheProc
        running: false
        property bool triedFuzzy: false

        onRunningChanged: if (running)
            triedFuzzy = false

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (text && text.trim() !== "") {
                    try {
                        const data = JSON.parse(text);
                        loadLyrics(data);
                        return;
                    } catch (e) {}
                }

                // Failed - try fuzzy search once
                if (!readCacheProc.triedFuzzy) {
                    readCacheProc.triedFuzzy = true;
                    const fuzzyMatch = fuzzySearchCache(currentFetchTitle);

                    if (fuzzyMatch) {
                        readCacheProc.command = ["cat", fuzzyMatch];
                        readCacheProc.running = true;
                        return;
                    }
                }

                // No cache found, fetch from API
                fetchFromAPI();
            }
        }
    }

    Process {
        id: onlineLyricsProc
        running: false
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data.statusCode) {
                        state = LyricsService.NetworkError;
                        lyrics = "Failed to connect to lyrics service";
                        onlineLyricsData = null;
                    } else if (Array.isArray(data)) {
                        if (data.length > 0) {
                            saveToCache(currentFetchArtist, currentFetchTitle, data[0]);
                            loadLyrics(data[0]);
                        } else {
                            state = LyricsService.NoLyricsFound;
                            lyrics = "No lyrics found for this song";
                            onlineLyricsData = null;
                        }
                    } else {
                        saveToCache(currentFetchArtist, currentFetchTitle, data);
                        loadLyrics(data);
                    }
                } catch (e) {
                    state = LyricsService.NetworkError;
                    lyrics = "Failed to retrieve lyrics";
                    onlineLyricsData = null;
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text && text.trim() !== "") {
                state = LyricsService.NetworkError;
                lyrics = "Network error occurred";
                onlineLyricsData = null;
            }
        }
    }
}
