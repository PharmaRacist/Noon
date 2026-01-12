import QtQuick
import qs.common
import qs.common.utils
import "bar"
import "beam"
import "desktop/bg"
import "dock"
import "lock"
import "notificationPopup"
import "onScreenDisplay"
import "sidebar"
import "view"
import "screenshot"

Scope {
    Component.onCompleted: GlobalStates.main.handle_init()

    WidgetLoader {
        enabled: Mem.options.desktop.bg.useQs && Mem.states.desktop.bg.currentBg.length > 1 && (Mem.options.desktop.bg.deloadOnFullscreen ? !GlobalStates.topLevel.fullscreen : true) && !Mem.states.desktop.bg.isLive

        Bg {}
    }

    WidgetLoader {
        enabled: Mem.options.desktop.bg.borderMultiplier > 0

        Border {}
    }
    WidgetLoader {
        enabled: GlobalStates.main.showScreenshot
        Screenshot {}
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

    WidgetLoader {
        IPC {}
    }
}
