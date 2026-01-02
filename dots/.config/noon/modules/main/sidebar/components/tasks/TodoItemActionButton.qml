import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets

RippleButton {
    id: button

    property string buttonText: ""
    property string tooltipText: ""

    implicitHeight: 30
    implicitWidth: implicitHeight
    buttonRadius: Rounding.large

    StyledToolTip {
        content: tooltipText
        extraVisibleCondition: tooltipText.length > 0
    }

    Behavior on implicitWidth {
        SmoothedAnimation {
            velocity: Appearance.animation.elementMove.velocity
        }

    }

    contentItem: MaterialSymbol {
        text: buttonText
        fill: 1
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Fonts.sizes.verylarge
        color: Colors.colOnLayer1
    }

}
