pragma Singleton
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.services
import qs.store

Singleton {
    id: root
    property int sidebarWidth
    readonly property var sizePresets: ({
            bar: Sizes.collapsedSideBarWidth ?? 50,
            contentQuarter: Math.round(Screen.width * 0.235) - Sizes.collapsedSideBarWidth,
            half: Math.round(Screen.width * 0.457),
            full: Screen.width,
            quarter: Math.round(Screen.width * 0.246),
            threeQuarter: Math.round(Screen.width * 0.85),
            session: 280,
            overview: 1250
        })

    // Simple category definitions - static, no Component.onCompleted needed
    readonly property var categories: [
        {
            id: "Apps",
            name: "Apps",
            icon: "apps",
            placeholder: qsTr("Search applications..."),
            component: Mem.options.sidebarLauncher.appearance.useAppListView ? "AppListView" : "AppGridView",
            searchable: true,
            hasModel: true,
            customSize: sizePresets.quarter,
            enabled: true
        },
        {
            id: "API",
            name: "APIs",
            icon: "neurology",
            component: "API",
            expandable: true,
            overlay: true,
            customSize: sizePresets.half,
            enabled: true
        },
        {
            id: "Notifs",
            name: "Notifs",
            icon: "notifications_active",
            component: "StyledNotifications",
            customSize: sizePresets.quarter,
            enabled: Mem.options.sidebarLauncher.content.notifs
        },
        {
            id: "Walls",
            name: "Walls",
            icon: "image",
            placeholder: qsTr("Search Wallpapers..."),
            component: "WallpaperSelector",
            expandable: true,
            searchable: true,
            customSize: sizePresets.threeQuarter,
            enabled: Mem.options.sidebarLauncher.content.wallpapers
        },
        {
            id: "Gallery",
            name: "Gallery",
            icon: "photo_library",
            placeholder: qsTr("Search gallery..."),
            component: "GalleryWidget",
            expandable: true,
            customSize: sizePresets.threeQuarter,
            searchable: true,
            hasModel: true,
            folderPath: Qt.resolvedUrl(Directories.gallery),
            nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp"],
            enabled: Mem.options.sidebarLauncher.content.gallery ?? true
        },
        {
            id: "Tasks",
            name: "Tasks",
            icon: "task_alt",
            component: "KanbanWidget",
            expandable: true,
            preExpand: false,
            customSize: sizePresets.half,
            enabled: Mem.options.sidebarLauncher.content.tasks
        },
        {
            id: "Notes",
            name: "Notes",
            icon: "stylus",
            component: "Notes",
            expandable: true,
            customSize: sizePresets.half,
            enabled: Mem.options.sidebarLauncher.content.notes
        },
        {
            id: "View",
            name: "View",
            icon: "ad",
            component: "OverviewWidget",
            expandable: true,
            preExpand: true,
            customSize: sizePresets.overview,
            enabled: Mem.options.sidebarLauncher.content.overview
        },
        {
            id: "Beats",
            name: "Beats",
            icon: "music_note",
            component: "Beats",
            expandable: true,
            customSize: sizePresets.half,
            preExpand: false,
            enabled: Mem.options.sidebarLauncher.content.beats
        },
        {
            id: "Bars",
            name: "Bars",
            icon: "format_paint",
            placeholder: qsTr("Search bar layouts..."),
            component: "AppListView",
            searchable: true,
            hasModel: true,
            useListView: true,
            customSize: sizePresets.quarter,
            enabled: Mem.options.sidebarLauncher.content.barSwitcher
        },
        {
            id: "Emojis",
            name: "Emojis",
            icon: "emoji_emotions",
            placeholder: qsTr("Search emojis..."),
            component: "AppGridView",
            searchable: true,
            hasModel: true,
            customSize: sizePresets.quarter,
            enabled: Mem.options.sidebarLauncher.content.emojies
        },
        {
            id: "History",
            name: "History",
            icon: "content_paste",
            placeholder: qsTr("Search history..."),
            component: "AppListView",
            searchable: true,
            hasModel: true,
            useListView: true,
            customSize: sizePresets.quarter,
            enabled: Mem.options.sidebarLauncher.content.history
        },
        {
            id: "Games",
            name: "Games",
            icon: "stadia_controller",
            component: "Games",
            expandable: true,
            preExpand: true,
            searchable: true,
            customSize: sizePresets.half,
            enabled: Mem.options.sidebarLauncher.content.games
        },
        {
            id: "Tweaks",
            name: "Tweaks",
            icon: "tune",
            component: "Tweaks",
            expandable: true,
            searchable: true,
            customSize: sizePresets.threeQuarter,
            enabled: Mem.options.sidebarLauncher.content.tweaks
        },
        {
            id: "Docs",
            name: "Docs",
            icon: "description",
            placeholder: qsTr("Search docs..."),
            component: "AppListView",
            searchable: true,
            hasModel: true,
            useListView: true,
            customSize: sizePresets.quarter,
            folderPath: Qt.resolvedUrl(Directories.notes),
            nameFilters: ["*.pdf", "*.docx", "*.md", "*.txt", "*.rtf", "*.odt"],
            enabled: Mem.options.sidebarLauncher.content.documents
        },
        {
            id: "Movies",
            name: "Movies",
            icon: "movie",
            placeholder: qsTr("Search movies..."),
            component: "AppListView",
            searchable: true,
            hasModel: true,
            useListView: true,
            customSize: sizePresets.quarter,
            folderPath: Directories.videos,
            nameFilters: ["*.mp4", "*.mkv", "*.avi", "*.mov", "*.wmv", "*.flv"],
            enabled: Mem.options.sidebarLauncher.content.movies
        },
        {
            id: "Bookmarks",
            name: "Bookmarks",
            icon: "bookmark",
            placeholder: qsTr("Search bookmarks..."),
            component: "AppListView",
            searchable: true,
            hasModel: true,
            useListView: true,
            customSize: sizePresets.quarter,
            enabled: Mem.options.sidebarLauncher.content.bookmarks ?? true
        },
        {
            id: "Misc",
            name: "Misc",
            icon: "more_horiz",
            component: "MiscComponent",
            overlay: true,
            customSize: sizePresets.quarter,
            enabled: Mem.options.sidebarLauncher.content.misc
        },
        {
            id: "Auth",
            name: "Auth",
            icon: "lock",
            component: "Auth",
            overlay: true,
            customSize: sizePresets.quarter,
            enabled: false
        },
        {
            id: "Session",
            name: "Session",
            icon: "power_settings_new",
            component: "PowerMenu",
            overlay: true,
            customSize: sizePresets.session,
            enabled: Mem.options.sidebarLauncher.content.session
        },
    ]

    // Build lookup structures from categories array
    readonly property var categoryMap: {
        const map = {};
        for (let i = 0; i < categories.length; i++) {
            map[categories[i].id] = categories[i];
        }
        return map;
    }

    readonly property var enabledCategories: {
        const enabled = [];
        for (let i = 0; i < categories.length; i++) {
            if (categories[i].enabled) {
                enabled.push(categories[i].id);
            }
        }
        return enabled;
    }

    // Keep old API for compatibility
    readonly property var registry: categoryMap

    // Simple getter functions
    function getCategory(catId) {
        return categoryMap[catId] || categoryMap["Apps"];
    }

    function getIcon(catId) {
        const cat = getCategory(catId);
        return cat.icon || "apps";
    }

    function getPlaceholder(catId) {
        const cat = getCategory(catId);
        return cat.placeholder || qsTr("Search...");
    }

    function getComponent(catId) {
        const cat = getCategory(catId);
        return cat.component || "AppGridView";
    }

    function isSearchable(catId) {
        const cat = getCategory(catId);
        return cat.searchable ?? false;
    }

    function hasModel(catId) {
        const cat = getCategory(catId);
        return cat.hasModel ?? false;
    }

    function isExpandable(catId) {
        const cat = getCategory(catId);
        return cat.expandable ?? false;
    }

    function usePreExpand(catId) {
        const cat = getCategory(catId);
        return cat.preExpand ?? false;
    }

    function isOverlay(catId) {
        const cat = getCategory(catId);
        return cat.overlay ?? false;
    }

    function currentSize(barMode, expanded, selectedCategory) {
        if (barMode)
            return sizePresets.bar + Padding.large;

        const cat = getCategory(selectedCategory);
        if (expanded && cat.expandable)
            return cat.customSize;

        return selectedCategory === "Session" ? sizePresets.session : sizePresets.quarter;
    }

    function getNextEnabledCategory(currentId) {
        const idx = enabledCategories.indexOf(currentId);
        if (idx === -1)
            return enabledCategories[0] || "";
        return enabledCategories[(idx + 1) % enabledCategories.length] || "";
    }

    function getPreviousEnabledCategory(currentId) {
        const idx = enabledCategories.indexOf(currentId);
        if (idx === -1)
            return enabledCategories[0] || "";
        return enabledCategories[(idx - 1 + enabledCategories.length) % enabledCategories.length] || "";
    }

    // Data generation
    function generateData(catId, searchText, params) {
        switch (catId) {
        case "Apps":
            return generateApps(searchText);
        case "Bars":
            return generateBarLayouts(searchText, params);
        case "Emojis":
            return generateEmojis(searchText, params);
        case "History":
            return generateHistory(searchText);
        case "Bookmarks":
            return generateBookmarks(searchText);
        default:
            return [];
        }
    }

    function generateApps(query) {
        const q = (query || "").trim().toLowerCase();
        const allEntries = [...DesktopEntries.applications.values];
        let results = q === "" ? allEntries : allEntries.filter(entry => entry.name?.toLowerCase().includes(q) || entry.genericName?.toLowerCase().includes(q) || entry.comment?.toLowerCase().includes(q) || (entry.keywords && entry.keywords.some(kw => kw.toLowerCase().includes(q))));

        results.sort((a, b) => (a.name || "").localeCompare(b.name || ""));

        return results.map(entry => ({
                    id: entry.id,
                    name: entry.name,
                    command: Array.isArray(entry.command) ? entry.command.join(' ') : String(entry.command || ""),
                    execString: Array.isArray(entry.execString) ? entry.execString.join(' ') : String(entry.execString || ""),
                    iconImage: entry.icon || entry.genericIcon || "applications-system",
                    clickActionName: qsTr("Launch"),
                    type: qsTr("App")
                }));
    }

    function generateBarLayouts(query, params) {
        const lower = (query || "").toLowerCase();
        const results = [];

        const addLayouts = (layouts, isVert) => {
            if (!layouts)
                return;
            layouts.forEach((layout, idx) => {
                const name = layout.replace('Layout', '');
                if (!query || name.toLowerCase().includes(lower)) {
                    const isActive = isVert ? params.isVerticalBar && params.currentVerticalLayout === idx : !params.isVerticalBar && params.currentHorizontalLayout === idx;

                    results.push({
                        name: `${name} (${isVert ? 'Vertical' : 'Horizontal'})`,
                        icon: isActive ? 'radio_button_checked' : 'radio_button_unchecked',
                        materialSymbol: isActive ? 'radio_button_checked' : 'radio_button_unchecked',
                        clickActionName: qsTr("Switch"),
                        type: isActive ? qsTr("Bar Layout (Active)") : qsTr("Bar Layout"),
                        categories: ["BarLayout"],
                        layoutIndex: idx,
                        isVertical: isVert,
                        id: ""
                    });
                }
            });
        };

        addLayouts(params.horizontalLayouts, false);
        addLayouts(params.verticalLayouts, true);
        return results;
    }

    function generateEmojis(query, params) {
        const source = (query || "").trim() === "" ? (params.frequentEmojis || []) : Emojis.fuzzyQuery(query);

        return source.map(e => ({
                    cliphistRawString: e,
                    bigText: e.match(/^\s*(\S+)/)?.[1] || "",
                    name: e.replace(/^\s*\S+\s+/, ""),
                    icon: e.match(/^\s*(\S+)/)?.[1] || "",
                    clickActionName: qsTr("Copy"),
                    type: qsTr("Emoji"),
                    categories: ["Emojis"],
                    id: ""
                }));
    }

    function generateHistory(query) {
        const results = Cliphist.fuzzyQuery(query || "");
        return results.map(str => {
            const id = Number(str.split("\t")[0]);
            const isImage = Cliphist.entryIsImage(str);
            const content = StringUtils.cleanCliphistEntry(str);

            let displayName = content;
            let imagePath = "";

            if (isImage) {
                imagePath = Cliphist.decodeImageEntry(str);
                const descMatch = content.split("]]")[1];
                displayName = descMatch?.trim() || "Image";
            }

            return {
                cliphistRawString: str,
                name: displayName,
                icon: isImage ? "image" : "",
                clickActionName: qsTr("Copy"),
                type: isImage ? qsTr("Image") : `#${id}`,
                categories: ["History"],
                id: id.toString(),
                isImage: isImage,
                imagePath: imagePath
            };
        });
    }

    function generateBookmarks(query) {
        const bookmarks = FirefoxBookmarksService.bookmarks || [];
        if (bookmarks.length === 0)
            return [];

        const lower = (query || "").toLowerCase();
        const filtered = bookmarks.filter(b => !query || b.title?.toLowerCase().includes(lower) || b.url?.toLowerCase().includes(lower));

        return filtered.map(bookmark => ({
                    name: bookmark.title || "Untitled",
                    icon: bookmark.favicon_local || bookmark.favicon_url || "bookmark",
                    materialSymbol: (bookmark.favicon_local || bookmark.favicon_url) ? "" : "bookmark",
                    faviconLocal: !!(bookmark.favicon_local || bookmark.favicon_url),
                    clickActionName: qsTr("Open"),
                    type: qsTr("Bookmark"),
                    categories: ["Bookmarks"],
                    url: bookmark.url,
                    id: bookmark.id?.toString() || "",
                    faviconUrl: bookmark.favicon_url || ""
                }));
    }

    // Launch handlers
    // Launch handlers
    function launch(catId, app, layoutSwitcher, isAux = false) {
        switch (catId) {
        case "Apps":
            launchApp(app, isAux);
            break;
        case "Bars":
            if (layoutSwitcher) {
                layoutSwitcher(app.layoutIndex, app.isVertical);
            }
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            break;
        case "Emojis":
            Noon.exec(`wl-copy '${StringUtils.shellSingleQuoteEscape(app.bigText)}'`);
            Emojis.recordEmojiUse(app.cliphistRawString);
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            break;
        case "History":
            Cliphist.copy(app.cliphistRawString);
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            break;
        case "Bookmarks":
            FirefoxBookmarksService.openUrl(app.url);
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            break;
        case "Docs":
            if (app.path) {
                Noon.exec(`xdg-open "${app.path}"`);
            }
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            break;
        case "Movies":
            if (app.path) {
                Noon.exec(`xdg-open "${app.path}"`);
            }
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            break;
        case "Gallery":
        case "Gallary":
            if (app.path) {
                Noon.exec(`xdg-open "${app.path}"`);
            }
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            break;
        default:
            console.warn("No launch handler for", catId);
        }
    }

    function altLaunch(app, isAux = false) {
        if (!app)
            return;
        const cat = getCategory(root.selectedCategory);
        if (cat.altLaunch) {
            cat.altLaunch(app, switchToLayout);
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
        }
    }

    function launchApp(app, isAux = false) {
        if (!app)
            return;
        if (app.execute) {
            app.execute();
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            return;
        }
        if (app.onClick) {
            app.onClick();
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
            return;
        }
        const entry = DesktopEntries.byId(app.id);
        if (entry) {
            Noon.playSound("event_accepted");
            entry.execute();
            if (!isAux) {
                Noon.callIpc("sidebar_launcher hide");
            }
        }
    }
}
