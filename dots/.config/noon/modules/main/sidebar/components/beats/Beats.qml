import QtQuick
import qs.common
import qs.common.widgets
import "pages"

RedunduntMultiViewPanel {
    id: root
    property bool expanded
    path: Qt.resolvedUrl("./")
    tabButtonList: [
        {
            // Queue ?
            "icon": "music_note",
            "name": "Home",
            "preload": "expanded",
            "preloadData": root.expanded,
            "component": "pages/HomePage"
        },
        {
            // Quick picks - discover - trending
            "icon": "globe",
            "name": "Feed",
            "preload": "expanded",
            "preloadData": root.expanded,
            "component": "pages/HitsPage"
        },
        {
            "icon": "list",
            "name": "Local",
            "preload": "expanded",
            "preloadData": root.expanded,
            "component": "pages/LocalTracksPage"
        },
        {
            "icon": "tune",
            "name": "EQ",
            "preload": "expanded",
            "preloadData": root.expanded,
            "component": "pages/EQPage"
        },
    ]
}
