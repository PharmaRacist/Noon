import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

StyledListView {
    id: navRail
    required property string selectedCategory
    required property QtObject colors
    readonly property bool sleek: !Mem.options.sidebar.appearance.showNavTitles
    // Layout.fillHeight: true
    height: model.length * 50
    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: GlobalStates.main.sidebar.hoverMode
    Layout.maximumWidth: implicitWidth
    implicitWidth: Sizes.sidebar.bar
    hint: false
    clip: true
    popin: false
    radius: Rounding.large
    spacing: sleek ? Padding.large : Padding.verylarge
    model: SidebarData.enabledCategories

    delegate: NavigationRailButton {
        required property int index
        required property string modelData
        showText: !navRail.sleek
        fontSize: 12
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        baseSize: navRail.implicitWidth * 0.75
        implicitWidth: navRail.implicitWidth
        toggled: (navRail.selectedCategory === modelData)
        buttonIcon: toggled ? SidebarData.getActiveIcon(modelData) : SidebarData.getIcon(modelData)
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
