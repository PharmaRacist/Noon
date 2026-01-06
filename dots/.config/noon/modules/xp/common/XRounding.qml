import QtQuick
import Quickshell
pragma Singleton

Singleton {
    readonly property real scale: 1
    readonly property real tiny: 2 * scale
    readonly property real small: 6 * scale
    readonly property real normal: 10 * scale
    readonly property real large: 14 * scale
    readonly property real verylarge: 18 * scale
}
