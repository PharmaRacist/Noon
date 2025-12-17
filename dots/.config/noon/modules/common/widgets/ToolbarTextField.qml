import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

TextField {
    id: filterField

    property alias colBackground: background.color

    Layout.fillHeight: true
    implicitWidth: 200
    padding: 10
    placeholderTextColor: Colors.colSubtext
    color: Colors.colOnLayer1
    font.pixelSize: Fonts.sizes.small
    renderType: Text.NativeRendering
    selectedTextColor: Colors.colOnSecondaryContainer
    selectionColor: Colors.colSecondaryContainer

    background: Rectangle {
        id: background

        color: Colors.colLayer1
        radius: Rounding.full
    }

}
