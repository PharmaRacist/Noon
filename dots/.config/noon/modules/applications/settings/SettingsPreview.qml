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
    required property var window

    property string debouncedQuery: ""

    Timer {
        id: debounceTimer
        interval: 150
        repeat: false
        onTriggered: root.debouncedQuery = searchbar.query.toLowerCase()
    }

    readonly property string selectedCat: Mem?.states?.applications?.settings?.cat
    readonly property var selectedCatData: SettingsData?.tweaks.find(entry => entry.section === selectedCat)
    readonly property var _visible_data: {
        const tweaks = SettingsData?.tweaks ?? [];
        const q = root.debouncedQuery;
        const result = [];

        if (selectedCatData?.isPage) {
            return [];
        }

        for (let i = 0; i < tweaks.length; i++) {
            const sec = tweaks[i];
            const matchedSubsections = [];
            const subsections = sec.subsections || [];

            for (let j = 0; j < subsections.length; j++) {
                const sub = subsections[j];
                const filteredItems = (sub.items || []).filter(item => {
                    const nameMatch = (item.name || "").toLowerCase().includes(q);
                    return q !== "" ? nameMatch : (sec.section === selectedCat && nameMatch);
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

    property var itemStates: ({})

    Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_F) {
            searchbar.visible = !searchbar.visible;
            searchbar.inputArea.forceActiveFocus();
            event.accepted = true;
        }
    }

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: Colors.colLayer0
        StyledLoader {
            fade: true
            anchors.fill: parent
            readonly property string pageName: `${selectedCatData?.pageName ?? "Options"}Page`
            source: sanitizeSource("pages/", pageName)
        }
    }
}
