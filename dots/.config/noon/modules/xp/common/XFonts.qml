import QtQuick
import Quickshell
pragma Singleton

Singleton {
    property QtObject family
    property QtObject sizes

    family: QtObject {
        property string main: "Trebuchet MS"
        property string title: "Tahoma"
        readonly property string monospace: "Courier"
    }

    sizes: QtObject {
        readonly property real scale: 1
        readonly property int verysmall: 12 * scale
        readonly property int small: 14 * scale
        readonly property int normal: 16 * scale
        readonly property int large: 18 * scale
        readonly property int verylarge: 20 * scale
        readonly property int huge: 24 * scale
        readonly property int title: 46 * scale
        readonly property int subTitle: 32 * scale
    }

}
