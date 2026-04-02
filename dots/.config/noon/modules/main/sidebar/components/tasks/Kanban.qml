import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.services

Item {
    id: root

    property bool expanded: false
    property int editIndex: -1
    // Column configuration model
    readonly property var columnConfigs: [
        {
            "status": TodoService.status_todo,
            "shape": MaterialShape.Cookie4Sided,
            "icon": "timer",
            "title": "Todo tasks",
            "model": todoTasksModel
        },
        {
            "status": TodoService.status_in_progress,
            "shape": MaterialShape.Ghostish,
            "icon": "hourglass_empty",
            "title": "In progress tasks",
            "model": inProgressTasksModel
        },
        {
            "status": TodoService.status_final_touches,
            "shape": MaterialShape.Slanted,
            "icon": "build",
            "title": "Final touches",
            "model": finalTouchesTasksModel
        },
        {
            "status": TodoService.status_done,
            "shape": MaterialShape.Cookie7Sided,
            "icon": "check_circle",
            "title": "Completed tasks",
            "model": doneTasksModel
        },
        {
            "status": TodoService.status_all,
            "shape": MaterialShape.Cookie12Sided,
            "icon": "check_circle",
            "title": "All",
            "model": allTasksModel
        }
    ]
    readonly property var todoColumn: getColumnByStatus(TodoService.status_todo)
    readonly property var inProgressColumn: getColumnByStatus(TodoService.status_in_progress)
    readonly property var finalTouchesColumn: getColumnByStatus(TodoService.status_final_touches)
    readonly property var doneColumn: getColumnByStatus(TodoService.status_done)
    readonly property Component dragTaskComponent: DragItem {}

    signal requestReveal

    function updateTaskModels() {
        for (var i = 0; i < columnConfigs.length; i++) {
            columnConfigs[i].model.clear();
        }
        for (var i = 0; i < TodoService.list.length; i++) {
            var item = TodoService.list[i];
            var entry = {
                "originalIndex": i,
                "content": item.content,
                "status": item.status,
                "todoistId": item.todoistId || ""
            };
            // Populate the matching status column
            var statusCol = columnConfigs.find(column => column.status === item.status);
            if (statusCol)
                statusCol.model.append(entry);
            // Populate "all" only if not done
            if (item.status !== TodoService.status_done) {
                columnConfigs.find(column => column.status === TodoService.status_all).model.append(entry);
            }
        }
    }

    function syncModelsToTodo() {
        var newList = [];
        const appendModel = m => {
            for (var i = 0; i < m.count; i++) {
                var it = m.get(i);
                newList.push({
                    "content": it.content,
                    "status": it.status,
                    "todoistId": it.todoistId
                });
            }
        };
        for (let i = 0; i < columnConfigs.length; i++) {
            appendModel(columnConfigs[i].model);
        }
        TodoService.list = newList;
        updateTaskModels();
    }

    function changeStatus(index, currentStatus, targetStatus) {
        var currentNum = currentStatus;
        var targetNum = targetStatus;
        var diff = targetNum - currentNum;
        var func = diff > 0 ? TodoService.nextStatus : TodoService.previousStatus;
        diff = Math.abs(diff);
        for (var i = 0; i < diff; i++) {
            func(index);
        }
    }

    function isOver(item, x, y) {
        var p = item.mapFromItem(overlay, x, y);
        return p.x >= 0 && p.x < item.width && p.y >= 0 && p.y < item.height;
    }

    function getColumnByStatus(status) {
        for (var i = 0; i < columnRepeater.count; i++) {
            var item = columnRepeater.itemAt(i);
            if (item && item.targetStatus === status)
                return item;
        }
        return null;
    }

    Component.onCompleted: {
        commandBar.forceActiveFocus();
        updateTaskModels();
    }
    ListModel {
        id: allTasksModel
    }
    ListModel {
        id: todoTasksModel
    }

    ListModel {
        id: inProgressTasksModel
    }

    ListModel {
        id: finalTouchesTasksModel
    }

    ListModel {
        id: doneTasksModel
    }

    Item {
        id: overlay

        anchors.fill: parent
        z: 100
    }

    QuickSettingsSplitButton {
        id: commandBar

        property bool editMode: false

        implicitHeight: 45
        showThird: false
        placeholderText: editMode ? "Edit task name" : "Add New"
        firstIcon: editMode ? "stylus" : "add"
        secondIcon: editMode ? "close" : "add"
        buttonExpanded: 200
        secondAction: () => {
            if (editMode) {
                editMode = false;
                root.editIndex = -1;
                commandBar.searchToggled = false;
                return;
            }
            commandBar.searchToggled = !commandBar.searchToggled;
        }
        secondPressHoldAction: () => !editMode ? root.requestReveal() : null
        searchAction: text => {
            if (editMode) {
                if (text.length > 0 && root.editIndex >= 0) {
                    TodoService.editItem(root.editIndex, text);
                    updateTaskModels();
                }
                editMode = false;
                root.editIndex = -1;
                text = "";
                return;
            } else {
                TodoService.addTask(text);
                updateTaskModels();
                text = "";
                return;
            }
        }

        Connections {
            function onEditIndexChanged() {
                if (root.editIndex >= 0 && root.editIndex < TodoService.list.length) {
                    commandBar.editMode = true;
                    var taskContent = TodoService.list[root.editIndex].content;
                    commandBar.searchToggled = true;
                    commandBar.searchInput.text = taskContent;
                } else if (root.editIndex === -1) {
                    commandBar.editMode = false;
                }
            }

            target: root
        }

        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 30
        }
    }

    GridLayout {
        anchors.fill: parent
        columnSpacing: Padding.huge
        rowSpacing: Padding.huge
        columns: expanded ? 2 : 1

        Repeater {
            id: columnRepeater

            model: ScriptModel {
                values: {
                    root.columnConfigs.filter(c => root.expanded ? c.status !== TodoService.status_all : c.status === TodoService.status_all);
                }
            }
            TaskList {
                required property var modelData
                required property int index

                visible: modelData.show ?? true
                shape: modelData.shape
                Layout.fillWidth: true
                Layout.fillHeight: true
                emptyPlaceholderIcon: modelData.icon
                emptyPlaceholderText: modelData.title
                targetStatus: modelData.status
                taskListModel: modelData.model
                onEditRequested: (idx, currentContent) => {
                    root.editIndex = idx;
                }
            }
        }
    }
}
