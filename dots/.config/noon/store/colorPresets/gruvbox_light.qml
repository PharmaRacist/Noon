// Gruvbox Light.qml
import QtQuick

QtObject {
    readonly property string name: "Gruvbox Light"
    readonly property string description: "Warm light theme inspired by Gruvbox palette"
    readonly property bool isDark: false
    readonly property string author: "Pablocosta"
    readonly property url website: "https://github.com/morhetz/gruvbox"

    readonly property var colors: ({
        "primary": "#b57614",
        "on_primary": "#fbf1c7",
        "primary_container": "#fefae0",
        "on_primary_container": "#7c6f64",
        "primary_fixed": "#b57614",
        "primary_fixed_dim": "#92610f",

        "secondary": "#076678",
        "on_secondary": "#fdf6e3",
        "secondary_container": "#f0e9d2",
        "on_secondary_container": "#1c1c1c",
        "secondary_fixed": "#076678",
        "secondary_fixed_dim": "#054d57",

        "tertiary": "#8f3f71",
        "on_tertiary": "#fdf6e3",
        "tertiary_container": "#f3e7ee",
        "on_tertiary_container": "#3c3836",
        "tertiary_fixed": "#8f3f71",
        "tertiary_fixed_dim": "#6b2f58",

        "error": "#cc241d",
        "on_error": "#fdf6e3",
        "error_container": "#fdecea",
        "on_error_container": "#3c3836",

        "background": "#fbf1c7",
        "on_background": "#3c3836",
        "surface": "#fefae0",
        "on_surface": "#3c3836",

        "surface_dim": "#f7f2cf",
        "surface_bright": "#fffaf0",

        "surface_container_lowest": "#fcf8e2",
        "surface_container_low": "#fefae0",
        "surface_container": "#fdf6e3",
        "surface_container_high": "#f6f1d7",
        "surface_container_highest": "#efe9c9",

        "surface_variant": "#f0e9d2",
        "on_surface_variant": "#3c3836",
        "surface_tint": "#b57614",

        "outline": "#7c6f64",
        "outline_variant": "#f0e9d2",

        "shadow": "#000000",
        "scrim": "#000000",

        "inverse_surface": "#3c3836",
        "inverse_on_surface": "#fdf6e3",
        "inverse_primary": "#b57614"
    })
}
