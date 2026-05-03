import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Noon.Services
import qs.common
import qs.services
import qs.common.widgets

StyledRect {
    id: chatView
    clip: true
    color: "transparent"
    radius: Rounding.small

    property alias listView: messageListView

    StyledListView {
        id: messageListView
        z: 0
        clip: true
        radius: Rounding.verylarge
        fasterInteractions: false
        anchors.fill: parent
        spacing: Padding.veryhuge
        reuseItems: false
        popin: false
        animateAppearance: false
        onCountChanged: if (messageListView.atYEnd)
            Qt.callLater(messageListView.positionViewAtEnd)

        _model: Ai.messageIDs.filter(id => Ai.messageByID[id]?.visibleToUser ?? true)
        Keys.onPressed: event => {
            if (event.modifiers === Qt.NoModifier) {
                if (event.key === Qt.Key_PageUp) {
                    contentY = Math.max(0, contentY - height / 2);
                    event.accepted = true;
                } else if (event.key === Qt.Key_PageDown) {
                    contentY = Math.min(contentHeight - height / 2, contentY + height / 2);
                    event.accepted = true;
                }
            }
        }
        delegate: Item {
            required property var modelData
            required property int index

            readonly property var msg: Ai.messageByID[modelData]
            readonly property Component userComp: UserMessage {
                messageIndex: index
                messageData: msg
                messageInputField: root.inputField
            }
            readonly property Component aiComp: AiMessage {
                messageIndex: index
                messageData: msg
                messageInputField: root.inputField
            }

            anchors.left: parent?.left
            anchors.right: parent?.right
            implicitHeight: loader?.implicitHeight

            Loader {
                id: loader
                asynchronous: true
                anchors.left: parent.left
                anchors.right: parent.right
                sourceComponent: parent.msg?.role === "user" ? userComp : aiComp
            }
        }
    }

    PagePlaceholder {
        z: 2
        shown: Ai.messageIDs.length === 0
        icon: "neurology"
        title: "AI"
        description: "access various AI models\n press '/' for more options "
        shape: MaterialShape.Shape.PixelCircle
    }
}
