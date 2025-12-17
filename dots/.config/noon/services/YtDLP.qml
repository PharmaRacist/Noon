import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: ytDLP
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string downloadDir: FileUtils.trimFileProtocol(Directories.music)
    readonly property string cleanedTitle: StringUtils.cleanMusicTitle(activePlayer?.trackTitle + " " + activePlayer?.trackArtist)

    // The enum definition itself is correct
    enum State {
        Idle,
        Starting,
        Downloading,
        Succeeded,
        Failed
    }

    // Initialize with the correct reference
    property int state: YtDLP.State.Idle
    property string currentQuery: ""

    Process {
        id: downloadProcess
        // Correctly reference the enum values
        onStarted: YtDLP.state = State.Downloading
        onExited: function (exitCode, exitStatus) {
            YtDLP.state = exitCode === 0 ? State.Succeeded : State.Failed;
        }
    }

    function isBusy() {
        return state === State.Starting || state === State.Downloading;
    }

    function downloadCurrentSong() {
        if (cleanedTitle && !isBusy()) {
            downloadSong(cleanedTitle);
        }
    }

    function downloadSong(query) {
        if (isBusy())
            return;
        currentQuery = query;
        const cmd = `notify-send "YouTube Music Downloader" "Downloading: ${query}..." && cd "${downloadDir}" && (yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata "ytsearch1:${query}" && notify-send "YouTube Music Downloader" "Downloaded: ${query}" || (notify-send "YouTube Music Downloader" "Download failed: ${query}" && exit 1))`;
        state = State.Starting;
        downloadProcess.command = ["bash", "-c", cmd];
        downloadProcess.start();
    }

    function downloadVideo(query) {
        if (isBusy())
            return;
        currentQuery = query;
        const cmd = `notify-send "YouTube Video Downloader" "Downloading: ${query}..." && cd "${downloadDir}" && (yt-dlp -f "best[height<=720]" --embed-subs --add-metadata "ytsearch1:${query}" && notify-send "YouTube Video Downloader" "Downloaded video: ${query}" || (notify-send "YouTube Video Downloader" "Download failed: ${query}" && exit 1))`;
        state = State.Starting;
        downloadProcess.command = ["bash", "-c", cmd];
        downloadProcess.start();
    }
}
