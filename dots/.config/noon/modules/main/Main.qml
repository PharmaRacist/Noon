import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.modules.main.view
import qs.modules.main.bar
import qs.modules.main.desktop.bg
import qs.common
import qs.common.utils
import qs.modules.main.dock
import qs.modules.main.lock
import qs.modules.main.notificationPopup
import qs.modules.main.onScreenDisplay
import qs.modules.main.sidebar
import qs.modules.main.beam

Scope {
    Component.onCompleted:GlobalStates.handle_init()

    WidgetLoader {
        enabled: Mem.options.desktop.bg.useQs && Mem.states.desktop.bg.currentBg.length > 1 && !ToplevelManager?.activeToplevel?.fullscreen && !Mem.states.desktop.bg.isLive
        Bg {}
    }

    WidgetLoader {
        enabled: Mem.options.desktop.bg.borderMultiplier > 0
        Border {}
    }
    
    WidgetLoader {
        enabled: true
        Sidebar {}
    }

    WidgetLoader {
        enabled: true
        NotificationPopup {}
    }

    WidgetLoader {
        enabled: Mem.options.dock.enabled
        Dock {}
    }
    WidgetLoader {
        enabled: Mem.options.desktop.lock.enabled
        Lock {}
    }
    WidgetLoader {
        enabled: Mem.options.bar.enabled
        Bar {}
    }
    WidgetLoader {
        enabled: Mem.options.desktop.screenCorners > 0 ?? false
        ScreenCorners {}
    }
    WidgetLoader {
        enabled: Mem.options.osd.enabled
        OSDs {}
    }
    WidgetLoader {
        Hyprview {}
    }
    WidgetLoader {
        Beam {}
    }
}
