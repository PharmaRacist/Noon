// windows11_dark.qml
import QtQuick

QtObject {
    readonly property string name: "Windows 11 Dark (approx)"
    readonly property string description: "Approximate Windows 11 default dark + accent palette"
    readonly property bool isDark: true
    readonly property string author: "Approximation"
    readonly property url website: "https://www.microsoft.com"

    readonly property var colors: ({
            "primary": "#0078d4",
            "on_primary": "#ffffff",
            "primary_container": "#005a9e",
            "on_primary_container": "#d0e7ff",
            "primary_fixed": "#0078d4",
            "primary_fixed_dim": "#005ea0",
            "secondary": "#2d7d9a",
            "on_secondary": "#ffffff",
            "secondary_container": "#145a6f",
            "on_secondary_container": "#cdefff",
            "secondary_fixed": "#2d7d9a",
            "secondary_fixed_dim": "#1f5a70",
            "tertiary": "#00b294",
            "on_tertiary": "#ffffff",
            "tertiary_container": "#007862",
            "on_tertiary_container": "#b3fff1",
            "tertiary_fixed": "#00b294",
            "tertiary_fixed_dim": "#008d7a",
            "error": "#d13438",
            "on_error": "#ffffff",
            "error_container": "#a4262c",
            "on_error_container": "#ffc9c9",
            "background": "#202126",
            "on_background": "#d4d4d4",
            "surface": "#252526",
            "on_surface": "#e0e0e0",
            "surface_dim": "#1a1a1f",
            "surface_bright": "#2d2d30",
            "surface_container_lowest": "#18181d",
            "surface_container_low": "#212125",
            "surface_container": "#252526",
            "surface_container_high": "#2e2e2f",
            "surface_container_highest": "#383839",
            "surface_variant": "#2b2b2f",
            "on_surface_variant": "#cfcfcf",
            "surface_tint": "#0078d4",
            "outline": "#444c56",
            "outline_variant": "#2b2b2f",
            "shadow": "#000000",
            "scrim": "#000000",
            "inverse_surface": "#e0e0e0",
            "inverse_on_surface": "#202126",
            "inverse_primary": "#005a9e"
        })
}
