import QtQuick
import qs.common.widgets

StyledMenu {
    id: widgetMenu
    content: {
        let items = [
            {
                "text": loader.isPinned ? "Unpin" : "Pin",
                "materialIcon": "push_pin",
                "action": () => {
                    widgetMenu.close();
                    loader.isPinned = !loader.isPinned;
                    root.db[index].pinned = loader.isPinned;
                    Qt.callLater(root.arrangeAll);
                }
            },
            {
                "text": root.db[index].pill ? "Island" : "Pill",
                "materialIcon": root.db[index].pill ? "capture" : "pill",
                "action": () => {
                    widgetMenu.close();
                    loader.isPill = !loader.isPill;
                    root.db[index].pinned = loader.isPill;
                    Qt.callLater(root.arrangeAll);
                }
            },
            {
                "text": "Disable",
                "materialIcon": "visibility_off",
                "action": () => {
                    widgetMenu.close();
                    root.db[index].enabled = false;
                    loader.active = false;
                    Qt.callLater(root.arrangeAll);
                    dialogRepeater.model = root.db.slice();
                }
            }
        ];

        if (loader.canExpand) {
            items.push({
                "text": loader.isExpanded ? "Collapse" : "Expand",
                "materialIcon": loader.isExpanded ? "close_fullscreen" : "open_in_full",
                "action": () => {
                    widgetMenu.close();
                    loader.isExpanded = !loader.isExpanded;
                    Qt.callLater(root.arrangeAll);
                }
            });
        }

        return items;
    }
}
