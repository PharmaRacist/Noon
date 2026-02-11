import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets

RippleButtonWithIcon {
    id: button

    property string hintText: ""

    materialIconFill: true
    implicitHeight: 30
    implicitWidth: implicitHeight
    buttonRadius: Rounding.large
    StyledToolTip {
        content: hintText
        extraVisibleCondition: hintText.length > 0 && button.hovered
    }
}
