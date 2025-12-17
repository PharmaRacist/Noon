// Ayu Dark (Full M3 Version)
import QtQuick

QtObject {
    readonly property string name: "Ayu Dark"
    readonly property string description: "A simple theme with bright colors"
    readonly property bool isDark: true
    readonly property string author: "Ayu Theme"
    readonly property url website: "https://github.com/ayu-theme"

    readonly property var colors: ({
        // Primary
        "primary":                "#39bae6",
        "on_primary":             "#0f1419",
        "primary_container":      "#1f2430",
        "on_primary_container":   "#bfbab0",
        "primary_fixed":          "#39bae6",
        "primary_fixed_dim":      "#1e6f89",

        // Secondary
        "secondary":              "#ffb454",
        "on_secondary":           "#0f1419",
        "secondary_container":    "#1f2430",
        "on_secondary_container": "#bfbab0",
        "secondary_fixed":        "#ffb454",
        "secondary_fixed_dim":    "#d28a33",

        // Tertiary
        "tertiary":               "#95e6cb",
        "on_tertiary":            "#0f1419",
        "tertiary_container":     "#1f2430",
        "on_tertiary_container":  "#bfbab0",
        "tertiary_fixed":         "#95e6cb",
        "tertiary_fixed_dim":     "#5eb49e",

        // Error
        "error":                  "#f07178",
        "on_error":               "#0f1419",
        "error_container":        "#1f2430",
        "on_error_container":     "#bfbab0",

        // Background / Surface
        "background":             "#0f1419",
        "on_background":          "#bfbab0",
        "surface":                "#1f2430",
        "on_surface":             "#bfbab0",

        // Surface variants
        "surface_dim":            "#0f1419",
        "surface_bright":         "#2b323f",
        "surface_container_lowest": "#0a0d11",
        "surface_container_low":  "#151a21",
        "surface_container":      "#1f2430",
        "surface_container_high": "#262c38",
        "surface_container_highest": "#2d3440",

        "surface_variant":        "#272d38",
        "on_surface_variant":     "#707a8c",

        "surface_tint":           "#39bae6",

        // Outline
        "outline":                "#3e4b59",
        "outline_variant":        "#272d38",

        // Misc
        "shadow":                 "#000000",
        "scrim":                  "#000000",

        // Inverse
        "inverse_surface":        "#bfbab0",
        "inverse_on_surface":     "#0f1419",
        "inverse_primary":        "#1e6f89"
    })
}
