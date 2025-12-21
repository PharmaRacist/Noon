import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.sidebarLauncher
import qs.services

ColumnLayout {
    id: root

    property bool shown: GlobalStates.playlistOpen
    property string searchText: ""

    spacing: Padding.normal
    Layout.fillHeight: true
    Layout.fillWidth: true
    Component.onCompleted: {
        MusicPlayerService.initializeTracks();
    }
}
