import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: notificationPopup

    StyledPanel {
        id: root
        visible: (Notifications.popupList.length > 0)
        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
        name: "notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: Mem.options.bar.currentLayout === 3 ? -1 : 0
        aboveWindows: false
        property bool rightMode:Mem.states.sidebarLauncher.behavior.expanded || GlobalStates.sidebarOpen || Mem.options.bar.behavior.position !== "right"

        anchors {
            top: true
            bottom: true
            right:rightMode
            left: !rightMode
        }

        mask: Region {
            item: listview.contentItem
        }

        color: "transparent"
        implicitWidth: Sizes.notificationPopupWidth

        NotificationListView {
            id: listview
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left:parent.left
                rightMargin: Sizes.elevationMargin + Sizes.frameThickness
                topMargin: Sizes.elevationMargin + Sizes.frameThickness
                leftMargin:Sizes.elevationMargin + Sizes.frameThickness
            }
            implicitWidth: parent.width - anchors.rightMargin * 2
            popup: true
        }
    }
}
