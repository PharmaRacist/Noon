import QtQuick
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

RedunduntMultiViewPanel {
    id: walls
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
            "name": "Wallhaven",
            "component": "WallhavenContent",
            "preload": "query",
            "preloadData": searchQuery
        }
    ]
    property string searchQuery: ""
    Component.onCompleted: {
        item.searchFocusRequested.connect(() => {
            walls.searchFocusRequested();
        });
        item.dismiss.connect(() => {
            walls.dismiss();
        });
    }
    onContentFocusRequested: {
        // propagate the same signal inside item
        item.contentFocusRequested();
    }
    signal searchFocusRequested
    signal contentFocusRequested
    signal dismiss
}
