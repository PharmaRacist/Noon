pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool isBusy: mainProc.running
    signal screenshotCompleted

    Process {
        id: mainProc
        command: ["hyprshot", "--freeze", "--clipboard-only", "--mode", "region", "--silent"]
        onExited: exitCode => {
            if (exitCode === 0) {
                root.screenshotCompleted();
            }
        }
    }

    function takeScreenShot() {
        if (!isBusy) {
            mainProc.running = true;
        }
    }
}
