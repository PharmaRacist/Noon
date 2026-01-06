import qs.common.utils

JsonAdapter {
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
            property string currentFolder: "/Pictures/Wallpapers"
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
        mediaPlayer: JsonObject {
            // property string selectedPlayerDbusName: ""
            property int selectedPlayerIndex: 0
        }
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
        property list<var> pinnedApps: ["firefox", "dolphin"]
    }
    property JsonObject sidebar: JsonObject {
        property JsonObject behavior
        property JsonObject misc
        property JsonObject apis
        property list<var> widgets: [
            {
                "id": "resources",
                "pill": false,
                "enabled": true,
                "expandable": true,
                "pinned": false,
                "component": "Resources"
            },
            {
                "id": "battery",
                "pill": true,
                "enabled": true,
                "expandable": false,
                "pinned": false,
                "component": "Battery"
            },
            {
                "id": "simple_clock",
                "pill": true,
                "enabled": true,
                "expandable": false,
                "pinned": false,
                "component": "Clock_Simple"
            },
            {
                "id": "bluetooth",
                "pill": true,
                "enabled": true,
                "expandable": false,
                "pinned": false,
                "component": "Bluetooth"
            },
            {
                "id": "media",
                "pill": false,
                "enabled": true,
                "expandable": true,
                "pinned": false,
                "component": "Media"
            },
            {
                "id": "combo",
                "enabled": true,
                "expandable": true,
                "pinned": false,
                "pill": false,
                "component": "ClockWeatherCombo"
            },
            {
                "id": "net",
                "pill": true,
                "enabled": true,
                "expandable": false,
                "pinned": false,
                "component": "NetworkSpeed"
            },
            {
                "id": "cal",
                "pill": false,
                "enabled": true,
                "expandable": true,
                "pinned": false,
                "component": "Calendar"
            },
            {
                "id": "pill",
                "enabled": true,
                "expandable": false,
                "pinned": false,
                "pill": true,
                "component": "Weather_Simple"
            }
        ]
        behavior: JsonObject {
            property bool expanded: false
            property bool pinned: false
        }
        misc: JsonObject {
            property int selectedTabIndex: 0
        }
        apis: JsonObject {
            property int selectedTab: 0
            property real fontScale: 1
        }
    }

    property JsonObject mediaPlayer: JsonObject {
        property string currentTrackPath: ""
    }
}
