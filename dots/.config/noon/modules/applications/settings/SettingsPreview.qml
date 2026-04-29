import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.store
import qs.common
import qs.common.widgets
import "pages"

Item {
    id: root
    focus: true
    anchors.fill: parent

    required property var window
    property string debouncedQuery: ""
    property var itemStates: ({})
    readonly property string selectedCat: Mem?.states?.applications?.settings?.cat
    readonly property var selectedCatData: SettingsData?.tweaks.find(entry => entry.section === selectedCat)

    readonly property var _visible_data: {
        if (selectedCatData?.isPage || !SettingsData)
            return [];

        const tweaks = SettingsData.tweaks || [];
        const q = root.debouncedQuery.toLowerCase();
        const isSearching = q !== "";
        const result = [];

        for (let i = 0; i < tweaks.length; i++) {
            const sec = tweaks[i];

            if (!isSearching && sec.section !== selectedCat)
                continue;

            const matchedSubsections = [];
            const subsections = sec.subsections || [];

            for (let j = 0; j < subsections.length; j++) {
                const sub = subsections[j];
                const items = sub.items || [];

                const filteredItems = items.filter(item => {
                    const name = (item.name || "").toLowerCase();
                    return name.includes(q);
                });

                if (filteredItems.length > 0) {
                    matchedSubsections.push({
                        "name": sub.name,
                        "items": filteredItems
                    });
                }
            }

            if (matchedSubsections.length > 0) {
                result.push({
                    "section": sec.section,
                    "icon": sec.icon,
                    "shell": sec.shell,
                    "subsections": matchedSubsections
                });
            }
        }
        return result;
    }

    Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_F) {
            searchbar.visible = !searchbar.visible;
            searchbar.inputArea.forceActiveFocus();
            event.accepted = true;
        }
    }

    Connections {
        target: contentLoader._item
        function onQueryChanged() {
            debounceTimer.restart();
        }
    }
    Timer {
        id: debounceTimer
        interval: 200
        repeat: false
        onTriggered: root.debouncedQuery = contentLoader._item?.query ?? ""
    }
    Rectangle {
        anchors.fill: parent
        color: Colors.colLayer0
        StyledLoader {
            id: contentLoader
            fade: true
            anchors.fill: parent
            readonly property string pageName: `${selectedCatData?.pageName ?? "Options"}Page`
            source: sanitizeSource("pages/", pageName)
            onLoaded: {
                if ("visibleData" in _item)
                    _item.visibleData = Qt.binding(() => root._visible_data);
                if ("itemStates" in _item)
                    _item.itemStates = Qt.binding(() => root.itemStates);
            }
        }
    }
}
