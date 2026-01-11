import qs.common
import qs.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: notificationPopup

    StyledPanel {
        id: root
        visible: (Notifications.popupList.length > 0)
        screen: GlobalStates.focusedScreen ?? null
        name: "notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: Mem.options.bar.currentLayout === 3 ? -1 : 0
        aboveWindows: false
        property bool rightMode: GlobalStates.main.sidebar.expanded || GlobalStates.main.sidebar.show || Mem.options.bar.behavior.position !== "right"

        anchors {
            top: true
            bottom: true
            right: rightMode
            left: !rightMode
        }

        mask: Region {
            item: listview.contentItem
        }

        color: "transparent"
        implicitWidth: Sizes.notificationPopupWidth + 100

        NotificationListView {
            id: listview
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: Sizes.elevationMargin + Sizes.frameThickness
                topMargin: Sizes.elevationMargin + Sizes.frameThickness
                leftMargin: Sizes.elevationMargin + Sizes.frameThickness
            }
            implicitWidth: Sizes.notificationPopupWidth - anchors.rightMargin * 2
            popup: true
        }
    }
}
