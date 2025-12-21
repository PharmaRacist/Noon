import qs.modules.common
import qs.modules.common.widgets

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RippleButton {
    id: button
    property string buttonText: ""
    property string tooltipText: ""

    implicitHeight: 30
    implicitWidth: implicitHeight

    Behavior on implicitWidth {
        SmoothedAnimation {
            velocity: Appearance.animation.elementMove.velocity
        }
    }

    buttonRadius: Rounding.large

    contentItem: MaterialSymbol {
        text: buttonText
        fill: 1
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Fonts.sizes.verylarge
        color: Colors.colOnLayer1
    }

    StyledToolTip {
        content: tooltipText
        extraVisibleCondition: tooltipText.length > 0
    }
}
