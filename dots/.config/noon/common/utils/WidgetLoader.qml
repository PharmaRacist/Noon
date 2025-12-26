import QtQuick
import Quickshell
import qs.common

LazyLoader {
    property bool enabled: true

    active: enabled && Mem.ready
    component: children[0]
}
