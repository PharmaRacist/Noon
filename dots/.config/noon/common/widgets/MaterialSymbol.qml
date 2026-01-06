import QtQuick
import qs.common

StyledText {
    id: root

    property real iconSize: Fonts.sizes.small ?? 16
    property real fill: 0
    property real truncatedFill: fill.toFixed(1)
    property var variableAxes: {
        "FILL": truncatedFill,
        "opsz": iconSize
    }
    renderType: Text.NativeRendering

    font {
        hintingPreference: Font.PreferNoHinting
        family: Fonts.family.iconMaterial ?? "Material Symbols Rounded"
        pixelSize: iconSize
        weight: Font.Normal + (Font.DemiBold - Font.Normal) * truncatedFill
        variableAxes: root.variableAxes
    }

    Behavior on opacity {
        Anim {}
    }

    Behavior on fill {
        FAnim {}
    }
}
