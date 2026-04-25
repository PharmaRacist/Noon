import QtQuick
import qs.common
import qs.common.widgets

RedunduntMultiViewPanel {
    id: root
    property bool expanded
    path: Qt.resolvedUrl("./")
    tabButtonList: [
        {
            "icon": "music_note",
            "name": "Beats",
            "preload": "expanded",
            "preloadData": root.expanded,
            "component": "LocalBeats"
        },
        {
            "icon": "globe",
            "name": "New",
            "preload": "expanded",
            "preloadData": root.expanded,
            "component": "BeatsHits"
        },
        {
            "icon": "equalizer",
            "name": "EQ",
            "preload": "expanded",
            "preloadData": root.expanded,
            "component": "BeatsEqualizer"
        }
    ]
}
