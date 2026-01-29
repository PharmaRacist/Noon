import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import qs.modules.main
import qs.modules.main.sidebar
import qs.modules.main.osd
import "desktop"
import "bar"
import "dock"
import "notifs"
import "db"

Scope {
    GWallpaper {}
    GIPC {}
    GBar {}
    GDock {}
    OSDs {}
    // temp
    Sidebar {
        rightMode: true
    }
    WidgetLoader {
        enabled: GlobalStates.nobuntu.db.show
        DB {}
    }
    WidgetLoader {
        enabled: GlobalStates.nobuntu.notifs.show
        GNotifs {}
    }
}
