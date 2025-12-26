import QtQuick
import QtQuick.Controls
import qs.common

/**
 * Does not include visual layout, but includes the easily neglected colors.
 */
TextArea {
    renderType: Text.NativeRendering
    selectedTextColor: Colors.m3.m3onSecondaryContainer
    selectionColor: Colors.colSecondaryContainer
    placeholderTextColor: Colors.m3.m3outline

    font {
        family: Fonts.family.main ?? "sans-serif"
        pixelSize: Fonts.sizes.small ?? 15
        hintingPreference: Font.PreferFullHinting
    }

}
