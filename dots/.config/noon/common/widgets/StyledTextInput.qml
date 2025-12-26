import QtQuick
import QtQuick.Controls
import qs.common

/**
 * Does not include visual layout, but includes the easily neglected colors.
 */
TextInput {
    renderType: Text.NativeRendering
    selectedTextColor: Colors.m3.m3onSecondaryContainer
    selectionColor: Colors.colSecondaryContainer

    font {
        family: Fonts.family.main ?? "sans-serif"
        pixelSize: Fonts.sizes.small ?? 15
        hintingPreference: Font.PreferFullHinting
    }

}
