import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    color: "transparent"
    radius: Rounding.verylarge
    property string searchQuery: ""

    signal searchFocusRequested
    signal contentFocusRequested
    signal dismiss

    onContentFocusRequested: {
        if (listView.count > 0) {
            listView.currentIndex = 0;
            listView.forceActiveFocus();
        }
    }

    ScriptModel {
        id: bookmarkModel
        values: {
            const bookmarks = FirefoxBookmarksService.bookmarks || [];
            const mapped = bookmarks.map(b => ({
                        name: b.title || "Untitled",
                        url: b.url,
                        icon: b.favicon_local || b.favicon_url || "bookmark",
                        isLocalIcon: !!(b.favicon_local || b.favicon_url),
                        type: qsTr("Bookmark")
                    }));

            const query = root.searchQuery.trim();
            if (!query)
                return mapped;

            const results = Fuzzy.go(query, mapped, {
                keys: ['name', 'url'],
                threshold: -10000,
                limit: 50
            });
            return results.map(r => r.obj);
        }
    }

    StyledListView {
        id: listView
        anchors.fill: parent
        anchors.margins: Padding.normal
        model: bookmarkModel
        spacing: Padding.small
        currentIndex: -1

        delegate: StyledDelegateItem {
            width: listView.width
            required property var modelData

            title: modelData.name
            subtext: modelData.url
            iconSource: modelData.icon
            toggled: listView.currentIndex === index
            shape: MaterialShape.Shape.Clover4Leaf

            releaseAction: () => {
                FirefoxBookmarksService.openUrl(modelData.url);
                Noon.playSound("event_accepted");
                root.dismiss();
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Up && currentIndex <= 0) {
                currentIndex = -1;
                root.searchFocusRequested();
            } else if (event.key === Qt.Key_Down && currentIndex < count - 1) {
                currentIndex++;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (currentIndex >= 0) {
                    FirefoxBookmarksService.openUrl(model.values[currentIndex].url);
                    root.dismiss();
                }
            } else
                return;
            event.accepted = true;
        }
    }
}
