import QtQuick
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

RedunduntMultiViewPanel {
    id: walls
    property string searchQuery: ""
    path: Qt.resolvedUrl("./")
    tabButtonList: [
        {
            "icon": "image",
            "name": "Local",
            "component": "LocalWallsContent",
            "preload": "query",
            "preloadData": searchQuery
        },
        {
            "icon": "wallpaper",
            "name": "Online",
            "component": "OnlineWallsContent",
            "preload": "query",
            "preloadData": searchQuery
        }
    ]
    WallpaperControls {}

    Connections {
        target: item
        function onSearchFocusRequested() {
            walls.searchFocusRequested();
        }
        function onDismiss() {
            walls.dismiss();
        }
    }
    onSelectedTabIndexChanged: {
        if (item && selectedTabIndex > -1)
            item.contentFocusRequested();
    }
    onContentFocusRequested: {
        item.contentFocusRequested();
    }

    signal searchFocusRequested
    signal contentFocusRequested
    signal dismiss
}
