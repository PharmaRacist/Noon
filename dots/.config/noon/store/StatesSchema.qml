import qs.common.utils

JsonAdapter {
    property JsonObject applications: JsonObject {
        property JsonObject settings: JsonObject {
            property string cat: ""
            property bool sidebar_expanded: false
            property bool sidebar_pinned: false
            property int appearance_mode: 0
        }
        property JsonObject reader: JsonObject {
            property string currentFile: ""
            property bool sidebar_expanded: false
            property bool sidebar_pinned: false
            property int appearance_mode: 0
        }
    }
    property JsonObject desktop: JsonObject {
        property JsonObject icons
        property JsonObject bg
        property JsonObject appearance
        property JsonObject clock

        icons: JsonObject {
            property string currentIconTheme: ""
        }
        bg: JsonObject {
            property bool isBright: false
            property bool isLive: false
            property string currentVideo: ""
            property string currentBg: ""
            property string currentFolder: "~/Pictures/Wallpapers"
        }
        appearance: JsonObject {
            property JsonObject colors

            property bool autoSchemeSelection: false
            property bool autoShellMode: false
            property string mode: "dark"
            property string scheme: ""

            colors: JsonObject {
                property real chroma: 1
                property real tone: 1
            }
        }
        clock: JsonObject {
            property bool center
            property real scale: 1
        }
    }

    property JsonObject services: JsonObject {
        property JsonObject kdeconnect
        property JsonObject bookmarks
        property JsonObject ai
        property JsonObject emojis
        property JsonObject nightLight
        property JsonObject ambientSounds
        property JsonObject mediaPlayer
        property JsonObject power

        ai: JsonObject {
            property JsonObject tokenCount: JsonObject {
                property int input
                property int output
                property int total
            }
        }
        power: JsonObject {
            property string controller: ""
            property string mode: ""
            property list<var> modes
        }
        kdeconnect: JsonObject {
            property list<var> devices: []
            property list<var> availableDevices: []
            property string selectedDeviceId: ""
            property string myDeviceId: ""
        }
        nightLight: JsonObject {
            property bool enabled: false
            property int temperature: 3600
        }
        bookmarks: JsonObject {
            property list<var> firefoxBookmarks: []
        }

        emojis: JsonObject {
            property list<var> frequentEmojies: []
        }
        ambientSounds: JsonObject {
            property real masterVolume: 1
            property bool masterPaused: false
            property bool muted: false
            property list<var> activeSounds: []
        }
        mediaPlayer: JsonObject {}
    }

    property JsonObject fonts: JsonObject {
        property JsonObject variableAxes

        variableAxes: JsonObject {
            property JsonObject display

            display: JsonObject {
                property int wght: 100
                property int wdth: 100
                property int ital: 100
                property int slnt: 100
                property int opsz: 100
            }
        }
    }

    property JsonObject beam: JsonObject {
        property JsonObject appearance

        appearance: JsonObject {
            property int mode: 0
        }
    }

    property JsonObject dock: JsonObject {
        property bool pinned: false
    }
    property JsonObject sidebar: JsonObject {
        property JsonObject misc
        property JsonObject apis
        property JsonObject web
        property JsonObject widgets
        property JsonObject shelf
        web: JsonObject {
            property string currentUrl: ""
        }
        shelf: JsonObject {
            property list<string> filePaths: []
        }
        widgets: JsonObject {
            property list<string> enabled: []
            property list<string> overlayed: []
            property list<string> pilled: []
            property list<string> pinned: []
            property list<string> expanded: []
        }
        misc: JsonObject {
            property int selectedTabIndex: 0
        }
        apis: JsonObject {
            property int selectedTab: 0
            property real fontScale: 1
        }
    }
    property JsonObject favorites: JsonObject {
        property list<var> apps: ["firefox", "dolphin"]
        property list<var> recentApps: ["vesktop", "kitty", "spotify", "heroic", "foot", "firefox"]
        property list<var> fastLaunchApps: ["heroic", "codium", "steam"]
    }
    property JsonObject mediaPlayer: JsonObject {
        property string currentTrackPath: ""
    }
}
