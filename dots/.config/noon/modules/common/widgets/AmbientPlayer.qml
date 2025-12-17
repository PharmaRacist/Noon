import QtQuick
import QtMultimedia

MediaPlayer {
    loops: MediaPlayer.Infinite
    audioOutput: AudioOutput {
        id: output
        muted: false
    }
}
