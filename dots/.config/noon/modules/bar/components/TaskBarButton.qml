import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs
import qs.modules.common
import qs.modules.common.widgets

RippleButton {
    implicitWidth: implicitHeight - topInset - bottomInset
    buttonRadius: Rounding.normal
    topInset: Sizes.hyprlandGapsOut - 15
    bottomInset: Sizes.hyprlandGapsOut - 15
}
