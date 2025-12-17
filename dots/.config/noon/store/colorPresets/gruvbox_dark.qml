// GitHub Dark.qml
import QtQuick

QtObject {
    readonly property string name: "GitHub Dark"
    readonly property string description: "GitHub dark theme for editors and shells"
    readonly property bool isDark: true
    readonly property string author: "GitHub"
    readonly property url website: "https://github.com/primer/github-vscode-theme"

    readonly property var colors: ({
        "primary": "#539bf5",
        "on_primary": "#0d1117",
        "primary_container": "#161b22",
        "on_primary_container": "#c9d1d9",
        "primary_fixed": "#539bf5",
        "primary_fixed_dim": "#3f7fd6",

        "secondary": "#79c0ff",
        "on_secondary": "#0d1117",
        "secondary_container": "#161b22",
        "on_secondary_container": "#c9d1d9",
        "secondary_fixed": "#79c0ff",
        "secondary_fixed_dim": "#539dcf",

        "tertiary": "#bc8cff",
        "on_tertiary": "#0d1117",
        "tertiary_container": "#161b22",
        "on_tertiary_container": "#e0dfff",
        "tertiary_fixed": "#bc8cff",
        "tertiary_fixed_dim": "#9c6fcc",

        "error": "#f85149",
        "on_error": "#0d1117",
        "error_container": "#161b22",
        "on_error_container": "#ffdce0",

        "background": "#0d1117",
        "on_background": "#c9d1d9",
        "surface": "#161b22",
        "on_surface": "#c9d1d9",

        "surface_dim": "#0b0f14",
        "surface_bright": "#1a1f27",

        "surface_container_lowest": "#080c11",
        "surface_container_low": "#12171f",
        "surface_container": "#161b22",
        "surface_container_high": "#1f252d",
        "surface_container_highest": "#292f38",

        "surface_variant": "#1f252d",
        "on_surface_variant": "#b0b9c6",
        "surface_tint": "#539bf5",

        "outline": "#30363d",
        "outline_variant": "#1f252d",

        "shadow": "#000000",
        "scrim": "#000000",

        "inverse_surface": "#c9d1d9",
        "inverse_on_surface": "#0d1117",
        "inverse_primary": "#3f7fd6"
    })
}
