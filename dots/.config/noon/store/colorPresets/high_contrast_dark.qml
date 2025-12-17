// HighContrastDark.qml
import QtQuick

QtObject {
    readonly property string name: "High Contrast Dark"
    readonly property string description: "High contrast dark theme for accessibility"
    readonly property bool isDark: true
    readonly property string author: "Microsoft"
    readonly property url website: "https://code.visualstudio.com"
    readonly property var colors: ({
            "primary": "#00ff00",
            "on_primary": "#000000",
            "primary_container": "#1a1a1a",
            "on_primary_container": "#ffffff",
            "secondary": "#00ffff",
            "on_secondary": "#000000",
            "secondary_container": "#1a1a1a",
            "on_secondary_container": "#ffffff",
            "tertiary": "#ffff00",
            "on_tertiary": "#000000",
            "tertiary_container": "#1a1a1a",
            "on_tertiary_container": "#ffffff",
            "error": "#ff0000",
            "on_error": "#000000",
            "error_container": "#1a1a1a",
            "on_error_container": "#ffffff",
            "background": "#000000",
            "on_background": "#ffffff",
            "surface": "#1a1a1a",
            "on_surface": "#ffffff",
            "surface_variant": "#333333",
            "on_surface_variant": "#ffffff",
            "outline": "#ffffff",
            "outline_variant": "#666666",
            "shadow": "#000000",
            "scrim": "#000000",
            "inverse_surface": "#ffffff",
            "inverse_on_surface": "#000000",
            "inverse_primary": "#008000"
        })
}
