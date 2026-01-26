import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import qs.common.functions

Scope {
    id: root
    IpcHandler {
        id: ipc
        target: "nobuntu"
        function toggle_db() {
            GlobalStates.nobuntu.db.show = !GlobalStates.nobuntu.db.show;
        }
        function toggle_overview() {
            GlobalStates.nobuntu.overview.show = !GlobalStates.nobuntu.overview.show;
        }
        function toggle_notifs() {
            GlobalStates.nobuntu.notifs.show = !GlobalStates.nobuntu.notifs.show;
        }
    }
}
