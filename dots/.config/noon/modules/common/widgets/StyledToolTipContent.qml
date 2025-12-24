import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    required property string text
    property bool shown: false
    property real horizontalPadding: 10
    property real verticalPadding: 5
    property bool isVisible: backgroundRectangle.implicitHeight > 0

    implicitWidth: tooltipTextObject.implicitWidth + 2 * root.horizontalPadding
    implicitHeight: tooltipTextObject.implicitHeight + 2 * root.verticalPadding

    Rectangle {
        id: backgroundRectangle

        color: Colors.colTooltip ?? "#3C4043"
        radius: Rounding.verysmall ?? 7
        opacity: shown ? 1 : 0
        implicitWidth: shown ? (tooltipTextObject.implicitWidth + 2 * root.horizontalPadding) : 0
        implicitHeight: shown ? (tooltipTextObject.implicitHeight + 2 * root.verticalPadding) : 0
        clip: true

        anchors {
            bottom: root.bottom
            horizontalCenter: root.horizontalCenter
        }

        StyledText {
            id: tooltipTextObject

            anchors.centerIn: parent
            text: root.text
            font.pixelSize: Fonts.sizes.verysmall ?? 14
            font.hintingPreference: Font.PreferNoHinting // Prevent shaky text
            color: Colors.colOnTooltip ?? "#FFFFFF"
            wrapMode: Text.Wrap
        }

        Behavior on implicitWidth {
            FAnim {
            }

        }

        Behavior on implicitHeight {
            FAnim {
            }

        }

        Behavior on opacity {
            FAnim {
            }

        }

    }

}
