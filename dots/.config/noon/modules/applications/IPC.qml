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

        function noon_view_pdf(): void {
            GlobalStates.applications.reader.show = true;
        // Mem.states.applications.reader.currentFile = file;
        }
        function noon_edit(file: string): void {
            GlobalStates.applications.editor.currentFile = file;
            open_editor();
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
