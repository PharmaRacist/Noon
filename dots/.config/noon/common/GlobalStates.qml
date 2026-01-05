import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common.widgets
import qs.services
pragma Singleton

Singleton {
    id: root

    property QtObject xp
    property bool locked: false
    property bool playlistOpen: false
    property bool oskOpen: false
    property bool superHeld: false
    property bool superReleaseMightTrigger: false
    property bool screenLocked: false
    property bool sidebarOpen: true
    property bool sidebarHovered: false
    property bool exposeView: false
    property bool showOsdValues: false
    property bool showBeam: false
    property bool showAppearanceDialog: false
    property bool showCaffaineDialog: false
    property bool showBluetoothDialog: false
    property bool showWifiDialog: false
    property bool showRecordingDialog: false
    property bool showTransparencyDialog: false
    property bool showTempDialog: false
    property bool showKdeConnectDialog: false
    property var topLevel: ToplevelManager.activeToplevel

    function handle_init() {
        ColorsService.reload();
        KeyringStorage.reload();
        NightLightService.reload();
        TimerService.reload();
        AlarmService.reload();
        ClipboardService.reload();
        AmbientSoundsService.reload();
        HyprlandParserService.getAll();
        Noon.playSound("device_unlocked");
    }

    onSuperReleaseMightTriggerChanged: superHeld.stop()

    Timer {
        id: superHeldTimer

        interval: Mem.options.hacks.superHeldInterval
        onTriggered: superHeld = true
    }

    CustomShortcut {
        name: "superHeld"
        onPressed: superHeldTimer.start()
        onReleased: {
            superHeldTimer.stop();
            superHeld = false;
        }
    }

    xp: QtObject {
        id: xp

        property QtObject startMenu
        property bool locked: false

        function handle_init() {
            Noon.playSound("init", "xp");
        }

        startMenu: QtObject {
            property bool visible: false
        }

    }

}
