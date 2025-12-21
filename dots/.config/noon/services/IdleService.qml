import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
pragma Singleton

Singleton {
    id: root

    property int timeout: Mem.options.services.idle.timeOut
    property bool inhibited: Mem.options.services.idle.inhibit

    function toggleInhibit() {
        Mem.options.services.idle.inhibit = !Mem.options.services.idle.inhibit;
    }

    IdleInhibitor {
        enabled: Mem.options.services.idle.inhibit

        window: PanelWindow {
            id: inhibitorWindow

            visible: true
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"

            anchors {
                right: true
                bottom: true
            }

            mask: Region {
                item: null
            }

        }

    }

    IdleMonitor {
        timeout: Mem.options.services.idle.timeOut
        onIsIdleChanged: {
            if (isIdle)
                Noon.callIpc("global lock");

        }
    }

}
