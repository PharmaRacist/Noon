import QtQuick
import Quickshell
import qs.common
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root

    property real scale: Mem.options.appearance.padding.scale ?? 1
    property int tiny: 2 * scale
    property int verysmall: 4 * scale
    property int small: 6 * scale
    property int normal: 8 * scale
    property int large: 10 * scale
    property int verylarge: 12 * scale
    property int huge: 14 * scale
    property int veryhuge: 16 * scale
    property int gigantic: 18 * scale
    property int massive: 20 * scale
}
