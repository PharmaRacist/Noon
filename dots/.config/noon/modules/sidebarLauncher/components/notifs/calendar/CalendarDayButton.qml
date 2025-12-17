import qs.modules.common
import qs.modules.common.widgets

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RippleButton {
    id: button
    property string day
    property int isToday
    property bool bold

    Layout.fillWidth: false
    Layout.fillHeight: false
    implicitWidth: 34
    implicitHeight: 34

    toggled: (isToday == 1)
    buttonRadius: Rounding.normal

    contentItem: StyledText {
        anchors.fill: parent
        text: day
        horizontalAlignment: Text.AlignHCenter
        font.weight: bold ? Font.DemiBold : Font.Normal
        color: (isToday == 1) ? Colors.m3.m3onPrimary : (isToday == 0) ? Colors.colOnLayer1 : Colors.colOutlineVariant

        Behavior on color {
            CAnim {}
        }
    }
}
