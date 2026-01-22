import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

Item {
    id: navContainer

    required property string selectedCategory
    required property QtObject colors
    Layout.fillHeight: true
    Layout.minimumWidth: childrenRect.width
    implicitWidth: childrenRect.width

    NavigationRail {
        id: navRail
        anchors.centerIn: parent
        implicitWidth: SidebarData.sizePresets.bar
        expanded: false
        spacing: sleek ? Padding.small : Padding.large
        readonly property bool sleek: !Mem.options.sidebar.appearance.showNavTitles

        Repeater {
            model: SidebarData.enabledCategories

            NavigationRailButton {
                required property int index
                required property string modelData
                showText: !navRail.sleek
                fontSize: baseSize / 3.5
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                baseSize: navRail.implicitWidth * 0.75
                implicitWidth: navRail.implicitWidth

                toggled: (navContainer.selectedCategory === modelData)
                buttonIcon: SidebarData.getIcon(modelData)
                buttonText: SidebarData.getCategory(modelData).name || modelData
                highlightColor: navContainer.colors.colSecondaryContainer
                highlightColorHover: navContainer.colors.colSecondaryContainerHover
                highlightColorActive: navContainer.colors.colSecondaryContainerActive
                itemColorActive: navContainer.colors.colOnLayer2

                onClicked: {
                    NoonUtils.playSound("pressed");
                    root.changeContent(modelData);
                }
            }
        }
    }
}
