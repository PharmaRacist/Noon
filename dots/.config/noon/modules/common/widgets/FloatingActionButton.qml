import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

/**
 * Material 3 FAB.
 */
RippleButton {
    id: root
    property string iconText: "add"
    property bool expanded: false
    property real baseSize: 56
    property real elementSpacing: 5
    implicitWidth: Math.max(contentRowLayout.implicitWidth + 10 * 2, baseSize)
    implicitHeight: baseSize
    buttonRadius: Rounding.small
    colBackground: Colors.colPrimaryContainer
    colBackgroundHover: Colors.colPrimaryContainerHover
    colRipple: Colors.colPrimaryContainer
    contentItem: RowLayout {
        id: contentRowLayout
        property real horizontalMargins: (root.baseSize - icon.width) / 2
        anchors {
            verticalCenter: parent?.verticalCenter
            left: parent?.left
            leftMargin: contentRowLayout.horizontalMargins
        }
        spacing: 0

        MaterialSymbol {
            id: icon
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 24
            fill: 1
            color: Colors.colPrimary
            text: root.iconText
        }
        Loader {
            active: true
            sourceComponent: Revealer {
                visible: root.expanded || implicitWidth > 0
                reveal: root.expanded
                implicitWidth: reveal ? (buttonText.implicitWidth + root.elementSpacing + contentRowLayout.horizontalMargins) : 0
                StyledText {
                    id: buttonText
                    anchors {
                        left: parent.left
                        leftMargin: root.elementSpacing
                    }
                    text: root.buttonText
                    color: Colors.colOnPrimary
                    font.pixelSize: 14
                    font.weight: 450
                }
            }
        }
    }
}
