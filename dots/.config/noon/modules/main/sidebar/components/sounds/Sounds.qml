import QtQuick
import qs.common
import qs.common.widgets

RedunduntMultiViewPanel {
    id: root
    path: Qt.resolvedUrl("./")
    tabButtonList: [
        {
            "icon": "discover_tune",
            "name": "Mixer",
            "component": "Mixer"
        },
        {
            "icon": "radio",
            "name": "Radio",
            "component": "Radio"
        }
    ]
}
