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
        screen: MonitorsInfo.focused ?? null
        name: "notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0
        aboveWindows: true

        anchors {
            top: true
            bottom: true
            right: true
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
                margins: Padding.massive
            }
            implicitWidth: Sizes.notificationPopupWidth - anchors.rightMargin * 2
            popup: true
            clip: false
            animateMovement: true
            animateAppearance: true
        }
    }
}
