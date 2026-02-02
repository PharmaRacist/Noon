import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.services
import qs.store

BarProgressIndicator {
    id: root
    value: AudioService.sink?.audio?.volume ?? 0
    icon:AudioService.sink?.audio.muted ? "volume_off" : "volume_up"

    Connections {
        target: AudioService.sink?.audio ?? null
        function onVolumeChanged() {
            if (AudioService.ready) root.expanded = true;
        }
        function onMutedChanged() {
            if (AudioService.ready) root.expanded = true;
        }
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const currentVolume = AudioService.sink?.audio.volume ?? 0;
            const step = currentVolume < 0.1 ? 0.01 : 0.02;

            if (event.angleDelta.y < 0)
                AudioService.sink.audio.volume = Math.max(0, currentVolume - step);
            else if (event.angleDelta.y > 0)
                AudioService.sink.audio.volume = Math.min(1, currentVolume + step);

            root.expanded = true;
        }
    }
}
