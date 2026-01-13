import QtQuick
import qs.common
import qs.common.widgets

ApplicationSkeleton {
    id: root
    title: "editor"
    contentItem: EditorPreview {
        window: root
    }
    sidebarContentItem: EditorList {
        expanded: root.expandSidebar
        onEdit: filePath => {
            if (root.contentLoaderItem) {
                root.contentLoaderItem.edit(filePath);
            }
        }
    }
}
