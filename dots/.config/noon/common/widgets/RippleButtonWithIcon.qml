import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets

RippleButton {
    id: root

    property string materialIcon
    property bool materialIconFill: true
    property int implicitSize: 36
    property alias iconColor: symbol.color
    property alias iconSize: symbol.font.pixelSize

    implicitWidth: implicitSize
    implicitHeight: implicitSize
    buttonRadius: Rounding.normal
    colBackground: Colors.colLayer2

    MaterialSymbol {
        id: symbol

        font.pixelSize: root.implicitSize / 2
        anchors.centerIn: parent
        text: materialIcon
        color: Colors.colOnSecondaryContainer
        fill: materialIconFill ? 1 : 0
    }

}
