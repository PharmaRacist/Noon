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

        // Reactive property to toggle titles based on memory settings
        property bool sleek: !Mem.options.sidebar.appearance.showNavTitles

        anchors.centerIn: parent
        implicitWidth: navContainer.implicitWidth
        expanded: false
        spacing: sleek ? Padding.small : Padding.large

        Repeater {
            // Using the new reactive enabledCategories list
            model: SidebarData.enabledCategories

            NavigationRailButton {
                required property int index
                required property string modelData // This is the Category ID string

                // UI Properties
                showText: !navRail.sleek
                fontSize: baseSize / 3.5
                baseSize: navContainer.implicitWidth
                implicitWidth: navContainer.implicitWidth

                // Logic
                toggled: navContainer.selectedCategory === modelData && root.showContent
                buttonIcon: SidebarData.getIcon(modelData)

                // Get the 'name' (e.g., "APIs") instead of the 'id' (e.g., "API")
                buttonText: SidebarData.getCategory(modelData).name || modelData

                // Coloring
                highlightColor: navContainer.colors.colSecondaryContainer
                highlightColorHover: navContainer.colors.colSecondaryContainerHover
                highlightColorActive: navContainer.colors.colSecondaryContainerActive
                itemColorActive: navContainer.colors.colOnLayer2

                onClicked: {
                    Noon.playSound("pressed");
                    root.changeContent(modelData);
                }
            }
        }
    }
}
