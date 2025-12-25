import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    anchors {
        fill: parent
        margins: Padding.large
    }

    PagePlaceholder {
        z: -1
        shown: listView.model.length < 1
        icon: "close"
        title: "Can't Find Any Sounds"
        description: "add ogg sounds in " + Directories.sounds + "ambient"
    }

    ColumnLayout {
        spacing: Padding.huge
        anchors.fill: parent

        BottomDialogHeader {
            title: "Avilable Sounds"
            subTitle: `There is ${listView.model.length} avilable sounds`
        }

        BottomDialogSeparator {
        }

        StyledListView {
            id: listView

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: Padding.normal
            clip: true
            radius: Rounding.verylarge
            model: AmbientSoundsService.availableSounds

            delegate: RippleButton {
                id: iconContainer

                width: listView.width
                height: 64
                buttonRadius: Rounding.normal
                releaseAction: () => {
                    return AmbientSoundsService.playSound(modelData.id);
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Padding.normal
                    spacing: Padding.normal

                    StyledRect {
                        Layout.preferredWidth: iconContainer.height * 0.65
                        Layout.preferredHeight: iconContainer.height * 0.65
                        radius: Rounding.normal
                        color: iconContainer.hovered ? Colors.m3.m3primaryContainer : Colors.colLayer3

                        MaterialSymbol {
                            text: modelData.icon
                            font.pixelSize: 20
                            color: iconContainer.hovered ? Colors.m3.m3onPrimaryContainer : Colors.colOnLayer3
                            fill: 1
                            anchors.centerIn: parent
                        }

                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.name
                        font.pixelSize: Fonts.sizes.normal
                        color: Colors.colOnLayer2
                        elide: Text.ElideRight
                    }

                    MaterialSymbol {
                        text: "add_circle"
                        font.pixelSize: 20
                        color: iconContainer.hovered ? Colors.colPrimary : Colors.colOnLayer2
                        opacity: iconContainer.hovered ? 1 : 0.5
                        fill: iconContainer.hovered ? 1 : 0
                    }

                }

            }

        }

    }

}
