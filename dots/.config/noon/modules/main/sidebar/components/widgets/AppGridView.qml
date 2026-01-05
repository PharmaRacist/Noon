import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

StyledGridView {
    id: appGridView

    // Properties
    property alias model: appGridView.model
    property string selectedCategory: ""
    property int columns: 3
    property int iconSize: 60

    // Signals
    signal appLaunched(var app)
    signal searchFocusRequested
    signal contentFocusRequested

    // Grid configuration
    cellWidth: Math.floor(width / columns)
    cellHeight: cellWidth
    cacheBuffer:Math.min(500, cellHeight * 3)
    reuseItems: true
    clip: true
    currentIndex: -1
    // Focus handling
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

    // Keyboard navigation
    Keys.onPressed: event => {
        const cols = Math.floor(width / cellWidth);
        const idx = currentIndex;

        switch (event.key) {
        case Qt.Key_Up:
            if (idx === -1 && count > 0) {
                currentIndex = count - 1;
            } else if (idx >= cols) {
                currentIndex -= cols;
            } else if (idx >= 0) {
                searchFocusRequested();
                currentIndex = -1;
            }
            positionViewAtIndex(currentIndex, GridView.Contain);
            event.accepted = true;
            break;
        case Qt.Key_Down:
            if (idx === -1 && count > 0) {
                currentIndex = 0;
            } else if (idx + cols < count) {
                currentIndex += cols;
            }
            positionViewAtIndex(currentIndex, GridView.Contain);
            event.accepted = true;
            break;
        case Qt.Key_Left:
            if (idx === -1 && count > 0) {
                currentIndex = 0;
            } else if (idx > 0) {
                currentIndex--;
            }
            positionViewAtIndex(currentIndex, GridView.Contain);
            event.accepted = true;
            break;
        case Qt.Key_Right:
            if (idx === -1 && count > 0) {
                currentIndex = 0;
            } else if (idx < count - 1) {
                currentIndex++;
            }
            positionViewAtIndex(currentIndex, GridView.Contain);
            event.accepted = true;
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            if (idx >= 0 && idx < count) {
                const item = model.get(idx);
                if (item)
                    appLaunched(item);
            }
            event.accepted = true;
            break;
        case Qt.Key_Home:
            if (count > 0) {
                currentIndex = 0;
                positionViewAtIndex(0, GridView.Beginning);
            }
            event.accepted = true;
            break;
        case Qt.Key_End:
            if (count > 0) {
                currentIndex = count - 1;
                positionViewAtIndex(count - 1, GridView.End);
            }
            event.accepted = true;
            break;
        }
    }

    // Delegate
    delegate: RippleButton {
        id: appItem
        required property int index
        required property var model

        width: appGridView.cellWidth - 10
        height: appGridView.cellHeight - 10

        property string appId: model.id
        property bool isPinned: Mem.states.dock.pinnedApps.some(id => id.toLowerCase() === appId.toLowerCase())
        property bool isSelected: appGridView.currentIndex === index && appGridView.activeFocus
        property bool isEmoji: appGridView.selectedCategory === "Emojis"

        buttonRadius: isSelected ? Rounding.verylarge : 100
        colBackground: isSelected ? Colors.colSecondaryContainerActive : "transparent"

        releaseAction: () => appGridView.appLaunched(model)

        altAction: () => {
            if (!appItem.isEmoji && loader.item && loader.item.contextMenu) {
                loader.item.contextMenu.popup();
            }
        }

        // Content loader
        Loader {
            id: loader
            anchors.centerIn: parent
            width: parent.width - 20
            sourceComponent: appItem.isEmoji ? emojiComponent : appComponent
        }

        Component {
            id: appComponent
            ColumnLayout {
                spacing: Padding.small
                property alias contextMenu: contextMenu

                StyledIconImage {
                    source: Noon.iconPath(model?.iconImage || "")
                    colorize: Mem.options.appearance.icons.tint
                    implicitWidth: appGridView.iconSize
                    implicitHeight: appGridView.iconSize
                    Layout.alignment: Qt.AlignHCenter
                }

                StyledText {
                    text: model.name || ""
                    font.pixelSize: 12
                    color: Colors.colOnLayer2
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 1
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                AppContextMenu {
                    id: contextMenu
                }
            }
        }

        Component {
            id: emojiComponent
            StyledText {
                text: model.icon || ""
                font.family: Fonts.emoji
                font.pixelSize: appGridView.iconSize
                color: Colors.colOnLayer2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Background
    Rectangle {
        anchors.fill: parent
        z: -1
        color: Colors.colLayer1
        radius: Rounding.verylarge
    }

    ScrollEdgeFade {
        target:appGridView 
    }

}
