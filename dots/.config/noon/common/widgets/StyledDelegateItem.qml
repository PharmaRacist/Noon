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
    property string iconSource
    property QtObject colors: Colors
    property bool active: toggled
    property int shapePadding: 6
    property var shape: MaterialShape.Shape.Cookie6Sided
    property string title: ""
    property string subtext: ""
    property color colSubtext: Colors.colSubtext
    property color colTitle: Colors.colOnLayer2
    property bool expanded: true
    property int extraRightPadding: 0
    property string materialIcon: "music_note"
    property int fill: 0
    width: parent?.width
    implicitHeight: 64
    colBackgroundToggled: colors.colPrimaryContainer
    colBackgroundHover: colors.colPrimaryContainerHover
    colBackgroundToggledHover: colors.colPrimaryContainerHover
    colBackground: colors.colLayer2
    buttonRadius: Rounding.large
    Loader {
        id: iconLoader
        z: -1
        sourceComponent: iconSource.length > 0 ? iconComponent : shapeComponent
        anchors {
            left: parent.left
            leftMargin: Padding.huge
            verticalCenter: parent.verticalCenter
        }

        Component {
            id: iconComponent
            Item {
                implicitWidth: 50
                implicitHeight: 50
                StyledIconImage {
                    anchors.centerIn: parent
                    implicitSize: 37
                    source: root.iconSource
                }
            }
        }
        Component {
            id: shapeComponent
            MaterialShapeWrappedMaterialSymbol {
                id: m3shape
                colors: root.colors
                shape: MaterialShape.Cookie6Sided
                padding: Padding.large
                iconSize: parent.height / 2.5
                colSymbol: root.active ? colors.colPrimaryActive : colors.colPrimary
                text: root.materialIcon
                fill: root.fill
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
        }
    }

    // Wrapper Item to handle anchors
    Item {
        visible: expanded
        anchors {
            left: iconLoader.right
            leftMargin: Padding.large
            right: parent.right
            rightMargin: Padding.massive + root.extraRightPadding
            top: parent.top
            bottom: parent.bottom
            margins: Padding.normal
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            anchors.fill: parent
            spacing: Padding.small

            StyledText {
                id: title
                text: root.title
                Layout.rightMargin: Padding.verylarge
                maximumLineCount: 1
                wrapMode: TextEdit.Wrap
                elide: Text.ElideRight
                Layout.preferredWidth: 240
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: Fonts.sizes.normal
                color: {
                    if (root.active)
                        return root.colors.colOnPrimaryContainer;
                    else
                        return root.colors.colOnLayer2;
                }
            }

            StyledText {
                id: subtext
                text: root.subtext
                Layout.fillWidth: true
                maximumLineCount: 1
                wrapMode: TextEdit.Wrap
                elide: Text.ElideRight
                Layout.rightMargin: Padding.verylarge
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: Fonts.sizes.small
                color: root.colSubtext
                visible: text !== ""
            }
        }
    }
}
