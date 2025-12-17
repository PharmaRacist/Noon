pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    property bool inhibited: false
    property int timeout: 10000
    property bool initialized: false
    function init() {
        if (initialized)
            return;

        // Load saved settings
        inhibited = Mem.options.services.idle.inhibit ?? false;
        timeout = Mem.options.services.idle.timeout ?? 10000;

        initialized = true;
    }

    function toggleInhibit() {
        inhibited = !inhibited;
        Mem.options.services.idle.inhibit = inhibited;
    }

    // Auto-save when changed
    onInhibitedChanged: {
        if (initialized) {
            Mem.options.services.idle.inhibit = inhibited;
        }
    }

    onTimeoutChanged: {
        if (initialized) {
            Mem.options.services.idle.timeout = timeout;
        }
    }
    IdleInhibitor {
        enabled: root.inhibited
        window: PanelWindow {
            id: inhibitorWindow
            visible: root.inhibited
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
        id: idleMonitor
        enabled: true
        respectInhibitors: false
        timeout: 100
        onIsIdleChanged: if (isIdle) {
            console.log("locked");
            Noon.callIpc("global lock");
        }
    }
}
