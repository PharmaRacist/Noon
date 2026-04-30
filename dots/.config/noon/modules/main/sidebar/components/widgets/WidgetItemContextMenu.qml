import QtQuick
import qs.store
import qs.common.widgets
import qs.common

StyledMenu {
    id: root

    required property var widgetData

    readonly property string widgetId: widgetData.id
    readonly property bool isPinned: Mem.states.sidebar.widgets.pinned.indexOf(widgetId) !== -1
    readonly property bool isDesktop: Mem.states.sidebar.widgets.desktop.indexOf(widgetId) !== -1
    readonly property bool isPill: Mem.states.sidebar.widgets.pilled.indexOf(widgetId) !== -1
    readonly property bool isExpanded: widgetData.expandable && Mem.states.sidebar.widgets.expanded.indexOf(widgetId) !== -1

    function toggleList(stateList, id) {
        let list = stateList.slice();
        let idx = list.indexOf(id);
        if (idx === -1)
            list.push(id);
        else
            list.splice(idx, 1);
        return list;
    }

    content: {
        let items = [
            {
                text: isPinned ? "Unpin" : "Pin",
                materialIcon: "push_pin",
                action: () => {
                    Mem.states.sidebar.widgets.pinned = toggleList(Mem.states.sidebar.widgets.pinned, widgetId);
                    root.close();
                }
            },
            {
                text: isDesktop ? "Remove from desktop" : "Send to desktop",
                materialIcon: "open_in_new",
                action: () => {
                    Mem.states.sidebar.widgets.desktop = toggleList(Mem.states.sidebar.widgets.desktop, widgetId);
                    root.close();
                }
            },
            {
                text: isPill ? "Square" : "Pill",
                materialIcon: isPill ? "capture" : "pill",
                action: () => {
                    Mem.states.sidebar.widgets.pilled = toggleList(Mem.states.sidebar.widgets.pilled, widgetId);
                    root.close();
                }
            },
            {
                text: "Disable",
                materialIcon: "visibility_off",
                action: () => {
                    Mem.states.sidebar.widgets.enabled = toggleList(Mem.states.sidebar.widgets.enabled, widgetId);
                    root.close();
                }
            }
        ];

        if (widgetData.expandable) {
            items.push({
                text: isExpanded ? "Collapse" : "Expand",
                materialIcon: isExpanded ? "close_fullscreen" : "open_in_full",
                action: () => {
                    Mem.states.sidebar.widgets.expanded = toggleList(Mem.states.sidebar.widgets.expanded, widgetId);
                    root.close();
                }
            });
        }

        return items;
    }
}
