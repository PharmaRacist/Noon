// Material Light.qml
import QtQuick

QtObject {
    readonly property string name: "Material Light"
    readonly property string description: "Light variant of Material Design 3 colors"
    readonly property bool isDark: false
    readonly property string author: "Google Material"
    readonly property url website: "https://material.io/design/color"

    readonly property var colors: ({
            "primary": "#6750a4",
            "on_primary": "#ffffff",
            "primary_container": "#eaddff",
            "on_primary_container": "#21005d",
            "primary_fixed": "#6750a4",
            "primary_fixed_dim": "#4f3f8a",
            "secondary": "#625b71",
            "on_secondary": "#ffffff",
            "secondary_container": "#e8def8",
            "on_secondary_container": "#1d192b",
            "secondary_fixed": "#625b71",
            "secondary_fixed_dim": "#4b435c",
            "tertiary": "#7d5260",
            "on_tertiary": "#ffffff",
            "tertiary_container": "#ffd8e4",
            "on_tertiary_container": "#370b1e",
            "tertiary_fixed": "#7d5260",
            "tertiary_fixed_dim": "#5e3d4b",
            "error": "#b3261e",
            "on_error": "#ffffff",
            "error_container": "#f9dedc",
            "on_error_container": "#410e0b",
            "background": "#fffbfe",
            "on_background": "#1c1b1f",
            "surface": "#fffbfe",
            "on_surface": "#1c1b1f",
            "surface_dim": "#f5f2f7",
            "surface_bright": "#ffffff",
            "surface_container_lowest": "#fcfaff",
            "surface_container_low": "#f6f1fa",
            "surface_container": "#f4eff6",
            "surface_container_high": "#ece6f0",
            "surface_container_highest": "#e5def1",
            "surface_variant": "#e7e0ec",
            "on_surface_variant": "#49454f",
            "surface_tint": "#6750a4",
            "outline": "#79747e",
            "outline_variant": "#e7e0ec",
            "shadow": "#000000",
            "scrim": "#000000",
            "inverse_surface": "#1c1b1f",
            "inverse_on_surface": "#e6e1e5",
            "inverse_primary": "#d0bcff"
        })
}
