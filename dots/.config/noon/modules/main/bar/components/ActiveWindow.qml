import qs.store
import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland

MouseArea {
    id: root
    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property int barHeight: BarData.currentBarExclusiveSize
    implicitHeight: BarData.currentBarExclusiveSize
    implicitWidth: 200
    hoverEnabled: true
    WorkspacePopup {
        hoverTarget: root
    }
    ColumnLayout {
        id: colLayout
        anchors.fill: parent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: -5

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: barHeight / 3
            color: Colors.colSubtext
            elide: Text.ElideRight
            text: root.activeWindow?.activated ? root.activeWindow?.appId : qsTr("Desktop")
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: barHeight / 2.8
            color: Colors.colOnLayer0
            elide: Text.ElideRight
            text: root.activeWindow?.activated ? root.activeWindow?.title : `${qsTr("Workspace")} ${monitor.activeWorkspace?.id}`
            Layout.maximumWidth: 220
        }
    }
}
