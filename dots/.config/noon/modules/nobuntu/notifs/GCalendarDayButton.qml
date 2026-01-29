import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts

RippleButton {
    id: button
    property string day
    property int isToday
    property bool bold

    Layout.fillWidth: false
    Layout.fillHeight: false
    implicitWidth: 38
    implicitHeight: 38
    colBackground: "transparent"
    toggled: (isToday == 1)
    buttonRadius: Rounding.verylarge

    contentItem: StyledText {
        anchors.fill: parent
        text: day
        horizontalAlignment: Text.AlignHCenter
        font.weight: bold ? Font.DemiBold : Font.Normal
        color: (isToday == 1) ? Colors.m3.m3onPrimary : (isToday == 0) ? Colors.colOnLayer1 : Colors.colOutlineVariant
        font.pixelSize:Fonts.sizes.small
        Behavior on color {
            CAnim {}
        }
    }
}
