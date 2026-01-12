import QtQuick
import qs.common
import qs.common.widgets

ApplicationSkeleton {
    id: root
    title: "media_player"
    contentItem: MediaPlayerPreview {
        id: preview
        window: root
    }

    sidebarContentItem: MediaPlayerList {
        expanded: root.expandSidebar
        onPlay: filePath => {
            if (root.contentLoaderItem) {
                root.contentLoaderItem.play(filePath);
            }
        }
    }
}
