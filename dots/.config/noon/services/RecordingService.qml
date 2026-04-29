pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

Singleton {
    id: root
    readonly property var store: Mem.states.services.record
    readonly property alias isRecording: mainProc.running
    property int targetDuration: 0
    property int recordingDuration: 0

    onRecordingDurationChanged: {
        if (!targetDuration)
            return;
        if (recordingDuration >= targetDuration)
            stop();
    }

    function stop() {
        targetDuration = 0;
        mainProc.running = false;
    }

    function record(opts = {
        duration: store.duration,
        fullscreen: store.fullscreen,
        sound: store.sound
    }) {
        if (!opts)
            return;
        let cmd = [Directories.scriptsDir + "/record_service.sh", "--dir", Directories.records];
        if (opts.duration)
            root.targetDuration = opts.duration;
        if (opts.fullscreen)
            cmd.push("--fullscreen");
        if (opts.sound)
            cmd.push("--sound");

        mainProc.running = false;
        mainProc.command = cmd;
        mainProc.running = true;
    }

    function getFormattedDuration() {
        const m = Math.floor(recordingDuration / 60).toString().padStart(2, "0");
        const s = (recordingDuration % 60).toString().padStart(2, "0");
        return `${m}:${s}`;
    }

    Process {
        id: mainProc
        onStarted: console.log(command.join(" "))
        onRunningChanged: {
            if (running)
                return;
            root.recordingDuration = 0;
            root.targetDuration = 0;
        }
    }

    Timer {
        interval: 1000
        running: root.isRecording
        repeat: true
        onTriggered: root.recordingDuration++
    }
}
