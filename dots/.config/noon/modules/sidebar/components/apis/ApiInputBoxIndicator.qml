import qs.common
import qs.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item { // Model indicator
    id: root
    property string icon: "api"
    property string text: ""
    property string tooltipText: ""
    implicitHeight: rowLayout.implicitHeight + 4 * 2
    implicitWidth: rowLayout.implicitWidth + 4 * 2

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent

        MaterialSymbol {
            text: root.icon
            font.pixelSize: Fonts.sizes.normal
        }
        StyledText {
            id: providerName
            font.pixelSize: Fonts.sizes.verysmall
            color: Colors.m3.m3onSurface
            elide: Text.ElideRight
            text: root.text
            animateChange: true
        }
    }

    Loader {
        active: root.tooltipText?.length > 0
        anchors.fill: parent
        sourceComponent: MouseArea {
            id: mouseArea
            hoverEnabled: true

            StyledToolTip {
                id: toolTip
                extraVisibleCondition: false
                alternativeVisibleCondition: mouseArea.containsMouse // Show tooltip when hovered
                text: root.tooltipText
            }
        }
    }
}
