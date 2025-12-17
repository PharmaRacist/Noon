// SolarizedDark.qml
import QtQuick

QtObject {
    readonly property string name: "Solarized Dark"
    readonly property string description: "Precision colors for machines and people"
    readonly property bool isDark: true
    readonly property string author: "Ethan Schoonover"
    readonly property url website: "https://ethanschoonover.com/solarized"

    readonly property var colors: ({
            "primary": "#268bd2",
            "on_primary": "#002b36",
            "primary_container": "#073642",
            "on_primary_container": "#fdf6e3",
            "primary_fixed": "#268bd2",
            "primary_fixed_dim": "#1e6aa0",

            "secondary": "#d33682",
            "on_secondary": "#002b36",
            "secondary_container": "#073642",
            "on_secondary_container": "#fdf6e3",
            "secondary_fixed": "#d33682",
            "secondary_fixed_dim": "#a92a69",

            "tertiary": "#2aa198",
            "on_tertiary": "#002b36",
            "tertiary_container": "#073642",
            "on_tertiary_container": "#fdf6e3",
            "tertiary_fixed": "#2aa198",
            "tertiary_fixed_dim": "#1f7a74",

            "error": "#dc322f",
            "on_error": "#002b36",
            "error_container": "#073642",
            "on_error_container": "#fdf6e3",

            "background": "#002b36",
            "on_background": "#839496",
            "surface": "#073642",
            "on_surface": "#839496",

            "surface_dim": "#001f29",
            "surface_bright": "#0a3a4c",

            "surface_container_lowest": "#001a25",
            "surface_container_low": "#022230",
            "surface_container": "#073642",
            "surface_container_high": "#0e4a5c",
            "surface_container_highest": "#16506c",

            "surface_variant": "#586e75",
            "on_surface_variant": "#93a1a1",

            "surface_tint": "#268bd2",

            "outline": "#657b83",
            "outline_variant": "#586e75",

            "shadow": "#000000",
            "scrim": "#000000",

            "inverse_surface": "#fdf6e3",
            "inverse_on_surface": "#002b36",
            "inverse_primary": "#b58900"
        })
}
