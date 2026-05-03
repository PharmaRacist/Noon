import QtQuick
import QtQuick3D
import Quickshell
import qs.common
import qs.common.widgets
import qs.services
import qs.common.characters.Girl
import qs.common.characters.Noon

StyledRect {
    id: root

    property bool expanded
    property int modelSize: 65
    property real minScale: 50
    property real maxScale: 80
    readonly property var latestMsg: Ai.messageIDs.length > 0 ? Ai.messageByID[Ai.messageIDs[Ai.messageIDs.length - 1]] : null
    property string response: ""
    color: "transparent"
    radius: Rounding.verylarge
    clip: true

    readonly property bool isThinking: Ai.isResponding
    Connections {
        target: Ai
        function onModelPosesChanged() {
            console.log("fired");
            model.reload();
        }
        function onResponseFinished() {
            let ids = Ai.messageIDs;
            if (ids.length === 0) {
                root.response = "";
                return;
            }
            let msg = Ai.messageByID[ids[ids.length - 1]];
            root.response = (msg?.role === "assistant" && msg?.content) ? msg.content : "";
        }
    }

    DragHandler {
        target: null
        property real lastX: 0
        onActiveChanged: if (active)
            lastX = centroid.position.x
        onCentroidChanged: if (active) {
            let deltaX = centroid.position.x - lastX;
            model.eulerRotation.y += deltaX * 0.1;
            lastX = centroid.position.x;
        }
    }

    PinchHandler {
        target: null
        property real startScale: 1
        onActiveChanged: if (active)
            startScale = model.scale.x
        onScaleChanged: {
            let s = Math.min(root.maxScale, Math.max(root.minScale, startScale * activeScale));
            model.scale = Qt.vector3d(s, s, s);
        }
    }

    WheelHandler {
        target: null
        onWheel: event => {
            let s = Math.min(root.maxScale, Math.max(root.minScale, model.scale.x + event.angleDelta.y * 0.02));
            model.scale = Qt.vector3d(s, s, s);
        }
    }

    View3D {
        anchors.fill: parent
        environment: SceneEnvironment {
            clearColor: "transparent"
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        Alicia {
            id: model
            scale: Qt.vector3d(root.modelSize, root.modelSize, root.modelSize)
            y: -1.25 * root.modelSize
            isThinking: root.latestMsg ? root.latestMsg.thinking : false
            isIdle: root.latestMsg ? root.latestMsg.done : true

            Connections {
                target: root.latestMsg
                function onThinkingChanged() {
                    model.isThinking = root.latestMsg.thinking;
                }
                function onDoneChanged() {
                    model.isIdle = root.latestMsg.done;
                }
            }
        }

        DirectionalLight {
            eulerRotation.x: -30
            brightness: 1.0
        }
        DirectionalLight {
            eulerRotation.x: 30
            eulerRotation.y: -135
            brightness: 0.25
        }
        PerspectiveCamera {
            z: 100
            clipNear: 0.1
            clipFar: 10000
        }
    }

    StyledRect {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Padding.massive
        width: moodLabel.contentWidth + Padding.huge
        height: 38
        radius: Rounding.large
        color: root.isThinking ? Colors.colSecondary : Colors.colSurfaceContainerHigh
        opacity: 0.92

        StyledText {
            id: moodLabel
            anchors.centerIn: parent
            text: root.isThinking ? "💭  Thinking" : "💤  Idle"
            font.pixelSize: 16
            color: root.isThinking ? Colors.colOnSecondary : Colors.colOnSurface
        }
    }

    StyledRect {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Padding.massive
        height: subtitleText.implicitHeight + Padding.massive
        radius: Rounding.small
        color: Colors.colSurfaceContainerHigh
        opacity: root.response.length > 0 ? 0.92 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        StyledText {
            id: subtitleText
            anchors.fill: parent
            anchors.margins: Padding.large
            text: root.response
            font.pixelSize: Fonts.sizes.large
            font.family: Fonts.family.reading
            color: Colors.colOnSurface
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
