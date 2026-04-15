pragma Singleton
import QtQuick
import qs.common
import qs.common.utils
import qs.store

Singleton {
    id: root
    readonly property bool enablePlugins: true
    readonly property alias sidebarPlugins: sidebar?.plugins

    PluginExtractor {
        id: sidebar
        dir: Directories.plugins.sidebar
        onPluginsChanged: SidebarData.rebuildAll()
    }
}
