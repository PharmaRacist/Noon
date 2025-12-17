import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import Quickshell
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

StyledGridView {
    id: appGridView
    property alias model: appGridView.model
    property string selectedCategory: ""
    property int columns: 3
    property int iconSize: 60
    property var currentMenu: null
    property int menuIndex: -1
    signal appLaunched(var app)
    signal searchFocusRequested
    signal contentFocusRequested

    cellWidth: Math.floor(width / columns)
    cellHeight: cellWidth
    reuseItems: false
    clip: true
    currentIndex: -1

    Connections {
        target: appGridView
        function onContentFocusRequested() {
            if (appGridView.count > 0) {
                appGridView.currentIndex = 0;
                appGridView.forceActiveFocus();
                appGridView.positionViewAtIndex(0, GridView.Beginning);
            }
        }
    }

    Keys.onPressed: event => {
        const columnsPerRow = Math.floor(width / cellWidth);

        switch (event.key) {
        case Qt.Key_Up:
            if (currentIndex === -1 && count > 0) {
                currentIndex = count - 1;
                positionViewAtIndex(currentIndex, GridView.Contain);
            } else if (currentIndex >= columnsPerRow) {
                currentIndex -= columnsPerRow;
                positionViewAtIndex(currentIndex, GridView.Contain);
            } else if (currentIndex >= 0) {
                searchFocusRequested();
                currentIndex = -1;
            }
            event.accepted = true;
            break;
        case Qt.Key_Down:
            if (currentIndex === -1 && count > 0) {
                currentIndex = 0;
                positionViewAtIndex(currentIndex, GridView.Contain);
            } else if (currentIndex + columnsPerRow < count) {
                currentIndex += columnsPerRow;
                positionViewAtIndex(currentIndex, GridView.Contain);
            }
            event.accepted = true;
            break;
        case Qt.Key_Left:
            if (currentIndex === -1 && count > 0) {
                currentIndex = 0;
                positionViewAtIndex(currentIndex, GridView.Contain);
            } else if (currentIndex > 0) {
                currentIndex--;
                positionViewAtIndex(currentIndex, GridView.Contain);
            }
            event.accepted = true;
            break;
        case Qt.Key_Right:
            if (currentIndex === -1 && count > 0) {
                currentIndex = 0;
                positionViewAtIndex(currentIndex, GridView.Contain);
            } else if (currentIndex < count - 1) {
                currentIndex++;
                positionViewAtIndex(currentIndex, GridView.Contain);
            }
            event.accepted = true;
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            if (currentIndex >= 0 && currentIndex < count) {
                const item = model.get(currentIndex);
                if (item)
                    appLaunched(item);
            }
            event.accepted = true;
            break;
        case Qt.Key_Home:
            if (count > 0) {
                currentIndex = 0;
                positionViewAtIndex(currentIndex, GridView.Beginning);
            }
            event.accepted = true;
            break;
        case Qt.Key_End:
            if (count > 0) {
                currentIndex = count - 1;
                positionViewAtIndex(currentIndex, GridView.End);
            }
            event.accepted = true;
            break;
        }
    }

    delegate: Rectangle {
        id: appItem
        required property int index
        required property var model

        width: appGridView.cellWidth - 10
        height: appGridView.cellHeight - 10

        property string appId: model.id
        property bool isPinned: Mem.states.dock.pinnedApps.some(id => id.toLowerCase() === appId.toLowerCase())
        property bool isSelected: appGridView.currentIndex === index && appGridView.activeFocus
        property bool isEmoji: appGridView.selectedCategory === "Emojis"

        radius: isSelected ? Rounding.verylarge : 100
        color: isSelected ? Colors.colSecondaryContainerActive : "transparent"

        Behavior on radius {
            Anim {}
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        AppContextMenu {
            id: contextMenu
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Padding.large

            // Emoji display
            StyledText {
                visible: appItem.isEmoji
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: appGridView.iconSize
                Layout.preferredHeight: appGridView.iconSize
                text: model.icon || ""
                font.pixelSize: appGridView.iconSize
                color: Colors.colOnLayer2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // App icon display
            StyledIconImage {
                id: iconImage
                visible: !appItem.isEmoji && iconImage.status !== Image.Error
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: appGridView.iconSize
                Layout.preferredHeight: appGridView.iconSize
                source: Noon.iconPath(model?.iconImage || "")
                colorize: Mem.options.appearance.icons.tint
                implicitSize: appGridView.iconSize
            }

            StyledText {
                visible: !appItem.isEmoji
                text: model.name || ""
                font.pixelSize: 12
                color: Colors.colOnLayer2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 1
                Layout.maximumWidth: appGridView.cellWidth - 35
            }
        }

        MouseArea {
            id: eventArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: false

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    appGridView.appLaunched(model);
                } else if (mouse.button === Qt.RightButton) {
                    if (!appItem.isEmoji) {
                        if (appGridView.currentMenu && appGridView.currentMenu !== contextMenu) {
                            appGridView.currentMenu.close();
                        }
                        appGridView.currentMenu = contextMenu;
                        appGridView.menuIndex = index;
                        appGridView.currentIndex = -1;
                        contextMenu.popup();
                    }
                }
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        z: -1
        color: Colors.colLayer1
        radius: Rounding.verylarge
    }
}
