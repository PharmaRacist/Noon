// Palen Night.qml
import QtQuick

QtObject {
    readonly property string name: "Palen Night"
    readonly property string description: "A soft dark theme with subdued tones"
    readonly property bool isDark: true
    readonly property string author: "Palen Night Team"
    readonly property url website: "https://github.com/palen-night/palen-night-theme"

    readonly property var colors: ({
            "primary": "#7fdbca",
            "on_primary": "#1e1e2e",
            "primary_container": "#2c2c3c",
            "on_primary_container": "#d0f5eb",
            "primary_fixed": "#7fdbca",
            "primary_fixed_dim": "#5fb0a0",
            "secondary": "#ffcb6b",
            "on_secondary": "#1e1e2e",
            "secondary_container": "#2c2c3c",
            "on_secondary_container": "#ffeaa3",
            "secondary_fixed": "#ffcb6b",
            "secondary_fixed_dim": "#d9a750",
            "tertiary": "#82aaff",
            "on_tertiary": "#1e1e2e",
            "tertiary_container": "#2c2c3c",
            "on_tertiary_container": "#b2d4ff",
            "tertiary_fixed": "#82aaff",
            "tertiary_fixed_dim": "#6090d7",
            "error": "#ff5370",
            "on_error": "#1e1e2e",
            "error_container": "#2c2c3c",
            "on_error_container": "#ff8e9a",
            "background": "#1e1e2e",
            "on_background": "#c0caf5",
            "surface": "#2c2c3c",
            "on_surface": "#c0caf5",
            "surface_dim": "#1a1a2a",
            "surface_bright": "#353546",
            "surface_container_lowest": "#181826",
            "surface_container_low": "#252535",
            "surface_container": "#2c2c3c",
            "surface_container_high": "#3a3a4a",
            "surface_container_highest": "#484858",
            "surface_variant": "#3a3a4a",
            "on_surface_variant": "#a9b1d6",
            "surface_tint": "#7fdbca",
            "outline": "#565f89",
            "outline_variant": "#3a3a4a",
            "shadow": "#000000",
            "scrim": "#000000",
            "inverse_surface": "#c0caf5",
            "inverse_on_surface": "#1e1e2e",
            "inverse_primary": "#5fb0a0"
        })
}
