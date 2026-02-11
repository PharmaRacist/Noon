import QtQuick
import Noon.Services
import Quickshell
import Quickshell.Services.Mpris
import qs.common
import qs.common.utils
import qs.modules.main.view
import qs.common.functions
import qs.common.widgets
import qs.services
import qs.store

Scope {
    IpcHandler {
        target: "noon"
        function expose(show: bool) {
            if (show) {
                GlobalStates.main.exposeView = true;
            } else if (!show) {
                GlobalStates.main.exposeView = false;
            }
        }
        function toggle_beam() {
            GlobalStates.main.showBeam = !GlobalStates.main.showBeam;
        }

        function toggle_bar_mode() {
            Mem.options.bar.behavior.position = BarData.cyclePosition();
        }
        function swap_bar_position() {
            BarData.swapPosition();
        }
        function toggle_dock_pin() {
            Mem.states.dock.pinned = !Mem.states.dock.pinned;
        }
    }
}
