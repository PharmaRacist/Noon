pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property real scale: 0
    property real main: 0 // Mem.options.appearance.transparency ? Math.pow(scale, 1.4) * 0.9 : 0
    property real layers: 0 // 1 - Math.pow(1 - scale, 2.5)
}
