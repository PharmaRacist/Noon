pragma Singleton
import QtQuick
import qs.common
import qs.common.utils
import qs.store

Singleton {
    id: root
    readonly property bool enablePlugins: true
    readonly property alias sidebarPlugins: sidebar?.plugins
    readonly property alias dockPlugins: dock?.plugins

    PluginExtractor {
        id: dock
        group: "dock"
    }

    PluginExtractor {
        id: sidebar
        group: "sidebar"
        onPluginsChanged: SidebarData.rebuildAll()
    }

    IpcHandler {
        target: "plugins"
        function reload(): void {
            dock.refresh();
            sidebar.refresh();
        }
    }
}
