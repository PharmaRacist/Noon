import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

Item {
    id: root

    required property PwNode node

    implicitHeight: rowLayout.implicitHeight

    PwObjectTracker {
        objects: [node]
    }

    RowLayout {
        id: rowLayout

        anchors.fill: parent
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                StyledText {
                    Layout.fillWidth: true
                    font.pixelSize: Fonts.sizes.normal
                    elide: Text.ElideRight
                    text: {
                        // application.name -> description -> name
                        const app = root.node.properties["application.name"] ?? (root.node.description != "" ? root.node.description : root.node.name);
                        const media = root.node.properties["media.name"];
                        return media != undefined ? `${app} • ${media}` : app;
                    }
                }
            }

            RowLayout {
                spacing: 10

                Image {
                    property real size: slider.trackHeight * 1.3

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: source != ""
                    sourceSize.width: size
                    sourceSize.height: size
                    source: {
                        let icon;
                        icon = AppSearch.guessIcon(root.node.properties["application.icon-name"]);
                        if (AppSearch.iconExists(icon))
                            return NoonUtils.iconPath(icon);

                        icon = AppSearch.guessIcon(root.node.properties["node.name"]);
                        return NoonUtils.iconPath(icon);
                    }
                }

                StyledSlider {
                    id: slider

                    value: root.node.audio.volume
                    onValueChanged: root.node.audio.volume = value
                }
            }
        }
    }
}
