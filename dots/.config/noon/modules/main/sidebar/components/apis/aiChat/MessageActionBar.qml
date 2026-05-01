import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts
import Noon.Services

RowLayout {
    id: root

    property int messageIndex
    property var messageData
    property bool editing: false

    spacing: Padding.small

    Repeater {
        model: [
            {
                icon: "content_copy",
                action: () => ClipboardService.copy(root.messageData.content)
            },
            {
                icon: root.editing ? "check" : "stylus",
                action: () => {
                    if (root.editing) {
                        root.editingChanged(false);
                        Ai.regenerate(root.messageIndex);
                    } else {
                        root.editingChanged(true);
                    }
                }
            },
            {
                icon: "delete",
                action: () => Ai.removeMessage(root.messageIndex)
            }
        ]
        delegate: Symbol {
            required property var modelData
            text: modelData.icon
            font.pixelSize: 18
            color: Colors.colSubtext
            fill: 0
            MouseArea {
                anchors.fill: parent
                onClicked: () => modelData.action()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
