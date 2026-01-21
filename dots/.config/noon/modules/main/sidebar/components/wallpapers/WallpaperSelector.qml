import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    visible: opacity > 0
    opacity: width > 320 ? 1 : 0
    color: "transparent"
    radius: Rounding.verylarge
    clip: true
    property string searchQuery: ""
    property string _debouncedQuery: ""
    property var cachedWallpapers: []

    signal searchFocusRequested
    signal contentFocusRequested
    signal dismiss

    anchors.fill: parent

    onSearchQueryChanged: debounceTimer.restart()

    Timer {
        id: debounceTimer
        interval: 150
        repeat: false
        onTriggered: root._debouncedQuery = root.searchQuery.trim()
    }

    onContentFocusRequested: if (listView.count > 0) {
        listView.currentIndex = 0;
        listView.forceActiveFocus();
    }

    function loadWallpapers() {
        const model = WallpaperService.wallpaperModel;
        if (!model)
            return;

        if (WallpaperService.wallpaperSelectorCachedModel && WallpaperService.wallpaperSelectorCachedModel.length === model.count) {
            cachedWallpapers = WallpaperService.wallpaperSelectorCachedModel;
            return;
        }

        const count = model.count;
        let wallpapers = new Array(count);

        for (let i = 0; i < count; i++) {
            const fileUrl = model.getFile(i);
            if (fileUrl) {
                wallpapers[i] = {
                    index: i,
                    fileUrl: fileUrl,
                    fileName: FileUtils.getEscapedFileName(fileUrl)
                };
            }
        }

        cachedWallpapers = wallpapers;
        WallpaperService.wallpaperSelectorCachedModel = wallpapers;
    }

    ScriptModel {
        id: filteredModel
        values: {
            const baseData = root.cachedWallpapers;
            if (!baseData || baseData.length === 0)
                return [];

            const query = root._debouncedQuery;
            if (!query)
                return baseData.slice(0, 100);

            const fuzzyResults = Fuzzy.go(query, baseData, {
                key: 'fileName',
                threshold: -10000,
                limit: 20
            });

            return fuzzyResults.map(r => r.obj);
        }
    }

    Timer {
        id: load_timer
        interval: 200
        onTriggered: loadWallpapers()
    }

    Connections {
        target: WallpaperService
        function onCurrentFolderPathChanged() {
            load_timer.restart();
        }
    }
    Component.onCompleted: {
        load_timer.restart();
    }
    StyledListView {
        id: listView
        anchors.fill: parent
        animateAppearance: true
        animateMovement: true
        popin: true
        anchors.margins: Padding.normal
        spacing: Padding.small
        clip: true
        model: filteredModel
        currentIndex: -1
        reuseItems: true
        cacheBuffer: height * 2

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 150

        delegate: Item {
            id: loader
            required property int index
            required property var modelData

            height: width * (9 / 16)
            width: listView.width

            WallpaperItem {
                id: wallpaperItem
                anchors.fill: parent
                readonly property int cellWidth: loader.width
                readonly property int cellHeight: loader.height

                isKeyboardSelected: listView.currentIndex === index
                isCurrentWallpaper: modelData ? String(modelData.fileUrl) === String(WallpaperService.currentWallpaper) : false
                fileUrl: modelData ? modelData.fileUrl : ""

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
            if (event.key === Qt.Key_Up) {
                if (currentIndex <= 0) {
                    currentIndex = -1;
                    root.searchFocusRequested();
                } else {
                    currentIndex--;
                }
            } else if (event.key === Qt.Key_Down) {
                if (currentIndex < count - 1) {
                    currentIndex++;
                }
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (currentIndex >= 0) {
                    const selectedData = filteredModel.values[currentIndex];
                    if (selectedData && selectedData.fileUrl) {
                        WallpaperService.applyWallpaper(selectedData.fileUrl);
                        Noon.playSound("event_accepted");
                    }
                }
            } else if (event.key === Qt.Key_Escape) {
                root.dismiss();
            } else
                return;

            event.accepted = true;
        }
    }
    ScrollEdgeFade {
        target: listView
        anchors.fill: parent
    }
    WallpaperControls {}
    PagePlaceholder {
        shown: listView.count === 0
        title: qsTr("No wallpapers found")
        icon: "image_not_supported"
        anchors.centerIn: parent
    }
}
