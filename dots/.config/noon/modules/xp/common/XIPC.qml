import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.common
import qs.common.functions
import qs.common.utils
import qs.common.widgets
import qs.modules.main.view
import qs.services
import qs.store

Scope {
    IpcHandler {
        function toggle_ai_bar() {
            GlobalStates.xp.startMenu.visible = !GlobalStates.xp.startMenu.visible;
        }

        target: "global"
    }

}
