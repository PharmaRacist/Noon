import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

MenuItem {
    id: root
    property color colBackground: colors.colLayer2
    property color colBackgroundHover: colors.colLayer2Hover
    property color colBackgroundActive: colors.colLayer2Active
    property color colContent: colors.colOnLayer2
    property color colContentActive: colors.colOnLayer2
    property alias materialIcon: symbol.text
    property QtObject colors: Colors

    height: 40

    background: Rectangle {
        color: parent.hovered ? root.colBackgroundHover : "transparent"
        radius: Rounding.small
    }

    contentItem: RowLayout {
        spacing: Padding.normal
        Layout.leftMargin: Padding.large
        Layout.rightMargin: Padding.large

        Symbol {
            id: symbol

            Layout.leftMargin: Padding.normal
            text: "share"
            fill: 1
            font.pixelSize: 18
            color: root.enabled ? root.colContentActive : root.colContent
        }

        StyledText {
            text: root.text
            color: root.enabled ? root.colContentActive : root.colContent
            font.variableAxes: Fonts.variableAxes.main
            font.pixelSize: Fonts.sizes.small
            Layout.fillWidth: true
            opacity: parent.parent.enabled ? 1 : 0.5
        }
    }
}
