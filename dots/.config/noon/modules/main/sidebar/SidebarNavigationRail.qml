import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

StyledRect {
    id: navContainer

    required property string selectedCategory
    property QtObject colors: Colors
    implicitWidth: SidebarData.sizePresets.bar - Padding.large
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
            model: SidebarData.enabledCategories

            NavigationRailButton {
                required property int index
                required property string modelData

                showText: !navRail.sleek
                fontSize: baseSize / 3.5
                baseSize: navContainer.implicitWidth
                implicitWidth: navContainer.implicitWidth
                toggled: navContainer.selectedCategory === modelData && showContent
                buttonIcon: SidebarData.getIcon(modelData)
                buttonText: modelData
                highlightColor: navContainer.colors.colSecondaryContainer
                highlightColorHover: navContainer.colors.colSecondaryContainerHover
                highlightColorActive: navContainer.colors.colSecondaryContainerActive
                itemColorActive: navContainer.colors.colOnLayer2
                onClicked: {
                    Noon.playSound("pressed");
                    requestCategoryChange(modelData);
                }
            }
        }
    }
}
