import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common

Rectangle {
    Layout.topMargin: Sizes.elevationMargin + Rounding.normal
    Layout.bottomMargin: Sizes.hyprland.gapsOut + Rounding.normal
    Layout.fillHeight: true
    implicitWidth: 1
    color: Colors.colOutlineVariant
}
