import QtQuick
import QtQuick.Effects
import qs.modules.common

RectangularShadow {
    property var target: parent
    z: -9999
    anchors.fill: target
    radius: target?.radius || Rounding.verylarge
    // offset.x: -2
    // offset.y: -5
    blur: 10
    spread: 1.7
    color: Colors.colShadow
    cached: true
}
