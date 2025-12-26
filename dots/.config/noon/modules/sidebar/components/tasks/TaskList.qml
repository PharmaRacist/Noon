import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.services

Rectangle {
    id: root

    required property ListModel taskListModel
    required property int targetStatus
    property string emptyPlaceholderIcon
    property string emptyPlaceholderText
    property int todoListItemSpacing: 8
    property int listBottomPadding: 80
    property int containerMargin: 0
    property int containerPadding: 10
    property alias listView: listView
    property alias shape: placeHolder.shape

    signal editRequested(int index, string currentContent)

    radius: Rounding.verylarge
    color: Colors.colLayer1

    StyledListView {
        id: listView

        animateMovement: true
        popin: false
        anchors.fill: parent
        anchors.margins: containerPadding
        clip: true
        model: taskListModel
        spacing: root.todoListItemSpacing

        delegate: Item {
            id: delegateItem

            property bool isDragged: false

            width: listView.width
            height: 60

            Rectangle {
                id: todoItemRectangle

                anchors.fill: parent
                radius: Rounding.large
                color: getColorForStatus(model.status)
                opacity: delegateItem.isDragged ? 0 : 1

                MouseArea {
                    id: mouseArea

                    property bool dragging: false
                    property point startPos
                    property var draggedItem: null
                    property int oldIndex: -1
                    property var originalModel: null

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    preventStealing: true
                    onPressed: function(mouse) {
                        if (mouse.button !== Qt.LeftButton)
                            return ;

                        startPos = Qt.point(mouse.x, mouse.y);
                    }
                    onPositionChanged: function(mouse) {
                        if (dragging) {
                            var globalPos = mapToItem(overlay, mouse.x, mouse.y);
                            draggedItem.x = globalPos.x - draggedItem.width / 2;
                            draggedItem.y = globalPos.y - draggedItem.height / 2;
                            return ;
                        }
                        if (!pressed)
                            return ;

                        var delta = Qt.point(mouse.x - startPos.x, mouse.y - startPos.y);
                        if (Math.abs(delta.x) > 10 || Math.abs(delta.y) > 10) {
                            dragging = true;
                            delegateItem.isDragged = true;
                            var taskData = {
                                "content": model.content,
                                "status": model.status,
                                "todoistId": model.todoistId || "",
                                "originalIndex": model.originalIndex
                            };
                            var globalPos = mapToItem(overlay, mouse.x, mouse.y);
                            draggedItem = dragTaskComponent.createObject(overlay, {
                                "x": globalPos.x - listView.width / 2,
                                "y": globalPos.y - 60 / 2,
                                "width": listView.width,
                                "height": 60,
                                "color": getColorForStatus(taskData.status),
                                "taskData": taskData
                            });
                        }
                    }
                    onReleased: function(mouse) {
                        if (dragging) {
                            dragging = false;
                            if (draggedItem === null)
                                return ;

                            var centerX = draggedItem.x + draggedItem.width / 2;
                            var centerY = draggedItem.y + draggedItem.height / 2;
                            var targetList = null;
                            if (isOver(todoColumn, centerX, centerY))
                                targetList = todoColumn;
                            else if (isOver(inProgressColumn, centerX, centerY))
                                targetList = inProgressColumn;
                            else if (isOver(finalTouchesColumn, centerX, centerY))
                                targetList = finalTouchesColumn;
                            else if (isOver(doneColumn, centerX, centerY))
                                targetList = doneColumn;
                            oldIndex = index;
                            originalModel = taskListModel;
                            var taskData = draggedItem.taskData;
                            if (targetList === null) {
                                // snap back
                                delegateItem.isDragged = false;
                            } else if (targetList === root) {
                                // same list, reorder
                                var localX = listView.mapFromItem(overlay, centerX, centerY).x;
                                var localY = listView.mapFromItem(overlay, centerX, centerY).y;
                                var dropIndex = listView.indexAt(localX, localY);
                                if (dropIndex === -1) {
                                    dropIndex = listView.count;
                                } else {
                                    var targetItem = listView.itemAt(localX, localY);
                                    if (targetItem && localY > targetItem.y + targetItem.height / 2)
                                        dropIndex++;

                                }
                                if (dropIndex !== index && dropIndex >= 0) {
                                    if (dropIndex > index)
                                        dropIndex--;

                                    taskListModel.move(index, dropIndex, 1);
                                    syncModelsToTodo();
                                }
                                delegateItem.isDragged = false;
                            } else {
                                // different list
                                taskListModel.remove(index);
                                taskData.status = targetList.targetStatus;
                                var localX = targetList.listView.mapFromItem(overlay, centerX, centerY).x;
                                var localY = targetList.listView.mapFromItem(overlay, centerX, centerY).y;
                                var dropIndex = targetList.listView.indexAt(localX, localY);
                                if (dropIndex === -1) {
                                    dropIndex = targetList.taskListModel.count;
                                } else {
                                    var targetItem = targetList.listView.itemAt(localX, localY);
                                    if (targetItem && localY > targetItem.y + targetItem.height / 2)
                                        dropIndex++;

                                }
                                targetList.taskListModel.insert(dropIndex, taskData);
                                syncModelsToTodo();
                            }
                            draggedItem.destroy();
                        } else {
                            var statusChanged = false;
                            if (mouse.button === Qt.LeftButton && model.status !== TodoService.status_todo) {
                                TodoService.previousStatus(model.originalIndex);
                                statusChanged = true;
                            } else if (mouse.button === Qt.RightButton && model.status !== TodoService.status_done) {
                                TodoService.nextStatus(model.originalIndex);
                                statusChanged = true;
                            } else if (mouse.button === Qt.MiddleButton) {
                                root.editRequested(model.originalIndex, model.content);
                            }
                            if (statusChanged)
                                updateTaskModels();

                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    spacing: 15

                    MaterialSymbol {
                        text: {
                            switch (model.status) {
                            case TodoService.status_todo:
                                return "radio_button_unchecked";
                            case TodoService.status_in_progress:
                                return "work_history";
                            case TodoService.status_final_touches:
                                return "auto_fix_high";
                            case TodoService.status_done:
                                return "check_circle";
                            default:
                                return "radio_button_unchecked";
                            }
                        }
                        color: {
                            switch (model.status) {
                            case TodoService.status_todo:
                                return Colors.colOnLayer1;
                            case TodoService.status_in_progress:
                                return Colors.colPrimary;
                            case TodoService.status_final_touches:
                                return Colors.colSecondary;
                            case TodoService.status_done:
                                return Colors.m3.m3success;
                            default:
                                return Colors.colOnLayer1;
                            }
                        }
                        font.pixelSize: Fonts.sizes.normal
                    }

                    Column {
                        Layout.fillWidth: true

                        RowLayout {
                            spacing: 6

                            StyledText {
                                width: 180
                                text: model.content
                                wrapMode: Text.Wrap
                                opacity: model.status === TodoService.status_done ? 0.7 : 1
                                font.strikeout: model.status === TodoService.status_done
                                maximumLineCount: 2
                            }

                            MaterialSymbol {
                                visible: {
                                    // Show if has todoistId OR if currently syncing with _tempId
                                    if (model.todoistId !== "" && model.todoistId !== null)
                                        return true;

                                    // Could also check for _tempId if you want to show "syncing" state
                                    return false;
                                }
                                text: model.todoistId ? "cloud_done" : "cloud_sync"
                                font.pixelSize: 14
                                color: model.todoistId ? Colors.colPrimary : Colors.colOnLayer1
                                opacity: model.todoistId ? 0.5 : 0.3
                                ToolTip.visible: todoistIndicatorMouse.containsMouse
                                ToolTip.text: model.todoistId ? "Synced with Todoist" : "Syncing..."
                                ToolTip.delay: 500

                                MouseArea {
                                    id: todoistIndicatorMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                }

                            }

                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: {
                                switch (model.status) {
                                case TodoService.status_todo:
                                    return "Not Started";
                                case TodoService.status_in_progress:
                                    return "In Progress";
                                case TodoService.status_final_touches:
                                    return "Final Touches";
                                case TodoService.status_done:
                                    return "Finished";
                                default:
                                    return "Not Started";
                                }
                            }
                            opacity: model.status === TodoService.status_done ? 0.3 : 0.45
                            font.pixelSize: 11
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.rightMargin: 15
                        Layout.fillWidth: true

                        TodoItemActionButton {
                            onClicked: root.editRequested(model.originalIndex, model.content)
                            ToolTip.visible: hovered
                            ToolTip.text: "Edit (or middle-click)"
                            ToolTip.delay: 1000

                            contentItem: MaterialSymbol {
                                text: "edit"
                                fill: 1
                                font.pixelSize: Fonts.sizes.verylarge
                                color: Colors.colOnLayer1
                            }

                        }

                        TodoItemActionButton {
                            onClicked: {
                                TodoService.deleteItem(model.originalIndex);
                                updateTaskModels();
                            }

                            contentItem: MaterialSymbol {
                                text: "delete_forever"
                                fill: 1
                                font.pixelSize: Fonts.sizes.verylarge
                                color: Colors.m3.m3error
                            }

                        }

                    }

                }

                Behavior on opacity {
                    Anim {
                    }

                }

                Behavior on color {
                    CAnim {
                    }

                }

            }

        }

    }

    PagePlaceholder {
        id: placeHolder

        visible: taskListModel.count === 0
        opacity: taskListModel.count === 0 ? 1 : 0
        anchors.centerIn: parent
        icon: emptyPlaceholderIcon
        shape: MaterialShape.Clover4Leaf
        title: quarters ? emptyPlaceholderText : ""
    }

}
