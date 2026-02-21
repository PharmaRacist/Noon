pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.common.utils
import qs.common.functions
import qs.services

Singleton {
    id: root

    property int sidebarWidth
    readonly property QtObject sizePresets: Sizes.sidebar
    readonly property var enabledCategories: Object.keys(registry).filter(key => (registry[key].enabled ?? true) && !registry[key].stealth && (registry[key].shell === undefined || registry[key].shell === Mem.options.desktop.shell.mode))
    readonly property var registry: {
        "Apps": {
            icon: "rocket",
            activeIcon: "rocket_launch",
            shell: "main",
            componentPath: "etc/Apps",
            searchable: true,
            expandSize: sizePresets.quarter,
            shape: MaterialShape.Shape.Ghostish,
            enabled: Mem.options.sidebar.content.apps,
            async: true
        },
        "API": {
            icon: "cognition",
            activeIcon: "cognition_2",
            componentPath: "apis/Apis",
            expandable: true,
            enabled: Mem.options.sidebar.content.apis
        },
        "Web": {
            icon: "globe",
            componentPath: "web/WebBrowser",
            expandable: true,
            preExpand: true,
            async: true,
            on_accepted_only: true,
            searchable: true,
            shape: MaterialShape.Shape.Ghostish,
            enabled: Mem.options.sidebar.content.web
        },
        "Notifs": {
            icon: "notifications",
            activeIcon: "notifications_active",
            shell: "main",
            componentPath: "notifs/Notifs",
            expandSize: sizePresets.quarter,
            enabled: Mem.options.sidebar.content.notifs
        },
        "Walls": {
            icon: "gallery_thumbnail",
            activeIcon: "image",
            componentPath: "wallpapers/WallpaperSelector",
            async: true,
            searchable: true,
            shape: MaterialShape.Shape.Ghostish,
            enabled: Mem.options.sidebar.content.wallpapers
        },
        "Tasks": {
            icon: "task_alt",
            activeIcon: "add_task",
            componentPath: "tasks/Kanban",
            expandable: true,
            enabled: Mem.options.sidebar.content.tasks
        },
        "Notes": {
            icon: "stylus",
            activeIcon: "stylus_note",
            componentPath: "etc/Notes",
            expandable: true,
            enabled: Mem.options.sidebar.content.notes
        },
        "View": {
            icon: "ad",
            activeIcon: "view_cozy",
            componentPath: "view/Overview",
            expandable: true,
            preExpand: true,
            expandSize: sizePresets.overview,
            enabled: Mem.options.sidebar.content.overview
        },
        "Beats": {
            icon: "music_note",
            activeIcon: "music_note_add",
            shell: "main",
            componentPath: "beats/Beats",
            enabled: Mem.options.sidebar.content.beats,
            colors: BeatsService.colors
        },
        "History": {
            icon: "content_paste",
            activeIcon: "inventory",
            shell: "main",
            componentPath: "etc/History",
            searchable: true,
            shape: MaterialShape.Shape.Ghostish,
            enabled: Mem.options.sidebar.content.history
        },
        "Games": {
            icon: "stadia_controller",
            activeIcon: "joystick",
            componentPath: "games/Games",
            expandable: true,
            searchable: true,
            shape: MaterialShape.Shape.Ghostish,
            expandSize: sizePresets.half - 80,
            colors: GameLauncherService.colors,
            enabled: Mem.options.sidebar.content.games
        },
        "Tweaks": {
            icon: "settings",
            activeIcon: "settings_heart",
            shell: "main",
            componentPath: "settings/QuickSettings",
            expandable: true,
            searchable: true,
            expandSize: sizePresets.threeQuarter,
            shape: MaterialShape.Shape.Ghostish,
            enabled: Mem.options.sidebar.content.tweaks
        },
        "Bookmarks": {
            icon: "bookmark",
            activeIcon: "bookmark_heart",
            componentPath: "etc/Bookmarks",
            searchable: true,
            shape: MaterialShape.Shape.Ghostish,
            enabled: Mem.options.sidebar.content.bookmarks
        },
        "Emojis": {
            icon: "sentiment_calm",
            activeIcon: "favorite",
            componentPath: "etc/Emojis",
            searchable: true,
            shape: MaterialShape.Shape.Ghostish,
            enabled: Mem.options.sidebar.content.emojis
        },
        "Shelf": {
            icon: "shelves",
            activeIcon: "book_ribbon",
            componentPath: "shelf/Shelf",
            enabled: Mem.options.sidebar.content.shelf
        },
        "Widgets": {
            icon: "widgets",
            activeIcon: "ripples",
            componentPath: "widgets/Widgets",
            enabled: Mem.options.sidebar.content.widgets
        },
        "Sounds": {
            icon: "more_horiz",
            activeIcon: "all_inclusive",
            componentPath: "sounds/Sounds",
            enabled: Mem.options.sidebar.content.sounds
        },
        "Timers": {
            icon: "timer",
            componentPath: "timers/Timers",
            enabled: Mem.options.sidebar.content.timers
        },
        "Share": {
            icon: "share",
            componentPath: "share/Share",
            enabled: Mem.options.sidebar.content.share
        },
        "Deen": {
            icon: "mosque",
            expandable: true,
            componentPath: "deen/Deen",
            enabled: Mem.options.sidebar.content.islam
        },
        "Session": {
            icon: "power_settings_new",
            componentPath: "etc/Session",
            enabled: Mem.options.sidebar.content.session
        },
        "DMenu": {
            icon: "dashboard",
            componentPath: "etc/DMenu",
            searchable: true,
            stealth: true
        },
        "Bars": {
            componentPath: "etc/BarSwitcher",
            shape: MaterialShape.Shape.Ghostish,
            searchable: true,
            shell: "main",
            stealth: true
        },
        "Auth": {
            componentPath: "etc/Polkit",
            stealth: true
        }
    }

    function _get(id) {
        return registry[id];
    }
    function getColors(id) {
        return _get(id)?.colors ?? Colors;
    }
    function getCategory(id) {
        return _get(id);
    }
    function getShape(id) {
        return _get(id)?.shape || "";
    }
    function getIcon(id, active = false) {
        return active ? _get(id)?.activeIcon : _get(id)?.icon;
    }
    function getComponentPath(id) {
        const c = _get(id);
        return c ? "components/" + c.componentPath + ".qml" : "";
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
        const content = registry[id];
        if (barMode || !content)
            return sizePresets.bar;
        if (id === "Session")
            return sizePresets.session;

        return (expanded && content.expandable) ? content.expandSize ?? sizePresets.half : sizePresets.quarter;
    }

    function _navigate(id, step) {
        const v = enabledCategories;
        const i = v.indexOf(id);
        return i > 0 ? v[(i + step + v.length) % v.length] : v[0];
    }

    function getNextEnabledCategory(id) {
        return _navigate(id, 1);
    }
    function getPreviousEnabledCategory(id) {
        return _navigate(id, -1);
    }
}
