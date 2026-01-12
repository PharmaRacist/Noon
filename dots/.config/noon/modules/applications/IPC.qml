import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.common
import qs.common.utils

Scope {
    IpcHandler {
        id: ipc
        target: "apps"

        function open_mediaplayer() {
            GlobalStates.applications.mediaplayer.show = true;
        }
        function toggle_mediaplayer() {
            GlobalStates.applications.mediaplayer.show = !GlobalStates.applications.mediaplayer.show;
        }
    }
}
