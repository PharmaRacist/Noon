import QtQuick
import Quickshell
import qs.common

LazyLoader {
    property bool enabled: true
    property var reloadOn
    onReloadOnChanged: {
        active = false;
        active = true;
    }
    active: enabled && Mem.ready
    component: children[0]
}
