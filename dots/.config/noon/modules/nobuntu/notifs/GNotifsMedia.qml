import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.services
import qs.common.widgets
import "./../common"

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: repeater.count > 0 ? 65 + (Math.max(0, repeater.count - 1) * Padding.small) : 0
    Layout.bottomMargin: Padding.massive
    Behavior on Layout.preferredHeight {
        Anim {}
    }
    clip: false
    Repeater {
        id: repeater
        model: BeatsService.meaningfulPlayers
        GNotifsMediaItem {
            required property var modelData
            required property var index
            property int _index: Math.min(2, index + 1)
            readonly property int padding: Padding.large * _index
            player: modelData
            anchors.centerIn: parent
            anchors.verticalCenterOffset: isPlaying ? hovered ? -padding : 0 : padding
            z: hovered ? _index + 99 : isPlaying ? _index + 3 : -_index
            width: isPlaying ? parent.width : parent.width - padding
            Behavior on anchors.verticalCenterOffset {
                Anim {}
            }
        }
    }
}
