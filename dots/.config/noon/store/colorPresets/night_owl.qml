// Night Owl.qml
import QtQuick

QtObject {
    readonly property string name: "Night Owl"
    readonly property string description: "Dark theme with a focus on readability and colors for night coding"
    readonly property bool isDark: true
    readonly property string author: "Sarah Drasner"
    readonly property url website: "https://github.com/sdras/night-owl-vscode-theme"

    readonly property var colors: ({
        "primary": "#7fdbca",
        "on_primary": "#011627",
        "primary_container": "#0c1824",
        "on_primary_container": "#a1e3d8",
        "primary_fixed": "#7fdbca",
        "primary_fixed_dim": "#5fb0a0",

        "secondary": "#ffcb6b",
        "on_secondary": "#011627",
        "secondary_container": "#0c1824",
        "on_secondary_container": "#ffeaa3",
        "secondary_fixed": "#ffcb6b",
        "secondary_fixed_dim": "#d9a750",

        "tertiary": "#82aaff",
        "on_tertiary": "#011627",
        "tertiary_container": "#0c1824",
        "on_tertiary_container": "#b2d4ff",
        "tertiary_fixed": "#82aaff",
        "tertiary_fixed_dim": "#6090d7",

        "error": "#ff5370",
        "on_error": "#011627",
        "error_container": "#0c1824",
        "on_error_container": "#ff8e9a",

        "background": "#011627",
        "on_background": "#d6deeb",
        "surface": "#0c1824",
        "on_surface": "#d6deeb",

        "surface_dim": "#081021",
        "surface_bright": "#1a2433",

        "surface_container_lowest": "#060f1b",
        "surface_container_low": "#0a1621",
        "surface_container": "#0c1824",
        "surface_container_high": "#1a2433",
        "surface_container_highest": "#24304d",

        "surface_variant": "#1a2433",
        "on_surface_variant": "#9db5cc",
        "surface_tint": "#7fdbca",

        "outline": "#5c6773",
        "outline_variant": "#1a2433",

        "shadow": "#000000",
        "scrim": "#000000",

        "inverse_surface": "#d6deeb",
        "inverse_on_surface": "#011627",
        "inverse_primary": "#5fb0a0"
    })
}
