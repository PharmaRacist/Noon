pragma Singleton
import QtQuick
import Quickshell
import qs.common

Singleton {
    readonly property QtObject settings: Mem.options.bar
    readonly property string position: settings.behavior.position
    readonly property var bars: ["Dynamic", "HyDe", "NovelKnocks", "Sleek", "VDynamic"]
    readonly property var layoutProps: ["fillHeight", "fillWidth", "preferredWidth", "preferredHeight", "topMargin", "bottomMargin", "leftMargin", "rightMargin", "margins", "implicitWidth", "implicitHeight", "width", "height", "minimumWidth", "minimumHeight", "maximumWidth", "maximumHeight"]
    readonly property int currentBarExclusiveSize: settings.layout.startsWith("V") ? settings.appearance.width : settings.appearance.height
    readonly property var contentTable: {
        "spacer": "Spacer",
        "power": "PowerIcon",
        "workspaces": "VWorkspaces",
        "unicodeWs": "UnicodeWs",
        "progressWs": "ProgressWs",
        "systemStatusIcons": "SystemStatusIcons",
        "materialStatusIcons": "StatusIcons",
        "sysTray": "SysTray",
        "utilButtons": "UtilButtons",
        "title": "CombinedTitle",
        "resources": "Resources",
        "circBattery": "MinimalBattery",
        "weather": "WeatherIndicator",
        "media": "VMedia",
        "clock": "VClockWidget",
        "keyboard": "KeyboardLayout",
        "logo": "Logo",
        "battery": "BatteryIndicator",
        "separator": "HSeparator",
        "space": "Spacer",
        "date": "DateWidget",
        "volume": "VolumeIndicator",
        "brightness": "BrightnessIndicator"
    }

    // Horizontal-specific component substitutions
    readonly property var horizontalSubstitutions: {
        "workspaces": "Workspaces",
        "title": "ActiveWindow",
        "media": "Media",
        "clock": "ClockWidget",
        "separator": "VerticalSeparator"
    }

    function swapPosition() {
        const pairs = {
            left: "right",
            right: "left",
            top: "bottom",
            bottom: "top"
        };
        settings.behavior.position = pairs[position];
    }

    function cyclePosition() {
        const positions = ["top", "left", "bottom", "right"];
        const currentPosition = settings.behavior.position;
        const position = (positions.indexOf(currentPosition) + 1) % 4;
        if (position === 0 || position === 2) {
            settings.layout = "Dynamic";
        } else {
            settings.layout = "VDynamic";
        }
        settings.behavior.position = positions[position];
    }
}
