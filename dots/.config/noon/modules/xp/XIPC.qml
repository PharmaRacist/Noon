import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import qs.services
import qs.store

IpcHandler {
    target: "xp"

    function toggle_run() {
        GlobalStates.xp.showRun = !GlobalStates.xp.showRun;
    }
    function toggle_settings() {
        GlobalStates.xp.showControlPanel = !GlobalStates.xp.showControlPanel;
    }
    function toggle_start_menu() {
        GlobalStates.xp.showStartMenu = !GlobalStates.xp.showStartMenu;
    }
}
