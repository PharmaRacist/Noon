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

    secondary_content_item: MediaPlayerList {
        expanded: root.sidebar_expanded
        onPlay: filePath => {
            if (root.contentLoaderItem) {
                root.contentLoaderItem.play(filePath);
            }
        }
    }
}
