pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Qt.labs.folderlistmodel
import qs.common

Singleton {
    id: root

    // Color Palettes
    readonly property alias palettes: palettesModel

    FolderListModel {
        id: palettesModel
        folder: Qt.resolvedUrl(Directories.assets) + "/db/palettes"
        // nameFilters: ["*.json"]
        showDirs: false
        showFiles: true
        Component.onCompleted: console.log(palettesModel.count, "in ", folder)
    }

    // Gowall
    readonly property var themes: [
        {
            "name": "Arc Dark",
            "value": "arcdark",
            "icon": "gradient"
        },
        {
            "name": "Monochromatic",
            "value": "monochromatic",
            "icon": "contrast"
        },
        {
            "name": "Catppuccin",
            "value": "catppuccin",
            "icon": "palette"
        },
        {
            "name": "Cyberpunk",
            "value": "cyberpunk",
            "icon": "computer"
        },
        {
            "name": "Dracula",
            "value": "dracula",
            "icon": "dark_mode"
        },
        {
            "name": "Everforest",
            "value": "everforest",
            "icon": "eco"
        },
        {
            "name": "GitHub Light",
            "value": "github-light",
            "icon": "dark_mode"
        },
        {
            "name": "Gruvbox",
            "value": "gruvbox",
            "icon": "texture"
        },
        {
            "name": "Kanagawa",
            "value": "kanagawa",
            "icon": "waves"
        },
        {
            "name": "Material",
            "value": "material",
            "icon": "design_services"
        },
        {
            "name": "Monokai",
            "value": "monokai",
            "icon": "contrast"
        },
        {
            "name": "Night Owl",
            "value": "night-owl",
            "icon": "nights_stay"
        },
        {
            "name": "Nord",
            "value": "nord",
            "icon": "ac_unit"
        },
        {
            "name": "Oceanic Next",
            "value": "oceanic-next",
            "icon": "water"
        },
        {
            "name": "One Dark",
            "value": "onedark",
            "icon": "circle"
        },
        {
            "name": "Rose Pine",
            "value": "rose-pine",
            "icon": "spa"
        },
        {
            "name": "Shades of Purple",
            "value": "shades-of-purple",
            "icon": "color_lens"
        },
        {
            "name": "Solarized",
            "value": "solarized",
            "icon": "wb_sunny"
        },
        {
            "name": "Srcery",
            "value": "srcery",
            "icon": "brush"
        },
        {
            "name": "Synthwave '84",
            "value": "synthwave-84",
            "icon": "graphic_eq"
        },
        {
            "name": "Tokyo Storm",
            "value": "tokyo-storm",
            "icon": "thunderstorm"
        }
    ]

    // M3 Modes
    readonly property var modes: [
        {
            "name": "Tonal Spot",
            "value": "scheme-tonal-spot",
            "icon": "palette"
        },
        {
            "name": "Neutral",
            "value": "scheme-neutral",
            "icon": "contrast"
        },
        {
            "name": "Expressive",
            "value": "scheme-expressive",
            "icon": "colorize"
        },
        {
            "name": "Fidelity",
            "value": "scheme-fidelity",
            "icon": "image"
        },
        {
            "name": "Content",
            "value": "scheme-content",
            "icon": "image"
        },
        {
            "name": "Monochrome",
            "value": "scheme-monochrome",
            "icon": "monochrome_photos"
        },
        {
            "name": "Rainbow",
            "value": "scheme-rainbow",
            "icon": "gradient"
        },
        {
            "name": "Fruit Salad",
            "value": "scheme-fruit-salad",
            "icon": "nature"
        },
        {
            "name": "Vibrant",
            "value": "scheme-vibrant",
            "icon": "palette"
        }
    ]
}
