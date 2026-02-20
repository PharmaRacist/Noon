import QtQuick
import QtQuick.Controls.Material
import Quickshell
import qs.common

CheckBox {
    Material.theme: Colors.m3.darkmode ? Material.Dark : Material.Light
    Material.accent: Colors.colPrimaryContainer
    Material.primary: Colors.colPrimary
    Material.roundedScale: Rounding.normal
    Material.elevation: 8
}
