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
    property string protectionMessage: ""
    property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)

    Binding {
        target: GlobalStates
        property: "showOsdValues"
        value: showOsdValues
    }

    function triggerOsd() {
        showOsdValues = true;
        if (!userInteracting)
            osdTimeout.restart();
    }

    function restartTimeoutIfNotInteracting() {
        if (showOsdValues && !userInteracting)
            osdTimeout.restart();
    }

    Timer {
        id: osdTimeout
        interval: Mem.options.osd.timeout
        repeat: false
        onTriggered: {
            if (!userInteracting) {
                root.showOsdValues = false;
                root.protectionMessage = "";
            } else {
                restart();
            }
        }
    }

    Connections {
        target: BrightnessService
        function onBrightnessChanged() {
            showOsdValues = false;
        }
    }

    Connections {
        target: AudioService.sink?.audio ?? null
        function onVolumeChanged() {
            if (AudioService.ready)
                root.triggerOsd();
        }
        function onMutedChanged() {
            if (AudioService.ready)
                root.triggerOsd();
        }
    }

    Connections {
        target: AudioService
        function onSinkProtectionTriggered(reason) {
            root.protectionMessage = reason;
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

        value: AudioService.sink?.audio.volume ?? 0
        icon: AudioService.sink?.audio.muted ? "volume_off" : "volume_up"
        targetScreen: root.focusedScreen

        onValueModified: function(newValue) {
            if (AudioService.sink?.audio)
                AudioService.sink.audio.volume = newValue;
        }

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
        target: "osdVolume"
        function trigger() { root.triggerOsd(); }
        function hide()    { root.showOsdValues = false; }
        function toggle()  { root.showOsdValues = !root.showOsdValues; }
    }
}
