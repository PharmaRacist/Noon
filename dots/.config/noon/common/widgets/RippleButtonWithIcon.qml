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
    property bool animateIcon: false
    implicitWidth: implicitSize
    implicitHeight: implicitSize
    buttonRadius: Rounding.normal
    colBackground: colors.colLayer2

    Symbol {
        id: symbol
        animateChange: root.animateIcon
        font.pixelSize: root.implicitSize / 2
        anchors.centerIn: parent
        text: materialIcon
        color: {
            if (root.toggled)
                colors.colOnPrimary;
            else if (root.containsMouse)
                colors.colOnLayer1Hover;
            else
                colors.colOnLayer1;
        }
        fill: materialIconFill ? 1 : 0
    }
}
