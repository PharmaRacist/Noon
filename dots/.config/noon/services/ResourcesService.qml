pragma Singleton
pragma ComponentBehavior: Bound
import Noon.Utils
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.common
import qs.common.utils

Singleton {
    id: root
    property alias stats: watcher.stats

    ResourcesWatcher {
        id: watcher
    }
}
