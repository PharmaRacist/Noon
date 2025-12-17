import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

RippleButton {
    id: root

    property string materialIcon
    property bool materialIconFill: true
    property int implicitSize: 36
    implicitWidth: implicitSize
    implicitHeight: implicitSize
    buttonRadius: Rounding.normal
    colBackground: Colors.colLayer2
    property alias iconSize: symbol.font.pixelSize
    MaterialSymbol {
        id: symbol
        font.pixelSize:root.implicitSize / 2
        anchors.centerIn: parent
        text: materialIcon
        color: Colors.colOnSecondaryContainer
        fill: materialIconFill ? 1 : 0
    }
}
