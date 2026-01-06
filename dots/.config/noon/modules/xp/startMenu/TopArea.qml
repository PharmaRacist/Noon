import "../common"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.services

RowLayout {
    id:root
    property int topAreaHeight: 75

    Layout.fillWidth: true
    Layout.preferredHeight: root.topAreaHeight
    Layout.leftMargin: XPadding.normal
    Layout.topMargin: XPadding.verysmall
    spacing: XPadding.normal
    StyledRect {
        color: "#BAD3F4"
        radius: XRounding.small
        height: topAreaHeight * 0.9
        width: height
        StyledImage {
            anchors.fill: parent
            anchors.margins: 3
            source: Directories.standard.home + "/.face"
            mipmap: true
            cache: true
            asynchronous: true
        }
    }
    StyledText {
        text: SysInfoService.username.charAt(0).toUpperCase() + SysInfoService.username.slice(1)
        color: "#FFFFFF"
        font {
            pixelSize: XFonts.sizes.huge
            weight: Font.Bold
            family: XFonts.family.title
        }
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 4
            horizontalOffset: 3
            opacity: 0.5
            color: XColors.colors.colShadows
            samples: 4
            radius: 5
        }
    }
}
