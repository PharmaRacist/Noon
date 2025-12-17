import Quickshell
import QtQuick
import qs.modules.common

LazyLoader {
    property bool enabled: true
    active: enabled && Mem.ready
    component:children[0]
}
