import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.utils
import qs.common.widgets

StyledRect {
    id: root
    property bool expanded: false
    property bool readyToReceive: false
    color: Colors.colLayer1
    radius: Rounding.verylarge
    // Drop zone
    DropArea {
        id: dropArea
        anchors.fill: parent

        keys: ["text/uri-list"]

        onEntered: root.readyToReceive = true
        onExited: root.readyToReceive = false

        onDropped: drop => {
            root.readyToReceive = false;
            let newPaths = drop.urls.map(url => url.toString());
            Mem.states.sidebar.shelf.filePaths = [...Mem.states.sidebar.shelf.filePaths, ...newPaths];

            if (!GlobalStates.main.sidebar.pinned) {
                Noon.callIpc("sidebar hide");
            }
            Noon.playSound("event_accepted");
        }
        StyledRect {
            id: dropRect
            anchors.fill: parent
            anchors.margins: Padding.normal
            color: "transparent"
            radius: Rounding.verylarge
            enableBorders: root.readyToReceive
            border.color: root.readyToReceive ? Colors.colPrimary : Colors.colOutline
            border.width: root.readyToReceive ? 2 : 0
            Flickable {
                anchors.fill: parent
                anchors.margins: Padding.normal

                contentWidth: fileFlow.width
                contentHeight: fileFlow.height

                clip: true

                Flow {
                    id: fileFlow
                    width: dropRect.width - Padding.large
                    spacing: Padding.normal

                    Repeater {
                        model: Mem.states.sidebar.shelf.filePaths

                        delegate: ShelfFileItem {
                            required property var modelData
                            path: modelData
                        }
                    }
                }
            }
            PagePlaceholder {
                icon: "shelves"
                shown: Mem.states.sidebar.shelf.filePaths.length === 0
                title: "Drop Anything Here"
            }
        }
    }
}
