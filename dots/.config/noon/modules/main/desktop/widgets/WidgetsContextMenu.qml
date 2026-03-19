import QtQuick
import QtQuick.Controls
import qs.store
import qs.common
import qs.common.widgets
import QtQuick.Layouts
import qs.modules.main.desktop.widgets

StyledMenu {
    id: root
    required property var modelData
    readonly property int widgetId: parseInt(modelData.id)
    property bool isExpanded: false

    property bool isPill: Mem.states.sidebar.widgets.pilled.includes(root.widgetId) //!== -1

    content: {
        let items = [
            {
                text: "Remove",
                materialIcon: "close",
                action: () => {
                    if (root.widgetId !== -1) {
                        Mem.states.sidebar.widgets.desktop.splice(root.widgetId, 1);
                    }
                    root.close();
                }
            },
            {
                text: root.isPill ? "Square" : "Pill",
                materialIcon: root.isPill ? "capture" : "pill",
                action: () => {
                    if (!root.isPill) {
                        Mem.states.sidebar.widgets.pilled.push(modelData.id);
                    } else {
                        Mem.states.sidebar.widgets.pilled.splice(modelData.id, 1);
                    }
                    root.close();
                }
            }
        ];

        if (modelData.expandable) {
            items.push({
                text: root.isExpanded ? "Collapse" : "Expand",
                materialIcon: root.isExpanded ? "close_fullscreen" : "open_in_full",
                action: () => {
                    let list = Mem.states.sidebar.widgets.expanded;
                    let idx = list.indexOf(root.widgetId);
                    if (idx === -1) {
                        list.push(root.widgetId);
                    } else {
                        list.splice(idx, 1);
                    }
                    Mem.states.sidebar.widgets.expanded = list.slice();
                    root.close();
                }
            });
        }

        return items;
    }
}
