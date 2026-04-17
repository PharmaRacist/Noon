pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.common.utils
import qs.store

Singleton {
    id: root

    readonly property bool enablePlugins: true
    readonly property alias sidebarPlugins: sidebar?.plugins
    readonly property alias dockPlugins: dock?.plugins
    readonly property alias beamPlugins: beam?.plugins

    PluginExtractor {
        id: dock
        group: "dock"
    }

    PluginExtractor {
        id: beam
        group: "beam"
        onPluginsChanged: root.buildBeamPlugins()
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
            beam.refresh();
        }
    }
}
