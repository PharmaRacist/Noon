import qs.services
import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

StyledText {
    id: title
    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    Layout.alignment: Qt.AlignVCenter
    WorkspacePopup {
        hoverTarget: mouse
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (title.opacity > 0) {
                title.opacity = 0;
            } else {
                title.opacity = 1;
            }
        }
    }
    Behavior on opacity {
        Anim {}
    }

    opacity: 1
    font.weight: 600
    font.pixelSize: Fonts.sizes.normal
    color: Colors.m3.m3onSurfaceVariant
    text: activeWindow?.activated ? activeWindow?.appId : qsTr("HyprNoon")
    elide: Text.ElideLeft
}
