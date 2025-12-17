import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.widgets
import qs.services

StyledRect {
    id: root
    color: Colors.colLayer1
    radius: Rounding.verylarge
    anchors.margins: Padding.normal
    clip: false
    // Scrollable window
    NotificationListView {
        id: listview

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: statusRow.top
        anchors.bottomMargin: 5
        layer.enabled: true
        popup: false

        layer.effect: OpacityMask {

            maskSource: Rectangle {
                width: listview.width
                height: listview.height
                radius: Rounding.normal
            }
        }
    }

    // Placeholder when list is empty
    Item {
        anchors.fill: listview
        visible: opacity > 0
        opacity: (Notifications.list.length === 0) ? 1 : 0

        PagePlaceholder {
            icon: Notifications.silent ? "notifications_off" : "notifications_active"
            shape: MaterialShape.Ghostish
            title: !Notifications.silent ? "Noisy" : "Shh"
        }

        Behavior on opacity {
            Anim {}
        }
    }

    Item {
        id: statusRow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Layout.fillWidth: true
        implicitHeight: Math.max(controls.implicitHeight, statusText.implicitHeight)

        StyledText {
            id: statusText

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            horizontalAlignment: Text.AlignHCenter
            text: `${Notifications.list.length} notifications`
            opacity: Notifications.list.length > 0 ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                Anim {}
            }
        }

        ButtonGroup {
            id: controls

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Padding.large
            anchors.verticalCenterOffset: -Padding.large
            NotificationStatusButton {
                buttonIcon: "notifications_paused"
                buttonText: qsTr("Silent")
                toggled: Notifications.silent
                onClicked: () => Mem.options.services.notifications.silent = !Notifications.silent
            }

            NotificationStatusButton {
                buttonIcon: "clear_all"
                buttonText: qsTr("Clear")
                onClicked: () => {
                    Notifications.discardAllNotifications();
                }
            }
        }
    }
}
