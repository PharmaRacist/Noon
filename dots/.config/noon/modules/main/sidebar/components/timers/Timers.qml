import QtQuick
import qs.common
import qs.common.widgets

RedunduntMultiViewPanel {
    id: root
    path: Qt.resolvedUrl("./")
    tabButtonList: [
        {
            "icon": "hourglass",
            "name": "Pomo",
            "component": "Pomos"
        },
        {
            "icon": "alarm",
            "name": "Alarms",
            "component": "Alarms"
        }
    ]
}
