import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Image {
    id: root
    visible: opacity > 0
    opacity: (status === Image.Ready) ? 1 : 0
    fillMode: Image.PreserveAspectCrop
    Behavior on opacity {
        Anim {}
    }
    property color tintColor: Colors.m3.m3surfaceTint
    property bool tint: false
    property real tintLevel: 0.5
    property int radius: Rounding.verylarge
    layer.enabled: radius > 1
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }
    }
    Rectangle {
        visible: root.tint
        anchors.fill: parent
        radius: root.radius
        color: root.tintColor
        opacity: 1 - root.tintLevel
    }
}
