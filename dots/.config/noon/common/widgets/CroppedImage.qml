import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

Image {
    id: root

    property color tintColor: Colors.m3.m3surfaceTint
    property bool tint: false
    property real tintLevel: 0.5
    property int radius: Rounding.verylarge

    visible: opacity > 0
    opacity: (status === Image.Ready) ? 1 : 0
    fillMode: Image.PreserveAspectCrop
    layer.enabled: radius > 1

    Rectangle {
        visible: root.tint
        anchors.fill: parent
        radius: root.radius
        color: root.tintColor
        opacity: 1 - root.tintLevel
    }

    Behavior on opacity {
        Anim {
        }

    }

    layer.effect: OpacityMask {

        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }

    }

}
