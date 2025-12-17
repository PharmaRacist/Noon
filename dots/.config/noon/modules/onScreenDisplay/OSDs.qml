import "."
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.utils

Scope {
    WidgetLoader {
        enabled: Mem.options.osd.enabled
        OnScreenDisplayBrightness {}
    }
    WidgetLoader {
        enabled: Mem.options.osd.enabled
        OnScreenDisplayVolume {}
    }
}
