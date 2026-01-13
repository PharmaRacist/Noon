import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.services
import qs.common.functions
import qs.modules.main.sidebar

RippleButton {
    id: root
    property alias shapePadding: m3shape.padding
    property alias shape: m3shape.shape
    property color colActiveColor: Colors.colPrimaryContainer
    property color colActiveItemColor: Colors.colPrimary
    property alias title: title.text
    property alias subtext: subtext.text  // Fixed: was pointing to title.text
    property color colSubtext: Colors.colSubtext
    property color colTitle: Colors.colOnLayer2
    property bool expanded: true
    property string materialIcon: "music_note"
    width: parent?.width
    implicitHeight: 64
    colBackground: Colors.colLayer2
    buttonRadius: Rounding.large
    MaterialShapeWrappedMaterialSymbol {
        id: m3shape
        anchors {
            left: parent.left
            leftMargin: Padding.huge
            verticalCenter: parent.verticalCenter
        }
        colors: root.colors
        shape: MaterialShape.Cookie6Sided
        padding: Padding.large
        iconSize: parent.height / 2.5
        colSymbol: colActiveItemColor
        text: root.materialIcon
        MouseArea {
            id: shapeHoverArea
            enabled: !root.expanded
            hoverEnabled: true
            anchors.fill: parent
        }
        StyledToolTip {
            extraVisibleCondition: shapeHoverArea.containsMouse
            content: root.title
        }
    }

    // Wrapper Item to handle anchors
    Item {
        visible: expanded
        anchors {
            left: m3shape.right
            leftMargin: Padding.large
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: Padding.normal
        }

        RowLayout {
            anchors.fill: parent
            spacing: Padding.massive

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Padding.small

                StyledText {
                    id: title
                    maximumLineCount: 1
                    wrapMode: TextEdit.Wrap
                    elide: Text.ElideRight
                    Layout.preferredWidth: 240
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: Fonts.sizes.normal
                    color: root.colTitle
                }

                StyledText {
                    id: subtext
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: Fonts.sizes.small
                    color: root.colSubtext
                    visible: text !== ""
                }
            }
        }
    }
}
