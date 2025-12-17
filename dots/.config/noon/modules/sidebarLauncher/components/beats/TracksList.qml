import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.common.functions
import qs
import qs.modules.sidebarLauncher

ColumnLayout {
    id: root
    spacing: Padding.normal
    Layout.fillHeight: true
    Layout.fillWidth: true

    property bool shown: GlobalStates.playlistOpen
    property string searchText: ""

    Component.onCompleted: {
        MusicPlayerService.initializeTracks();
    }

}
