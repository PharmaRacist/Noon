import qs.modules.common
import QtQuick

StyledText {
    id: root
    property real iconSize: Fonts.sizes.small ?? 16
    property real fill: 0
    property real truncatedFill: fill.toFixed(1) // Reduce memory consumption spikes from constant font remapping
    renderType: Text.NativeRendering
    font {
        hintingPreference: Font.PreferNoHinting
        family: Fonts.family.iconMaterial ?? "Material Symbols Rounded"
        pixelSize: iconSize
        weight: Font.Normal + (Font.DemiBold - Font.Normal) * truncatedFill
        variableAxes: {
            "FILL": truncatedFill,
            // "wght": font.weight,
            // "GRAD": 0,
            "opsz": iconSize
        }
    }

    Behavior on fill {
        FAnim {}
    }
}
