import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

/**
 * Material 3 dialog button. See https://m3.material.io/components/dialogs/overview
 */
RippleButton {
    id: root

    property string buttonText
    property color colEnabled: Colors.colPrimary ?? "#65558F"
    property color colDisabled: Colors.m3.m3outline ?? "#8D8C96"
    property alias colText: buttonTextWidget.color

    padding: 14
    implicitHeight: 36
    implicitWidth: buttonTextWidget.implicitWidth + padding * 2
    buttonRadius: Rounding.full ?? 9999
    colBackground: ColorUtils.transparentize(Colors.colLayer3)
    colBackgroundHover: Colors.colLayer3Hover
    colRipple: Colors.colLayer3Active

    contentItem: StyledText {
        id: buttonTextWidget

        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Fonts.sizes.small ?? 12
        color: root.enabled ? root.colEnabled : root.colDisabled

        Behavior on color {
            CAnim {}
        }

    }

}
