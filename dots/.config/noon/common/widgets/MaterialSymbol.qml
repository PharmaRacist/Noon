import QtQuick
import qs.common

StyledText {
    id: root

    property real iconSize: Fonts.sizes.small ?? 16
    property real fill: 0
    property real truncatedFill: fill.toFixed(1) // Reduce memory consumption spikes from constant font remapping

    renderType: Text.NativeRendering

    font {
        // "wght": font.weight,
        // "GRAD": 0,

        hintingPreference: Font.PreferNoHinting
        family: Fonts.family.iconMaterial ?? "Material Symbols Rounded"
        pixelSize: iconSize
        weight: Font.Normal + (Font.DemiBold - Font.Normal) * truncatedFill
        variableAxes: {
            "FILL": truncatedFill,
            "opsz": iconSize
        }
    }

    Behavior on opacity {
        Anim {
        }

    }

    Behavior on fill {
        FAnim {
        }

    }

}
