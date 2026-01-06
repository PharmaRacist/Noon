import QtQuick
import QtQuick.Controls
import qs.common
import qs.store
import qs.common.widgets
import QtQuick.Layouts
import "widgets"

Item {
    id: root
    property bool expanded: false
    property bool isDragging: false
    property int pinnedCount: 0
    readonly property int columns: expanded ? 4 : 2
    readonly property int cellSize: 180
    readonly property int gridSpacing: 20
    readonly property int unit: cellSize + gridSpacing

    property var db: [
        {
            "id": "resources",
            "pill": false,
            "enabled": true,
            "expandable": true,
            "pinned": false,
            "component": "Resources"
        },
        {
            "id": "battery",
            "pill": true,
            "enabled": true,
            "expandable": false,
            "pinned": false,
            "component": "Battery"
        },
        {
            "id": "simple_clock",
            "pill": true,
            "enabled": true,
            "expandable": false,
            "pinned": false,
            "component": "Clock_Simple"
        },
        {
            "id": "bluetooth",
            "pill": true,
            "enabled": true,
            "expandable": false,
            "pinned": false,
            "component": "Bluetooth"
        },
        {
            "id": "media",
            "pill": false,
            "enabled": true,
            "expandable": true,
            "pinned": false,
            "component": "Media"
        },
        {
            "id": "combo",
            "enabled": true,
            "expandable": true,
            "pinned": false,
            "pill": false,
            "component": "ClockWeatherCombo"
        },
        {
            "id": "net",
            "pill": true,
            "enabled": true,
            "expandable": false,
            "pinned": false,
            "component": "NetworkSpeed"
        },
        {
            "id": "cal",
            "pill": false,
            "enabled": true,
            "expandable": true,
            "pinned": false,
            "component": "Calendar"
        },
        {
            "id": "pill",
            "enabled": true,
            "expandable": false,
            "pinned": false,
            "pill": true,
            "component": "Weather_Simple"
        }
    ]

    function arrangeAll() {
        let items = {
            pinned: [],
            unpinned: []
        };

        for (let i = 0; i < widgetRepeater.count; i++) {
            let item = widgetRepeater.itemAt(i);
            if (!item?.active)
                continue;

            items[item.isPinned ? "pinned" : "unpinned"].push({
                item: item,
                width: item.isExpanded && item.canExpand ? 2 : 1
            });
        }

        let x = 0, y = 0;

        for (let section of [items.pinned, items.unpinned]) {
            for (let data of section) {
                if (x + data.width > columns) {
                    x = 0;
                    y++;
                }

                data.item.gX = x;
                data.item.gY = y;
                data.item.isExpanded = data.width === 2;

                x += data.width;
                if (x >= columns) {
                    x = 0;
                    y++;
                }
            }

            if (section === items.pinned && items.pinned.length > 0) {
                root.pinnedCount = y + (x > 0 ? 1 : 0);
                if (x > 0) {
                    x = 0;
                    y++;
                }
            }
        }

        if (items.pinned.length === 0)
            root.pinnedCount = 0;
    }

    Flickable {
        anchors.fill: parent
        contentHeight: container.childrenRect.height + 100
        interactive: !root.isDragging
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id: container
            width: parent.width
            anchors.margins: Padding.massive

            Separator {
                visible: root.pinnedCount > 0
                width: parent.width - Padding.massive
                y: root.pinnedCount * root.unit - root.gridSpacing / 2 - 1.5
                opacity: 0.85
            }

            Repeater {
                id: widgetRepeater
                model: root.db

                delegate: Loader {
                    id: loader
                    active: modelData.enabled
                    visible: active
                    source: active ? "widgets/" + modelData.component + ".qml" : ""

                    property int gX: 0
                    property int gY: 0
                    property bool isExpanded: false
                    property bool isPinned: modelData.pinned
                    property bool isPill: modelData.pill

                    readonly property bool canExpand: modelData.expandable

                    width: active ? (isExpanded ? cellSize * 2 + gridSpacing : cellSize) : 0
                    height: active ? cellSize : 0
                    x: dragArea.pressed ? dragArea.dragX : gX * unit
                    y: dragArea.pressed ? dragArea.dragY : gY * unit
                    z: dragArea.pressed ? 1000 : 1

                    Behavior on x {
                        enabled: !dragArea.pressed && active
                        Anim {}
                    }
                    Behavior on y {
                        enabled: !dragArea.pressed && active
                        Anim {}
                    }
                    Behavior on width {
                        Anim {}
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        z: 999
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        property real dragX: loader.x
                        property real dragY: loader.y
                        property point startPos

                        onPressed: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                widgetMenu.popup(mouse.x, mouse.y);
                                return;
                            }

                            if (loader.isPinned)
                                return;

                            root.isDragging = true;
                            startPos = Qt.point(mouse.x, mouse.y);
                            dragX = loader.x;
                            dragY = loader.y;
                        }

                        onPositionChanged: mouse => {
                            if (!loader.isPinned && pressed && mouse.buttons & Qt.LeftButton) {
                                dragX += mouse.x - startPos.x;
                                dragY += mouse.y - startPos.y;
                            }
                        }

                        onReleased: mouse => {
                            if (mouse.button !== Qt.LeftButton || loader.isPinned)
                                return;

                            root.isDragging = false;

                            let targetY = Math.round(dragY / unit);
                            let targetX = Math.round(dragX / unit);

                            if (targetY < root.pinnedCount) {
                                loader.isPinned = true;
                                root.db[index].pinned = true;
                                Qt.callLater(root.arrangeAll);
                                return;
                            }

                            let targetIndex = targetY * columns + targetX;
                            targetIndex = Math.max(0, Math.min(targetIndex, widgetRepeater.count - 1));

                            if (index !== targetIndex) {
                                let targetItem = widgetRepeater.itemAt(targetIndex);
                                if (targetItem?.active) {
                                    [loader.gX, targetItem.gX] = [targetItem.gX, loader.gX];
                                    [loader.gY, targetItem.gY] = [targetItem.gY, loader.gY];
                                }
                            }
                        }
                    }
                    IslandContextMenu {
                        id: widgetMenu
                    }
                    Binding {
                        when: loader.status === Loader.Ready
                        target: loader.item
                        property: "width"
                        value: loader.width
                    }
                    Binding {
                        when: loader.status === Loader.Ready
                        target: loader.item
                        property: "pill"
                        value: loader.isPill
                    }
                    Binding {
                        when: loader.status === Loader.Ready
                        target: loader.item
                        property: "expanded"
                        value: loader.isExpanded
                    }

                    Component.onCompleted: Qt.callLater(root.arrangeAll)
                }
            }
        }
    }
    WidgetsSpawnerDialog {
        db: root.db
    }
}
