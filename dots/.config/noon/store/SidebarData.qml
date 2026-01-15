pragma Singleton
import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import qs.common.functions
import qs.services

Singleton {
    id: root

    property int sidebarWidth
    property QtObject sizePresets: Sizes.sidebar

    readonly property var enabledCategories: Object.keys(registry).filter(key => (registry[key].enabled ?? true) && !registry[key].stealth)

    readonly property var registry: ({
            "Apps": {
                icon: "apps",
                componentPath: "apps/Apps",
                searchable: true,
                customSize: sizePresets.quarter,
                enabled: Mem.options.sidebar.content.apps

            },
            "API": {
                icon: "neurology",
                componentPath: "apis/ApisContent",
                expandable: true,
                customSize: sizePresets.half,
                enabled: Mem.options.sidebar.content.apis

            },
            "Web": {
                icon: "globe",
                componentPath: "web/WebBrowser",
                expandable: true,
                preExpand: true,
                async: true,
                searchable: true,
                customSize: sizePresets.half,
                enabled: Mem.options.sidebar.content.web

            },
            "Notifs": {
                icon: "notifications_active",
                componentPath: "notifs/Notifs",
                customSize: sizePresets.quarter,
                enabled: Mem.options.sidebar.content.notifs
            },
            "Walls": {
                icon: "image",
                componentPath: "wallpapers/WallpaperSelector",
                searchable: true,
                async: true,
                enabled: Mem.options.sidebar.content.wallpapers
            },
            "Gallery": {
                icon: "photo_library",
                componentPath: "gallary/GalleryWidget",
                expandable: true,
                customSize: sizePresets.threeQuarter,
                searchable: true,
                enabled: Mem.options.sidebar.content.gallery ?? true
            },
            "Tasks": {
                icon: "task_alt",
                componentPath: "tasks/KanbanWidget",
                expandable: true,
                customSize: sizePresets.half,
                enabled: Mem.options.sidebar.content.tasks
            },
            "Notes": {
                icon: "stylus",
                componentPath: "notes/Notes",
                expandable: true,
                customSize: sizePresets.half,
                enabled: Mem.options.sidebar.content.notes
            },
            "View": {
                icon: "ad",
                componentPath: "view/OverviewWidget",
                expandable: true,
                preExpand: true,
                customSize: sizePresets.overview,
                enabled: Mem.options.sidebar.content.overview
            },
            "Beats": {
                icon: "music_note",
                componentPath: "beats/Beats",
                enabled: Mem.options.sidebar.content.beats,
                colorful: true
            },
            "History": {
                icon: "content_paste",
                componentPath: "history/History",
                searchable: true,
                enabled: Mem.options.sidebar.content.history
            },
            "Games": {
                icon: "stadia_controller",
                componentPath: "games/GameLauncher",
                expandable: true,
                searchable: true,
                customSize: sizePresets.half - 80,
                colorful: true,
                enabled: Mem.options.sidebar.content.games
            },
            "Tweaks": {
                icon: "tune",
                componentPath: "settings/QuickSettings",
                expandable: true,
                searchable: true,
                customSize: sizePresets.threeQuarter,
                enabled: Mem.options.sidebar.content.tweaks
            },
            "Bookmarks": {
                icon: "bookmark",
                componentPath: "bookmarks/Bookmarks",
                searchable: true,
                enabled: Mem.options.sidebar.content.bookmarks
            },
            "Emojis": {
                icon: "sentiment_calm",
                componentPath: "emojis/Emojis",
                searchable: true,
                enabled: Mem.options.sidebar.content.emojis
            },
            "Session": {
                icon: "power_settings_new",
                componentPath: "session/PowerMenu",
                customSize: sizePresets.session,
                enabled: Mem.options.sidebar.content.session
            },
            "Shelf": {
                icon: "shelves",
                componentPath: "shelf/ShelfPanel",
                enabled: Mem.options.sidebar.content.shelf
            },
            "Widgets": {
                icon: "widgets",
                componentPath: "widgets/WidgetsPanel",
                enabled: Mem.options.sidebar.content.widgets
            },
            "Misc": {
                icon: "keyboard_option_key",
                componentPath: "misc/MiscWidget",
                enabled: Mem.options.sidebar.content.misc
            },
            "Bars": {
                componentPath: "barSwitcher/BarSwitcher",
                searchable: true,
                stealth: true
            },
            "Auth": {
                componentPath: "polkit/Polkit",
                stealth: true
            }
        })

    // Removed the "Apps" fallback here so it can return undefined
    function _get(id) {
        return registry[id];
    }

    function getCategory(id) {
        return _get(id);
    }
    function getIcon(id) {
        return _get(id)?.icon || "";
    }
    function getComponentPath(id) {
        const c = _get(id);
        return c ? "components/" + c.componentPath + ".qml" : "";
    }
    function isColorful(id) {
        return !!_get(id)?.colorful;
    }
    function isSearchable(id) {
        return !!_get(id)?.searchable;
    }
    function isAsync(id) {
        return !!_get(id)?.async;
    }
    function isExpandable(id) {
        return !!_get(id)?.expandable;
    }
    function usePreExpand(id) {
        return !!_get(id)?.preExpand;
    }
    function isStealth(id) {
        return !!_get(id)?.stealth;
    }

    function currentSize(barMode, expanded, id) {
        if (barMode)
            return sizePresets.bar + Padding.large;
        const c = registry[id];
        if (!c)
            return sizePresets.bar;
        return (expanded && c.expandable) ? c.customSize : (id === "Session" ? sizePresets.session : sizePresets.quarter);
    }

    function _navigate(id, step) {
        const v = enabledCategories;
        if (v.length === 0)
            return "";
        const i = v.indexOf(id);
        if (i !== -1)
            return v[(i + step + v.length) % v.length];
        return v[0];
    }

    function getNextEnabledCategory(id) {
        return _navigate(id, 1);
    }
    function getPreviousEnabledCategory(id) {
        return _navigate(id, -1);
    }
}
