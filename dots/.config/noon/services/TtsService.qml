pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.common
import qs.common.utils

Singleton {
    id: root
    readonly property var opts: optsView.data

    function pronounce(text: string) {
        if (!text)
            return;
        mainProc.text = "";
        mainProc.running = false;
        mainProc.text = text;
        mainProc.running = true;
    }

    Process {
        id: mainProc
        property string text: ""
        command: ["uv", "--directory", Directories.venv, "run", Directories.scriptsDir + "/tts.py", text]
    }

    ConfigFileView {
        id: optsView
        fileName: "tts_config"
        state: false

        adapter: JsonAdapter {
            property string model: ""
            property string device: ""
        }
    }
}
