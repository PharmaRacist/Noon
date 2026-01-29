import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services
import "../common"

RowLayout {
    id: root
    Layout.preferredHeight: 38
    Layout.fillWidth: true
    Layout.rightMargin: Padding.normal
    Layout.leftMargin: Padding.normal
    spacing: Padding.large

    property var focusedScreen: GlobalStates.focusedScreen
    property var brightnessMonitor: BrightnessService.getMonitorForScreen(focusedScreen)

    readonly property var levels: ({
            "low": "display-brightness-low-symbolic",
            "medium": "display-brightness-medium-symbolic",
            "high": "display-brightness-high-symbolic"
        })

    readonly property string currentLevel: {
        if (brightnessSlider.value < 0.33)
            return "low";
        if (brightnessSlider.value < 0.67)
            return "medium";
        return "high";
    }

    StyledIconImage {
        implicitSize: 18
        _source: root.levels[root.currentLevel]
    }

    GSlider {
        id: brightnessSlider
        Layout.fillWidth: true
        from: 0
        to: 1
        value: root.brightnessMonitor?.brightness ?? 0

        onMoved: {
            if (root.brightnessMonitor) {
                root.brightnessMonitor.setBrightness(value);
            }
        }

        Connections {
            target: root.brightnessMonitor ? root.brightnessMonitor : null
            ignoreUnknownSignals: true

            function onBrightnessChanged() {
                if (!brightnessSlider.pressed && root.brightnessMonitor) {
                    brightnessSlider.value = root.brightnessMonitor.brightness;
                }
            }
        }
    }
}
