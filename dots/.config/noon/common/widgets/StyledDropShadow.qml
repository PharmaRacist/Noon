import Qt5Compat.GraphicalEffects
import QtQuick
import qs.common

DropShadow {
    required property var target

    source: target
    anchors.fill: source
    radius: 8
    samples: radius * 2 + 1
    color: Colors.colShadow
    transparentBorder: true
}
