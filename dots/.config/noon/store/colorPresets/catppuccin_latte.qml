// Catppuccin Latte.qml
import QtQuick

QtObject {
    readonly property string name: "Catppuccin Latte"
    readonly property string description: "Soft pastel theme, light variant"
    readonly property bool isDark: false
    readonly property string author: "Catppuccin"
    readonly property url website: "https://catppuccin.com"

    readonly property var colors: ({
        "primary": "#d699ff",
        "on_primary": "#1c1c24",
        "primary_container": "#e5d9f0",
        "on_primary_container": "#1c1c24",
        "primary_fixed": "#d699ff",
        "primary_fixed_dim": "#b47fd6",

        "secondary": "#8aadf4",
        "on_secondary": "#1c1c24",
        "secondary_container": "#dce0f0",
        "on_secondary_container": "#1c1c24",
        "secondary_fixed": "#8aadf4",
        "secondary_fixed_dim": "#6b8ed0",

        "tertiary": "#95e6cb",
        "on_tertiary": "#1c1c24",
        "tertiary_container": "#daf0e6",
        "on_tertiary_container": "#1c1c24",
        "tertiary_fixed": "#95e6cb",
        "tertiary_fixed_dim": "#6ecdb4",

        "error": "#f38ba8",
        "on_error": "#1c1c24",
        "error_container": "#f9d7dd",
        "on_error_container": "#1c1c24",

        "background": "#faf8f5",
        "on_background": "#4c4f69",
        "surface": "#f5f4f1",
        "on_surface": "#4c4f69",

        "surface_dim": "#f0efec",
        "surface_bright": "#fcfbf8",

        "surface_container_lowest": "#f9f8f5",
        "surface_container_low": "#f5f4f1",
        "surface_container": "#eeeeea",
        "surface_container_high": "#e5e2de",
        "surface_container_highest": "#dad7d2",

        "surface_variant": "#dce0f0",
        "on_surface_variant": "#4c4f69",
        "surface_tint": "#d699ff",

        "outline": "#cdd6f4",
        "outline_variant": "#dce0f0",

        "shadow": "#000000",
        "scrim": "#000000",

        "inverse_surface": "#1c1c24",
        "inverse_on_surface": "#f5f4f1",
        "inverse_primary": "#b47fd6"
    })
}
