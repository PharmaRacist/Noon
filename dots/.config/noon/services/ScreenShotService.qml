pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.common.utils

Singleton {
    id: root

    readonly property bool isBusy: mainProc.running

    signal screenshotCompleted

    function takeScreenShot() {
        if (!isBusy)
            mainProc.running = true;
    }

    Process {
        id: mainProc

        command: ["grimblast", "copy", "area"]
        onExited: exitCode => {
            if (exitCode === 0)
                root.screenshotCompleted();
        }
    }
}
