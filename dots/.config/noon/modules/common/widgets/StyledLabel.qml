import qs.modules.common
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Label {
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferFullHinting
        family: Fonts.family.main ?? "sans-serif"
        pixelSize: Fonts.sizes.small ?? 15
    }
    color: Colors.m3.m3onBackground ?? "black"
    linkColor: Colors.m3.m3primary
}
