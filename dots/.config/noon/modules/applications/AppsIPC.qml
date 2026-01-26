import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.common
import qs.common.utils
import qs.common.functions
import "mediaplayer"
import "editor"
import "reader"
import "settings"

Scope {
    id: root
    readonly property Component settings: Settings {}
    readonly property Component reader: PDFReader {}
    readonly property Component editor: Editor {}
    readonly property Component mediaplayer: MediaPlayer {}

    IpcHandler {
        id: ipc
        target: "apps"

        function settings() {
            root.settings.createObject(root);
        }
        function pdf() {
            root.reader.createObject(root);
        }
        function editor() {
            root.editor.createObject(root);
        }
        function edit(file: string): void {
            GlobalStates.applications.editor.currentFile = file;
            root.editor.createObject(root);
        }
        function media() {
            root.mediaplayer.createObject(root);
        }
    }
}
