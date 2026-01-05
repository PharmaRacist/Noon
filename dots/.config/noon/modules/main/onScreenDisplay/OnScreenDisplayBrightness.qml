import qs.services
import qs.common
import qs.common.utils
import qs.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root
    property bool showOsdValues: false
    property bool userInteracting: false
    property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
    property var brightnessMonitor: BrightnessService.getMonitorForScreen(focusedScreen)

    function triggerOsd() {
        showOsdValues = true;
        if (!userInteracting) {
            osdTimeout.restart();
        }
    }

    function restartTimeoutIfNotInteracting() {
        if (!userInteracting && showOsdValues) {
            osdTimeout.restart();
        }
    }

    Binding {
        target: GlobalStates
        property: "showOsdValues"
        value: showOsdValues
    }

    Timer {
        id: osdTimeout
        interval: Mem.options.osd.timeout
        repeat: false
        running: false
        onTriggered: {
            if (!userInteracting) {
                root.showOsdValues = false;
            } else {
                restart();
            }
        }
    }

    Connections {
        target: BrightnessService
        function onBrightnessChanged() {
            if (!root.brightnessMonitor.ready)
                return;
            root.triggerOsd();
        }
    }

    Connections {
        target: root
        function onFocusedScreenChanged() {
            if (osdIndicator.item)
                osdIndicator.item.screen = root.focusedScreen;
        }
    }

    OsdValueIndicator {
        id: osdIndicator
        active: showOsdValues

        value: root.brightnessMonitor?.brightness ?? 50
        icon: BrightnessService.iconMaterial
        targetScreen: root.focusedScreen

        onInteractionStarted: {
            root.userInteracting = true;
            osdTimeout.stop();
        }

        onInteractionEnded: {
            root.userInteracting = false;
            root.restartTimeoutIfNotInteracting();
        }
    }

    IpcHandler {
        target: "osdBrightness"

        function trigger() {
            root.triggerOsd();
        }

        function hide() {
            showOsdValues = false;
        }

        function toggle() {
            showOsdValues = !showOsdValues;
        }
    }
}
