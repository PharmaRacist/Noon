import QtQuick

QtObject {
    readonly property string name: "SynthWave '84"
    readonly property string description: "A retro synthwave theme inspired by the 1980s"
    readonly property bool isDark: true
    readonly property string author: "Robb Owen"
    readonly property url website: "https://github.com/robb0wen/synthwave-vscode"

    readonly property var colors: ({
            // Base colors
            "primary": "#ff7edb"           // Hot Pink
            ,
            "on_primary": "#241b2f"        // Background
            ,
            "primary_container": "#495495" // Purple Container
            ,
            "on_primary_container": "#f8f8f2" // Light Text

            ,
            "secondary": "#72f1b8"         // Neon Green
            ,
            "on_secondary": "#241b2f"      // Background
            ,
            "secondary_container": "#36f9f6" // Cyan Container
            ,
            "on_secondary_container": "#241b2f" // Dark Text

            ,
            "tertiary": "#fede5d"          // Neon Yellow
            ,
            "on_tertiary": "#241b2f"       // Background
            ,
            "tertiary_container": "#ff8b39" // Orange Container
            ,
            "on_tertiary_container": "#241b2f" // Dark Text

            ,
            "error": "#ff6c6b"             // Neon Red
            ,
            "on_error": "#241b2f"          // Background
            ,
            "error_container": "#8a1538"   // Dark Red Container
            ,
            "on_error_container": "#f8f8f2" // Light Text

            ,

            // Background and surface
            "background": "#241b2f"        // Dark Purple Background
            ,
            "on_background": "#f8f8f2"     // Light Text
            ,
            "surface": "#2a2139"           // Slightly Lighter Purple
            ,
            "on_surface": "#f8f8f2"        // Light Text
            ,
            "surface_variant": "#34294f"   // Purple Variant
            ,
            "on_surface_variant": "#b4b4b4" // Gray Text

            ,

            // Outline and shadow
            "outline": "#6a4c93"           // Purple Outline
            ,
            "outline_variant": "#34294f"   // Purple Variant
            ,
            "shadow": "#000000"            // Black Shadow
            ,
            "scrim": "#000000"             // Black Scrim

            ,

            // Inverse colors
            "inverse_surface": "#f8f8f2"   // Light Surface
            ,
            "inverse_on_surface": "#241b2f" // Dark Text
            ,
            "inverse_primary": "#8a2be2"   // Blue Violet

            ,

            // Additional SynthWave colors
            "sw_neon_pink": "#ff7edb",
            "sw_neon_green": "#72f1b8",
            "sw_neon_blue": "#36f9f6",
            "sw_neon_yellow": "#fede5d",
            "sw_neon_orange": "#ff8b39",
            "sw_neon_red": "#ff6c6b",
            "sw_neon_purple": "#9d4edd",
            "sw_dark_purple": "#241b2f",
            "sw_medium_purple": "#2a2139",
            "sw_light_purple": "#34294f",
            "sw_glow_pink": "#ff2a6d",
            "sw_glow_blue": "#01b9ff",
            "sw_glow_green": "#39ff14",
            "sw_glow_yellow": "#ffff00",
            "sw_grid_blue": "#36f9f6",
            "sw_sunset_orange": "#ff8c42",
            "sw_sunset_pink": "#ff006e",
            "sw_retro_blue": "#277da1",
            "sw_retro_teal": "#4d908e",
            "sw_chrome": "#c0c0c0",
            "sw_laser_red": "#ff073a"
        })
}
