import QtQuick
import qs.common
import qs.common.widgets

ApplicationSkeleton {
    id: root
    title: "settings"
    states_target: "settings"
    contentItem: SettingsPreview {
        window: root
    }
    secondary_content_item: SettingsList {}
}
