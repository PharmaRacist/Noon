import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services
import "./../common"

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    StyledListView {
        id: list
        spacing: Padding.small
        clip: true
        radius: Rounding.huge
        anchors.fill: parent

        model: ScriptModel {
            values: Notifications.appNameList
        }

        delegate: NotificationGroup {
            required property int index
            required property var modelData
            anchors.left: parent?.left
            anchors.right: parent?.right
            notificationGroup: Notifications.groupsByAppName[modelData]
            radius: Rounding.massive
            color: Colors.colLayer3
        }
    }
    GPlaceHolder {
        anchors.centerIn: root
        anchors.verticalCenterOffset: 20
        icon: Notifications.silent ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
        title: "NoNotifications"
        shown: Notifications.list.length === 0
    }
}
