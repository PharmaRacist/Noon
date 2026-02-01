pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    readonly property var db: [
        {
            id: "resources",
            expandable: true,
            component: "Resources",
            materialIcon: "memory"
        },
        {
            id: "battery",
            expandable: false,
            component: "Battery",
            materialIcon: "battery_full"
        },
        {
            id: "simple_clock",
            expandable: false,
            component: "Clock_Simple",
            materialIcon: "schedule"
        },
        {
            id: "bluetooth",
            expandable: false,
            component: "Bluetooth",
            materialIcon: "bluetooth"
        },
        {
            id: "media",
            expandable: true,
            component: "Media",
            materialIcon: "music_note"
        },
        {
            id: "combo",
            expandable: true,
            component: "ClockWeatherCombo",
            materialIcon: "wb_twilight"
        },
        {
            id: "net",
            expandable: false,
            component: "NetworkSpeed",
            materialIcon: "network_check"
        },
        {
            id: "cal",
            expandable: true,
            component: "Calendar",
            materialIcon: "calendar_today"
        },
        {
            id: "pill",
            expandable: false,
            component: "Weather_Simple",
            materialIcon: "cloud"
        }
    ]
}
