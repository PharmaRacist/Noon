import "../common"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs
import qs.common
import qs.common.widgets
import qs.services

StyledPanel {
    id: root

    property bool top: false

    shell: "xp"
    name: "startMenu"
    implicitHeight: XSizes.startMenu.size.height
    implicitWidth: XSizes.startMenu.size.width
    visible: GlobalStates.xp.startMenu.visible

    anchors {
        bottom: true
        top: false
        left: true
    }

    StyledRect {
        id: bg

        color: XColors.colors.primaryContainer
        topLeftRadius: XRounding.normal
        topRightRadius: XRounding.large
        border.color: XColors.colors.primaryBorder
        // border.width: 2
        layer.enabled: true

        ColumnLayout {
            id: contentColumn

            anchors.fill: parent

            StyledRect {
                Layout.fillWidth: true
                color: "transparent"
                Layout.preferredHeight: 175

                RowLayout {
                    anchors.fill: parent

                    StyledRect {
                        Layout.leftMargin: XPadding.huge
                        radius: XRounding.large
                        implicitHeight: 120
                        implicitWidth: 120
                    }

                }

            }

            Spacer {
            }

        }

        anchors {
            fill: parent
            margins: 10
            bottomMargin: -border.width - 2
        }

        layer.effect: DropShadow {
            verticalOffset: 4
            horizontalOffset: 4
            color: XColors.colors.shadows
            radius: 3
            samples: 2
        }

    }

}
