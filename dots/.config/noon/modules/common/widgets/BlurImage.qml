import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Image {
    id: root
    retainWhileLoading: true
    visible: opacity > 0
    opacity: (status === Image.Ready) ? 1 : 0
    fillMode: Image.PreserveAspectCrop
    Behavior on opacity {
        Anim {}
    }
    property bool blur: false
    property color tintColor: Colors.m3.m3surfaceTint
    property bool tint: false
    property real tintLevel: 0.5

    layer.enabled: blur
    layer.effect: MultiEffect {
        source: root
        saturation: 0.2
        blurEnabled: true
        blurMax: 25
        blur: 2
    }
    Rectangle {
        visible: root.tint
        anchors.fill: parent
        color: root.tintColor
        opacity: 1 - root.tintLevel
    }
}
