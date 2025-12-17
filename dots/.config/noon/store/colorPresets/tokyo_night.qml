// Tokyo Night.qml
import QtQuick

QtObject {
    readonly property string name: "Tokyo Night"
    readonly property string description: "A dark, blue-focused theme inspired by Tokyo at night"
    readonly property bool isDark: true
    readonly property string author: "enkia"
    readonly property url website: "https://github.com/enkia/tokyo-night-vscode-theme"

    readonly property var colors: ({
        "primary": "#7aa2f7",
        "on_primary": "#1a1b26",
        "primary_container": "#1f2335",
        "on_primary_container": "#c0caf5",
        "primary_fixed": "#7aa2f7",
        "primary_fixed_dim": "#6080c0",

        "secondary": "#9ece6a",
        "on_secondary": "#1a1b26",
        "secondary_container": "#1f2335",
        "on_secondary_container": "#d3f988",
        "secondary_fixed": "#9ece6a",
        "secondary_fixed_dim": "#78aa4f",

        "tertiary": "#f7768e",
        "on_tertiary": "#1a1b26",
        "tertiary_container": "#1f2335",
        "on_tertiary_container": "#f2c7d9",
        "tertiary_fixed": "#f7768e",
        "tertiary_fixed_dim": "#c1596f",

        "error": "#e06c75",
        "on_error": "#1a1b26",
        "error_container": "#1f2335",
        "on_error_container": "#f2c7d9",

        "background": "#1a1b26",
        "on_background": "#c0caf5",
        "surface": "#1f2335",
        "on_surface": "#c0caf5",

        "surface_dim": "#16171f",
        "surface_bright": "#292c3c",

        "surface_container_lowest": "#151622",
        "surface_container_low": "#1b1c2e",
        "surface_container": "#1f2335",
        "surface_container_high": "#2c2f42",
        "surface_container_highest": "#373a4d",

        "surface_variant": "#2a2e3f",
        "on_surface_variant": "#a9b1d6",
        "surface_tint": "#7aa2f7",

        "outline": "#565f89",
        "outline_variant": "#2a2e3f",

        "shadow": "#000000",
        "scrim": "#000000",

        "inverse_surface": "#c0caf5",
        "inverse_on_surface": "#1a1b26",
        "inverse_primary": "#5c88d9"
    })
}
