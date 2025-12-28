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
    property QtObject colors: Colors

    implicitWidth: implicitSize
    implicitHeight: implicitSize
    buttonRadius: Rounding.normal
    colBackground: colors.colLayer2

    MaterialSymbol {
        id: symbol

        font.pixelSize: root.implicitSize / 2
        anchors.centerIn: parent
        text: materialIcon
        color: colors.colOnSecondaryContainer
        fill: materialIconFill ? 1 : 0
    }

}
