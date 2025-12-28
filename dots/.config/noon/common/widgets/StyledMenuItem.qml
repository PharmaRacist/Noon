import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

MenuItem {
    id:root
    property color colBackground:Colors.m3.m3surfaceContainer
    property color colBackgroundHover:Colors.m3.m3surfaceContainerHigh
    property color colBackgroundActive:Colors.m3.m3secondaryContainer
    property color colContent:Colors.m3.m3onSurfaceContainer
    property color colContentActive:Colors.m3.m3onSecondaryContainer
    property alias materialIcon:symbol.text
    height: 40

    background: Rectangle {
        color: parent.hovered ? root.colBackgroundHover : "transparent"
        radius: Rounding.small
    }
    contentItem: RowLayout {
        spacing: Padding.normal
        Layout.leftMargin: Padding.large
        Layout.rightMargin: Padding.large

        MaterialSymbol {
            id:symbol
            Layout.leftMargin: Padding.normal
            text: "share"
            fill:1
            font.pixelSize: 18
            color: root.enabled ? root.colContentActive : root.colContent
        }

        StyledText {
            text: root.text
            color: root.enabled ? root.colContentActive : root.colContent
            font.variableAxes:Fonts.variableAxes.main
            font.pixelSize: Fonts.sizes.small
            Layout.fillWidth: true
            opacity: parent.parent.enabled ? 1 : 0.5
        }
    }

}
