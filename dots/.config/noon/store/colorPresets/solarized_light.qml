// SolarizedLight.qml
import QtQuick

QtObject {
    readonly property string name: "Solarized Light"
    readonly property string description: "Precision colors for machines and people"
    readonly property bool isDark: false
    readonly property string author: "Ethan Schoonover"
    readonly property url website: "https://ethanschoonover.com/solarized"
    readonly property var colors: ({
            "primary": "#268bd2",
            "on_primary": "#fdf6e3",
            "primary_container": "#eee8d5",
            "on_primary_container": "#073642",
            "secondary": "#d33682",
            "on_secondary": "#fdf6e3",
            "secondary_container": "#eee8d5",
            "on_secondary_container": "#073642",
            "tertiary": "#2aa198",
            "on_tertiary": "#fdf6e3",
            "tertiary_container": "#eee8d5",
            "on_tertiary_container": "#073642",
            "error": "#dc322f",
            "on_error": "#fdf6e3",
            "error_container": "#eee8d5",
            "on_error_container": "#073642",
            "background": "#fdf6e3",
            "on_background": "#657b83",
            "surface": "#eee8d5",
            "on_surface": "#657b83",
            "surface_variant": "#93a1a1",
            "on_surface_variant": "#586e75",
            "outline": "#839496",
            "outline_variant": "#93a1a1",
            "shadow": "#000000",
            "scrim": "#000000",
            "inverse_surface": "#073642",
            "inverse_on_surface": "#fdf6e3",
            "inverse_primary": "#b58900"
        })
}
