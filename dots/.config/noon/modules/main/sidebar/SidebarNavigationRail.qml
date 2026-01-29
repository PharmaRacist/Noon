import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

NavigationRail {
    id: navRail
    required property string selectedCategory
    required property QtObject colors
    readonly property bool sleek: !Mem.options.sidebar.appearance.showNavTitles
    Layout.fillHeight: true
    Layout.fillWidth: GlobalStates.main.sidebar.hoverMode
    Layout.maximumWidth: implicitWidth
    implicitWidth:Sizes.sidebar.bar
    spacing: sleek ? Padding.small : Padding.large
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
            toggled: (navRail.selectedCategory === modelData)
            buttonIcon: SidebarData.getIcon(modelData)
            buttonText: SidebarData.getCategory(modelData).name || modelData
            highlightColor: navRail.colors.colSecondaryContainer
            highlightColorHover: navRail.colors.colSecondaryContainerHover
            highlightColorActive: navRail.colors.colSecondaryContainerActive
            itemColorActive: navRail.colors.colOnLayer2
            onClicked: {
                NoonUtils.playSound("pressed");
                root.changeContent(modelData);
            }
        }
    }
}
