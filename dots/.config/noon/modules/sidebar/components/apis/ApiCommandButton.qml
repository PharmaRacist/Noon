import QtQuick
import qs.modules.common
import qs.modules.common.widgets

GroupButton {
    id: button

    property string buttonText

    horizontalPadding: 8
    verticalPadding: 6
    baseWidth: contentItem.implicitWidth + horizontalPadding * 2
    clickedWidth: baseWidth + 20
    baseHeight: contentItem.implicitHeight + verticalPadding * 2
    buttonRadius: down ? Rounding.verysmall : Rounding.small
    colBackground: Colors.colLayer2
    colBackgroundHover: Colors.colLayer2Hover
    colBackgroundActive: Colors.colLayer2Active

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: Colors.m3.m3onSurface
    }

}
