import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

Item {
    id: root
    property string searchQuery: ""
    readonly property int itemSpacing: Padding.large
    property var cachedWallpapers: []
    anchors.fill: parent

    signal searchFocusRequested
    signal contentFocusRequested

    function loadWallpapers() {
        const model = WallpaperService.wallpaperModel;
        const count = model.count;
        const currentPath = WallpaperService.currentWallpaper;

        let wallpapers = [];
        for (let i = 0; i < count; i++) {
            const fileUrl = model.getFile(i);
            if (fileUrl) {
                const urlString = fileUrl.toString();
                wallpapers.push({
                    index: i,
                    fileUrl: fileUrl,
                    fileName: FileUtils.getEscapedFileName(fileUrl),
                    isCurrentWallpaper: urlString === currentPath
                });
            }
        }
        cachedWallpapers = wallpapers;
        Fuzzy.prepare(cachedWallpapers);
        filterWallpapers();
    }

    function filterWallpapers() {
        const query = root.searchQuery.trim();
        if (!query) {
            filteredModel.values = cachedWallpapers;
            return;
        }

        filteredModel.values = Fuzzy.go(query, cachedWallpapers, {
            key: 'fileName',
            threshold: -10000,
            limit: 7
        }).map(r => r.obj);
    }

    Component.onCompleted: loadWallpapers()
    onSearchQueryChanged: searchDebounceTimer.restart()

    Timer {
        id: searchDebounceTimer
        interval: 250
        onTriggered: filterWallpapers()
    }

    ScriptModel {
        id: filteredModel
        values: []
    }

    StyledRect {
        anchors.fill: parent
        color: "transparent"
        clip: true
        radius: Rounding.verylarge

        StyledListView {
            id: listView
            anchors.fill: parent
            anchors.margins: Padding.normal
            spacing: Padding.small
            model: filteredModel
            currentIndex: -1
            cacheBuffer: height * 2

            delegate: Item {
                width: ListView.view.width
                height: width * (9 / 16)

                required property var modelData
                required property int index

                WallpaperItem {
                    id: wallpaperItem
                    anchors.fill: parent
                    isKeyboardSelected: listView.currentIndex === index && listView.activeFocus
                    isCurrentWallpaper: modelData.isCurrentWallpaper
                    fileUrl: modelData.fileUrl

                    onClicked: if (fileUrl) {
                        WallpaperService.applyWallpaper(fileUrl);
                        listView.currentIndex = index;
                    }
                }

                StyledRectangularShadow {
                    target: wallpaperItem
                    show: wallpaperItem.isKeyboardSelected
                }
            }

            Keys.onPressed: event => {
                if (count === 0)
                    return;

                const navKeys = [Qt.Key_Down, Qt.Key_Up, Qt.Key_PageDown, Qt.Key_PageUp, Qt.Key_Home, Qt.Key_End, Qt.Key_Return, Qt.Key_Enter, Qt.Key_Escape];
                if (navKeys.indexOf(event.key) === -1)
                    return;

                event.accepted = true;
                switch (event.key) {
                case Qt.Key_Down:
                    if (currentIndex < count - 1)
                        currentIndex++;
                    break;
                case Qt.Key_Up:
                    if (currentIndex <= 0) {
                        currentIndex = -1;
                        root.searchFocusRequested();
                    } else
                        currentIndex--;
                    break;
                case Qt.Key_PageDown:
                    currentIndex = Math.min(currentIndex + 5, count - 1);
                    break;
                case Qt.Key_PageUp:
                    currentIndex = Math.max(currentIndex - 5, 0);
                    break;
                case Qt.Key_Home:
                    currentIndex = 0;
                    break;
                case Qt.Key_End:
                    currentIndex = count - 1;
                    break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    if (currentIndex >= 0)
                        WallpaperService.applyWallpaper(model.values[currentIndex].fileUrl);
                    break;
                case Qt.Key_Escape:
                    root.searchFocusRequested();
                    break;
                }
            }
        }
    }
}
