pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.common.functions

Singleton {
    id: root
    readonly property var hits: Mem.states.services.beats.hits
    readonly property bool isBusy: fetchProc.running

    function request(limit = 10) {
        fetchProc.command = ["uv", "--directory", Directories.venv, "run", Directories.scriptsDir + "/hits_service.py", "--limit", limit, FileUtils.trimFileProtocol(BeatsService._metadataPath)];
        fetchProc.running = true;
    }
    function refresh(limit) {
        Mem.states.services.beats.hits = [];
        Qt.callLater(() => request(limit));
    }
    Process {
        id: fetchProc
        stdout: StdioCollector {
            onStreamFinished: {
                const out = JSON.parse(text.trim());
                if (out.length > 0)
                    Mem.states.services.beats.hits = [...Mem.states.services.beats.hits, ...out];
            }
        }
    }
}
