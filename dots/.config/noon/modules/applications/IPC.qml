import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.common
import qs.common.utils
import qs.common.functions

Scope {
    IpcHandler {
        id: ipc
        target: "apps"

        function noon_edit(file: string): void {
            open_editor();
            GlobalStates.applications.editor.currentFile = Qt.resolvedUrl(FileUtils.handleTelda(file));
        }
        function open_editor() {
            GlobalStates.applications.editor.show = true;
        }
        function open_mediaplayer() {
            GlobalStates.applications.mediaplayer.show = true;
        }
        function toggle_mediaplayer() {
            GlobalStates.applications.mediaplayer.show = !GlobalStates.applications.mediaplayer.show;
        }
    }
}
