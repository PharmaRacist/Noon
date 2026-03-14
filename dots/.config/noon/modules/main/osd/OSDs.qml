import qs.common
import qs.common.utils

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
