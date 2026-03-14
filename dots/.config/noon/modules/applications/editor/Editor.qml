import QtQuick
import qs.common
import qs.common.widgets

ApplicationSkeleton {
    id: root
    title: "editor"
    contentItem: EditorPreview {
        window: root
    }
    secondary_content_item: EditorList {
        expanded: root.sidebar_expanded
        onEdit: filePath => {
            if (root.contentLoaderItem) {
                root.contentLoaderItem.edit(filePath);
            }
        }
    }
}
