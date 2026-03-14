import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.common
import qs.common.widgets
import qs.services
import "../common"

RowLayout {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 38
    Layout.rightMargin: Padding.normal
    Layout.leftMargin: Padding.normal
    spacing: Padding.large

    property var sink: AudioService.sink
    property real maxValue: 1

    readonly property var levels: ({
            "muted": "audio-volume-muted-symbolic",
            "low": "audio-volume-low-symbolic",
            "medium": "audio-volume-medium-symbolic",
            "high": "audio-volume-high-symbolic"
        })

    readonly property string currentLevel: {
        if (sink?.audio?.muted || volumeSlider.value <= 0.01)
            return "muted";
        if (volumeSlider.value < 0.33)
            return "low";
        if (volumeSlider.value < 0.67)
            return "medium";
        return "high";
    }

    StyledIconImage {
        implicitSize: 18
        _source: root.levels[root.currentLevel]
    }

    GSlider {
        id: volumeSlider
        Layout.fillWidth: true
        from: 0
        to: root.maxValue
        value: root.sink?.audio?.volume ?? 0

        onMoved: {
            if (root.sink?.audio) {
                root.sink.audio.volume = value;
            }
        }

        Connections {
            target: root.sink?.audio ? root.sink.audio : null
            ignoreUnknownSignals: true
            function onVolumeChanged() {
                if (!volumeSlider.pressed) {
                    volumeSlider.value = root.sink.audio.volume;
                }
            }
        }
    }
}
