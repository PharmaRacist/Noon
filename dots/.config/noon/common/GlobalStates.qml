pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.common.widgets
import qs.services

Singleton {
    id: root

    property QtObject main
    property QtObject xp
    property QtObject applications
    property bool superHeld: false
    property var topLevel: ToplevelManager.activeToplevel
    property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)

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
    applications: QtObject {
        property QtObject mediaplayer: QtObject {
            property bool show: false
            property var queue: []
        }
        property QtObject editor: QtObject {
            property bool show: false
            property string currentPath: Qt.resolvedUrl(Directories.shellConfigs)
            property string currentFile: ""
        }
    }
    main: QtObject {
        id: main
        function handle_init() {
            KeyringStorage.reload();
            NightLightService.reload();
            TimerService.reload();
            AlarmService.reload();
            ClipboardService.reload();
            AmbientSoundsService.reload();
            HyprlandParserService.reload();
            Noon.playSound("device_unlocked");
        }

        property bool locked: false
        property bool oskOpen: false
        property bool exposeView: false
        property bool showOsdValues: false
        property bool showBeam: false
        property bool showScreenshot: false

        property QtObject sidebar: QtObject {
            property bool show: true
            property bool pinned: false
            property bool expanded: false
            property var webBrowserState
        }
        property QtObject dialogs: QtObject {
            property bool showAppearanceDialog: false
            property bool showCaffaineDialog: false
            property bool showBluetoothDialog: false
            property bool showWifiDialog: false
            property bool showRecordingDialog: false
            property bool showTransparencyDialog: false
            property bool showTempDialog: false
            property bool showKdeConnectDialog: false
        }
    }
    xp: QtObject {
        id: xp

        property bool locked: false

        function handle_init() {
            HyprlandParserService.getAll();
            Noon.playSound("init", "xp");
        }
        property bool showRun: false
        property bool showStartMenu: false
        property bool showControlPanel: false
    }
}
