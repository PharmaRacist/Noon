import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

StyledGridView {
    id: root

    property int columns: 3
    property int iconSize: 60
    signal dismiss
    signal searchFocusRequested
    signal contentFocusRequested
    // Grid configuration
    cellWidth: Math.floor(width / columns)
    cellHeight: cellWidth
    cacheBuffer: Math.min(500, cellHeight * 3)
    reuseItems: true
    clip: true
    currentIndex: -1
    // Focus handling
    Connections {
        target: root
        function onContentFocusRequested() {
            if (root.count > 0) {
                root.currentIndex = 0;
                root.forceActiveFocus();
                root.positionViewAtIndex(0, GridView.Beginning);
            }
        }
    }
    model: DesktopEntries.applications
    delegate: RippleButton {
        id: appItem
        required property int index
        required property var modelData

        width: root.cellWidth - 10
        height: root.cellHeight - 10

        property string appId: modelData.id
        property bool isPinned: Mem.states.favorites.apps.some(id => id.toLowerCase() === appId.toLowerCase())
        property bool isSelected: root.currentIndex === index && root.activeFocus

        buttonRadius: isSelected ? Rounding.verylarge : 100
        colBackground: isSelected ? Colors.colSecondaryContainerActive : "transparent"

        releaseAction: () => {
            modelData.execute();
            root.dismiss();
        }

        altAction: () => {
            if (loader.item && loader.item.contextMenu) {
                loader.item.contextMenu.popup();
            }
        }

        // Content loader
        Loader {
            id: loader
            anchors.centerIn: parent
            width: parent.width - 20

            sourceComponent: appComponent
        }

        Component {
            id: appComponent
        }
    }

    Rectangle {
        anchors.fill: parent
        z: -1
        color: Colors.colLayer1
        radius: Rounding.verylarge
    }

    ScrollEdgeFade {
        target: root
    }
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
                const item = modelData.get(idx);
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
}
