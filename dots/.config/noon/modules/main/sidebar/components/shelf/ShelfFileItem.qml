import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.common.functions
import qs.services
import qs.store

StyledRect {
    id: root

    property string path
    implicitHeight: Sizes.sidebar.shelfItemSize.height
    implicitWidth: Sizes.sidebar.shelfItemSize.width
    color: Colors.colLayer2
    radius: Rounding.large
    border.color: eventArea.drag.active ? Colors.colPrimary : "transparent"
    border.width: 2
    function getIcon(path) {
        if (!path)
            return "draft";

        // Get the extension and format it to match "*.ext"
        const ext = "*." + FileUtils.getEscapedFileExtension(path).toLowerCase();

        if (NameFilters.picture.indexOf(ext) !== -1) {
            return "image";
        } else if (NameFilters.video.indexOf(ext) !== -1) {
            return "play_arrow";
        } else if (NameFilters.audio.indexOf(ext) !== -1) {
            return "music_note";
        } else if (NameFilters.document.indexOf(ext) !== -1) {
            return "docs";
        } else if (NameFilters.archive.indexOf(ext) !== -1) {
            return "archive";
        }
        return "draft";
    }

    CLayout {
        anchors.centerIn: parent

        Symbol {
            id: symbol
            text: getIcon(root.path)
            fill: eventArea.drag.active ? 0 : 1
            font.pixelSize: 32
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            id: title
            text: decodeURIComponent(FileUtils.getEscapedFileNameWithoutExtension(root.path))
            color: Colors.colOnLayer2
            font.pixelSize: Fonts.sizes.small
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 2
            Layout.fillWidth: true
            Layout.maximumWidth: root.width - Padding.verysmall
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        id: eventArea
        anchors.fill: parent
        drag.target: dragProxy
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        onPressed: event => {
            switch (event.button) {
            case Qt.LeftButton:
                Noon.openFile(path);
                if (!GlobalStates.main.sidebar.pinned) {
                    Noon.callIpc("sidebar hide");
                }
                dragProxy.Drag.mimeData = {
                    "text/uri-list": path
                };
                break;
            case Qt.RightButton:
                contextMenu.popup();
                break;
            }
        }

        onReleased: {
            dragProxy.Drag.drop();
            dragProxy.x = 0;
            dragProxy.y = 0;
        }
    }
    ShelfPreviewArea {
        type: symbol.text
        path: root.path
        extraVisibleCondition: supportedPreviews.includes(type) && eventArea.containsMouse && path.length > 0
    }
    Rectangle {
        id: dragProxy
        width: 60
        height: 60
        color: Colors.colPrimary
        radius: Rounding.small
        opacity: 0.7
        visible: eventArea.drag.active

        Drag.active: eventArea.drag.active
        Drag.supportedActions: Qt.CopyAction | Qt.MoveAction
        Drag.dragType: Drag.Automatic

        Symbol {
            text: symbol.text
            anchors.centerIn: parent
            font.pixelSize: 28
            color: Colors.colOnPrimary
        }
    }
    StyledMenu {
        id: contextMenu
        content: [
            {
                "text": "Forget",
                "materialIcon": "delete",
                "action": () => {
                    if (root.index !== undefined) {
                        Mem.states.sidebar.shelf.filePaths.splice(root.index, 1);
                    }
                }
            }
        ]
    }
}
