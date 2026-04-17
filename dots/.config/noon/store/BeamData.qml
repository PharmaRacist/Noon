pragma Singleton
import Noon.Services
import QtQuick
import Quickshell

import qs.common
import qs.common.widgets
import qs.common.utils
import qs.services

Singleton {
    id: root

    property string query: ""
    property string activeState: "ai"
    property string modelName: Ai?.getModel(Mem.options.ai?.model ?? "")?.name ?? "AI"
    property string activeSubState: ""
    property var suggestedApp: null
    readonly property string cleanQuery: {
        if (query.length === 0)
            return "";
        const prefix = config?.prefix || "";
        return prefix !== "" ? query.substring(prefix.length).trim() : query.trim();
    }

    readonly property var config: registry[activeState]

    readonly property var subConfig: {
        if (!activeSubState || !config.subStates)
            return null;
        return config.subStates[activeSubState] || null;
    }
    property string activeHint

    readonly property var registry: {
        "ai": {
            prefix: "",
            icon: "thread_unread",
            shape: MaterialShape.Shape.Ghostish,
            placeholder: "Ask " + root.modelName + " Any Thing ..",
            showHint: false,
            showOsrButton: true,
            hinter: () => "",
            executor: () => {
                if (Mem.options.beam.behavior.clearAiChatBeforeSearch)
                    Ai.clearMessages();
                Ai.sendUserMessage(query);
                NoonUtils.callIpc("sidebar reveal API");
            }
        },
        "commands": {
            prefix: ";",
            icon: "keyboard_return",
            shape: MaterialShape.Shape.Oval,
            placeholder: "Command Master ..",
            showHint: true,
            showOsrButton: false,
            hinter: () => {
                if (NoonUtils.avilableSystemCommands.length < 1)
                    NoonUtils.fetchCommands();
                const q = cleanQuery.toLowerCase();
                for (let cmd of NoonUtils.avilableSystemCommands) {
                    if (cmd.toLowerCase().startsWith(q))
                        return cmd;
                }
                return "";
            },
            executor: () => Quickshell.execDetached(["bash", "-c", cleanQuery])
        },
        "calc": {
            prefix: "=",
            icon: "calculate",
            shape: MaterialShape.Shape.Hexagon,
            placeholder: "Calculate ..",
            showHint: true,
            showOsrButton: false,
            hinter: () => {
                if (cleanQuery.length > 0) {
                    QalcService.calculate(cleanQuery, result => {
                        if (activeState === "calc")
                            activeHint = result;
                    });
                }
                return activeHint;
            },
            executor: () => {
                if (QalcService.result)
                    ClipboardService.copy(QalcService.result);
            }
        },
        "install": {
            prefix: "$",
            icon: "deployed_code_update",
            shape: MaterialShape.Shape.SoftBurst,
            placeholder: "Install ..",
            showHint: false,
            showOsrButton: false,
            hinter: () => "",
            executor: () => NoonUtils.installPkg(cleanQuery)
        },
        "note": {
            prefix: ",",
            icon: "stylus",
            shape: MaterialShape.Shape.Slanted,
            placeholder: "Note ..",
            showHint: false,
            showOsrButton: false,
            hinter: () => "",
            executor: () => {
                const separator = Mem.options.beam.behavior.addSeparatorForNotes ? "\n - - - " : "";
                NotesService.note(cleanQuery + separator);
            }
        },
        "alarm": {
            prefix: "`",
            icon: "timer",
            shape: MaterialShape.Shape.Diamond,
            placeholder: "I Can Wake You ..",
            showHint: false,
            showOsrButton: false,
            hinter: () => "",
            executor: () => {
                AlarmService.addTimer(cleanQuery, "Beam Timer");
                if (Mem.options.beam.behavior.revealLauncherOnAction) {
                    Mem.states.sidebar.misc.selectedTabIndex = 3;
                    NoonUtils.callIpc("sidebar reveal Alarms");
                }
            }
        },
        "launch": {
            prefix: ".",
            icon: "rocket_launch",
            shape: MaterialShape.Shape.Pentagon,
            placeholder: "Launch App ..",
            showHint: true,
            showOsrButton: false,
            hinter: () => {
                if (cleanQuery === "") {
                    suggestedApp = null;
                    return "";
                }
                const allApps = [...DesktopEntries.applications.values];
                const q = cleanQuery.toLowerCase();
                let bestMatch = null;
                let bestScore = 0;
                for (let app of allApps) {
                    const name = (app.name || "").toLowerCase();
                    const genericName = (app.genericName || "").toLowerCase();
                    let score = 0;
                    if (name.startsWith(q))
                        score = 100 + (100 - name.length);
                    else if (name.includes(q))
                        score = 50;
                    if (genericName.startsWith(q))
                        score = Math.max(score, 90);
                    else if (genericName.includes(q))
                        score = Math.max(score, 45);
                    const acronym = name.split(/\s+/).map(w => w[0]).join("").toLowerCase();
                    if (acronym === q)
                        score = Math.max(score, 95);
                    if (score > bestScore) {
                        bestScore = score;
                        bestMatch = app;
                    }
                }
                suggestedApp = bestMatch;
                return bestMatch ? bestMatch.name : "";
            },
            executor: () => {
                if (suggestedApp) {
                    const entry = DesktopEntries.byId(suggestedApp.id);
                    if (entry)
                        entry.execute();
                }
            }
        },
        "timer": {
            prefix: "~",
            icon: "hourglass",
            shape: MaterialShape.Shape.Clover8Leaf,
            placeholder: "How Long ..",
            showHint: false,
            showOsrButton: false,
            hinter: () => "",
            executor: () => {
                const duration = TimerService.parseTimeString(cleanQuery);
                if (duration > 0)
                    TimerService.addTimer("Focus Time", duration, true, true);
                if (Mem.options.beam.behavior.revealLauncherOnAction)
                    NoonUtils.callIpc("sidebar reveal Timers");
            }
        },
        "todo": {
            prefix: "/",
            icon: "task_alt",
            shape: MaterialShape.Shape.Cookie4Sided,
            placeholder: "Any plans ..?",
            showHint: false,
            showOsrButton: false,
            hinter: () => "",
            executor: () => TodoService.addTask(cleanQuery)
        },
        "ipc": {
            prefix: "!",
            icon: "moon_stars",
            shape: MaterialShape.Shape.Pentagon,
            placeholder: "Just Order ..?",
            showHint: true,
            showOsrButton: false,
            hinter: () => {
                if (NoonUtils.avilableIpcCommands.length < 1)
                    NoonUtils.fetchIpcCommands();
                const q = cleanQuery.toLowerCase();
                for (let cmd of NoonUtils.avilableIpcCommands) {
                    if (cmd.toLowerCase().startsWith(q))
                        return cmd;
                }
                return "";
            },
            executor: () => NoonUtils.callIpc(cleanQuery)
        },
        "search": {
            prefix: "?",
            icon: "search",
            shape: MaterialShape.Shape.PixelCircle,
            placeholder: "Wanna Search Google ..?",
            showHint: true,
            showOsrButton: false,
            hinter: () => {
                if (BookmarksService.bookmarkTitles.length > 0) {
                    const q = cleanQuery.toLowerCase();
                    for (let bookmark of BookmarksService.bookmarkTitles) {
                        if (bookmark.toLowerCase().startsWith(q))
                            return bookmark;
                    }
                }
                return "";
            },
            executor: () => {
                const searchUrl = subConfig?.searchQuery || Mem.options.networking.searchPrefix;
                const searchText = subConfig ? cleanQuery.substring(subConfig.prefix.length) : cleanQuery;
                Quickshell.execDetached(["xdg-open", searchUrl + encodeURIComponent(searchText)]);
            },
            subStates: {
                "search": {
                    prefix: "",
                    icon: "search",
                    searchQuery: Mem.options.networking.searchPrefix,
                    shape: MaterialShape.Shape.PixelCircle
                },
                "yt_music": {
                    prefix: "m",
                    icon: "music_note",
                    searchQuery: "https://music.youtube.com/search?q=",
                    shape: MaterialShape.Shape.Bun
                },
                "spotify": {
                    prefix: "s",
                    icon: "music_cast",
                    searchQuery: "https://open.spotify.com/search/",
                    shape: MaterialShape.Shape.Cookie7Sided
                },
                "m3": {
                    prefix: "i",
                    icon: "glyphs",
                    searchQuery: "https://fonts.google.com/icons?icon.query=",
                    shape: MaterialShape.Shape.Cookie12Sided
                },
                "github": {
                    prefix: "g",
                    icon: "commit",
                    searchQuery: "https://github.com/search?q=",
                    shape: MaterialShape.Shape.Oval
                }
            }
        },
        "translate": {
            prefix: ">",
            icon: "translate",
            shape: MaterialShape.Shape.Arrow,
            placeholder: "Translate ..?",
            showHint: true,
            showOsrButton: false,
            hinter: () => {
                if (cleanQuery.length > 0) {
                    TranslatorService.translate(cleanQuery, result => {
                        if (activeState === "translate")
                            activeHint = result;
                    });
                }
                return activeHint;
            },
            executor: () => {
                if (TranslatorService.translatedText)
                    ClipboardService.copy(TranslatorService.translatedText);
            }
        },
        "download": {
            prefix: "-",
            icon: "download",
            shape: MaterialShape.Shape.Arrow,
            placeholder: "Download ..?",
            showHint: false,
            showOsrButton: false,
            hinter: () => "",
            executor: () => {
                const params = subConfig?.parameters || "";
                const searchQuery = subConfig ? cleanQuery.substring(subConfig.prefix.length).trim() : cleanQuery.trim();
                const processedParams = params.replace(/%q/g, searchQuery);
                const cmd = params.includes("%q") ? `yt-dlp -f ${processedParams}` : `yt-dlp -f ${processedParams} '${searchQuery}'`;
                BeatsService.downloadByCommand(cmd);
            },
            subStates: {
                "video": {
                    prefix: "v",
                    icon: "play_arrow",
                    parameters: "bestvideo[height<=720]+bestaudio/best[height<=720]",
                    shape: MaterialShape.Shape.PixelCircle
                },
                "audio": {
                    prefix: "m",
                    icon: "music_note",
                    parameters: `bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -P "${Directories.beats.downloads}" `,
                    shape: MaterialShape.Shape.PixelCircle
                },
                "audio_search": {
                    prefix: "?m",
                    icon: "music_note",
                    parameters: `bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -P "${Directories.beats.downloads}" 'ytsearch1:%q'`,
                    shape: MaterialShape.Shape.PixelCircle
                }
            }
        }
    }

    function updateStateFromQuery(fullQuery) {
        query = fullQuery;

        if (fullQuery.length === 0) {
            activeState = "ai";
            activeSubState = "";
            return;
        }

        const firstChar = fullQuery[0];

        for (let key in registry) {
            const stateConfig = registry[key];
            if (stateConfig.prefix === firstChar && firstChar !== "") {
                activeState = key;
                if (stateConfig.subStates) {
                    updateSubState(fullQuery.substring(1), stateConfig.subStates);
                } else {
                    activeSubState = "";
                }
                return;
            }
        }

        activeState = "ai";
        activeSubState = "";
    }

    function updateSubState(remainder, subStates) {
        if (!remainder) {
            activeSubState = "";
            return;
        }

        for (let subKey in subStates) {
            const subPrefix = subStates[subKey].prefix;
            if (subPrefix !== "" && remainder.startsWith(subPrefix)) {
                activeSubState = subKey;
                return;
            }
        }

        activeSubState = Object.keys(subStates)[0] || "";
    }

    function reset() {
        query = "";
        activeState = "ai";
        activeSubState = "";
        suggestedApp = null;
    }

    function getIcon() {
        if (subConfig)
            return subConfig.icon;
        return config?.icon || "question_mark";
    }

    function getShape() {
        if (subConfig)
            return subConfig.shape;
        return config?.shape || MaterialShape.Shape.Oval;
    }

    function getHint() {
        if (!config.showHint) {
            activeHint = "";
            return "";
        }
        debounceTimer.restart();
        return activeHint;
    }

    Timer {
        id: debounceTimer
        interval: 120
        onTriggered: activeHint = config?.hinter ? config.hinter() : ""
    }

    function executeCommand() {
        if (cleanQuery.length === 0 && activeState !== "ai")
            return;
        if (config?.executor)
            config.executor();
    }

    function autocomplete(hintText) {
        if (!hintText)
            return query;

        const prefix = config?.prefix || "";

        const resultStates = ["calc", "translate"];
        if (resultStates.includes(activeState))
            return query;

        return prefix + hintText;
    }
}
