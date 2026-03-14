import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets

RippleButton {
    implicitWidth: implicitHeight - topInset - bottomInset
    buttonRadius: Rounding.normal
    topInset: Sizes.hyprland.gapsOut - 15
    bottomInset: Sizes.hyprland.gapsOut - 15
}
