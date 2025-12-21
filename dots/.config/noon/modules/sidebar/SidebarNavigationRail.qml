import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.store

Rectangle {
    id: navContainer

    required property string selectedCategory

    implicitWidth: LauncherData.sizePresets.bar - Padding.large
    clip: true
    color: "transparent"
    Layout.fillHeight: true

    NavigationRail {
        id: navRail

        property bool sleek: !Mem.options.sidebar.appearance.showNavTitles

        anchors.centerIn: parent
        implicitWidth: navContainer.implicitWidth
        expanded: false
        spacing: sleek ? Padding.small : Padding.large

        Repeater {
            model: LauncherData.enabledCategories

            NavigationRailButton {
                required property int index
                required property string modelData

                showText: !navRail.sleek
                fontSize: baseSize / 3.5
                baseSize: navContainer.implicitWidth
                implicitWidth: navContainer.implicitWidth
                toggled: navContainer.selectedCategory === modelData && showContent
                buttonIcon: LauncherData.getIcon(modelData)
                buttonText: modelData
                highlightColor: navContainer.selectedCategory === "Beats" ? TrackColorsService.colors.colSecondaryContainer : Colors.colSecondaryContainer
                highlightColorHover: navContainer.selectedCategory === "Beats" ? TrackColorsService.colors.colSecondaryContainerHover : Colors.colSecondaryContainerHover
                highlightColorActive: navContainer.selectedCategory === "Beats" ? TrackColorsService.colors.colSecondaryContainerActive : Colors.colSecondaryContainerActive
                itemColorActive: navContainer.selectedCategory === "Beats" ? TrackColorsService.colors.colOnSecondaryContainer : Colors.colOnLayer0
                onClicked: {
                    Noon.playSound("pressed");
                    requestCategoryChange(modelData);
                }
            }

        }

        Behavior on spacing {
            Anim {
            }

        }

    }

}
