import qs.common.utils

JsonAdapter {
    property JsonObject misc: JsonObject {
        property list<string> ipcCommands: []
        property list<string> systemCommands: []
    }

    property JsonObject secrets: JsonObject {
        property string wallhaven: ""
        property string unsplash: ""
    }

    property JsonObject services: JsonObject {
        property JsonObject ambientSounds
        property JsonObject icons
        property JsonObject emojis
        property JsonObject backlight
        property JsonObject cheats
        property JsonObject colors

        colors: JsonObject {
            property list<var> palettes: []
        }

        cheats: JsonObject {
            property list<string> superKeys: ["󰖳", "󰌽", "󰘳", "", "󰨡", "", "", "󰣇", "", "", "", "", "", "", "󱄛"]
            property list<var> defaultKeybinds: []
            property list<var> shellKeybinds: []
        }
        backlight: JsonObject {
            property list<var> devices: []
        }

        icons: JsonObject {
            property list<var> availableIconThemes: []
        }
        ambientSounds: JsonObject {
            property list<var> availableSounds: []
        }
    }
}
