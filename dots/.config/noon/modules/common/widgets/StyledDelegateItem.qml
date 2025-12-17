import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.common.functions
import qs
import qs.modules.sidebarLauncher

RippleButton {
    id: root
    property color colActiveColor:Colors.colPrimaryContainer
    property color colActiveItemColor:Colors.colPrimary
    property alias title: title.text
    property alias subtext: subtext.text  // Fixed: was pointing to title.text
    property color colSubtext: Colors.colSubtext
    property color colTitle: Colors.colOnLayer2
    property string materialIcon: "music_note"
    width: parent?.width
    implicitHeight: 64
    colBackground: Colors.colLayer2
    buttonRadius: Rounding.large

    StyledRect {
        id: sideRect
        color: colActiveColor
        leftRadius: Rounding.large
        implicitWidth: 60
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        MaterialSymbol {
            text: root.materialIcon
            font.pixelSize: 30
            fill: 1
            anchors.horizontalCenterOffset: Padding.tiny
            color: colActiveItemColor
            anchors.centerIn: parent
        }
    }

    // Wrapper Item to handle anchors
    Item {
        anchors {
            left: sideRect.right
            leftMargin: Padding.large
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: Padding.normal
        }

        RowLayout {
            anchors.fill: parent
            spacing: Padding.verylarge

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Padding.small

                StyledText {
                    id: title
                    maximumLineCount: 1
                    Layout.preferredWidth:240
                    horizontalAlignment:Text.AlignLeft
                    font.pixelSize: Fonts.sizes.normal
                    color: root.colTitle
                    elide: Text.ElideRight
                }

                StyledText {
                    id: subtext
                    Layout.fillWidth: true
                    horizontalAlignment:Text.AlignLeft
                    font.pixelSize: Fonts.sizes.small
                    color: root.colSubtext
                    visible: text !== ""
                }
            }
        }
    }
}
