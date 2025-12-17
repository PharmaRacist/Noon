import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolTip {
    id: root
    property string content
    property bool extraVisibleCondition: true
    property bool alternativeVisibleCondition: false
    property bool internalVisibleCondition: {
        const ans = (extraVisibleCondition && (parent.hovered === undefined || parent?.hovered)) || alternativeVisibleCondition;
        return ans;
    }
    verticalPadding: 7
    horizontalPadding: 14
    opacity: internalVisibleCondition ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        Anim {}
    }

    background: null

    contentItem: Item {
        id: contentItemBackground
        implicitWidth: tooltipTextObject.width + 2 * root.horizontalPadding
        implicitHeight: tooltipTextObject.height + 2 * root.verticalPadding

        Rectangle {
            id: backgroundRectangle
            anchors.bottom: contentItemBackground.bottom
            anchors.horizontalCenter: contentItemBackground.horizontalCenter
            color: Colors.colLayer2 ?? "#3C4043"
            radius: Rounding.verysmall ?? 7
            width: internalVisibleCondition ? (tooltipTextObject.width + 2 * root.horizontalPadding) : 0
            height: internalVisibleCondition ? (tooltipTextObject.height + 2 * root.verticalPadding) : 0
            clip: true

            Behavior on width {
                Anim {}
            }
            Behavior on height {
                Anim {}
            }

            StyledText {
                id: tooltipTextObject
                anchors.centerIn: parent
                text: content
                font.pixelSize: Fonts.sizes.small - 2 ?? 14
                // font.weight: 400
                font.hintingPreference: Font.PreferFullHinting
                // Prevent shaky text
                color: Colors.colOnLayer1 ?? "#FFFFFF"
                wrapMode: Text.Wrap
            }
        }
    }
}
