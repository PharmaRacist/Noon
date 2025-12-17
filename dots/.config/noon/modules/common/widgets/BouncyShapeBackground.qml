import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: root

    // Public API
    property color backgroundColor: "lightgray"
    property real backgroundRadius: 12
    property real backgroundOpacity: 1.0
    property bool bounceOnRadiusChange: true
    signal bounced()


    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: root.backgroundRadius
        color: root.backgroundColor
        opacity: root.backgroundOpacity

        transform: Scale {
            id: shapeScale
            origin.x: bgRect.width / 2
            origin.y: bgRect.height / 2
            xScale: 1.0
            yScale: 1.0
        }

        Behavior on radius {
            Anim {
                id: radiusAnim
            }
        }

        Behavior on color {
            CAnim { }
        }

        onRadiusChanged: {
            if (root.bounceOnRadiusChange) {
                shapeScaleAnimation.restart()
            }
        }

        SequentialAnimation {
            id: shapeScaleAnimation
            running: false
            PropertyAnimation { target: shapeScale; property: "xScale"; to: 0.94; duration: 80; easing.type: Easing.OutQuad }
            PropertyAnimation { target: shapeScale; property: "xScale"; to: 1.0; duration: 120; easing.type: Easing.OutBounce }
            PropertyAnimation { target: shapeScale; property: "yScale"; to: 0.94; duration: 80; easing.type: Easing.OutQuad }
            PropertyAnimation { target: shapeScale; property: "yScale"; to: 1.0; duration: 120; easing.type: Easing.OutBounce }
            onStopped: root.bounced()
        }
    }
}
