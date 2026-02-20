import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

StyledRect {
    id: root
    required property var content
    required property string selectedCategory
    required property QtObject colors
    readonly property bool sleek: !Mem.options.sidebar.appearance.showNavTitles
    Layout.fillHeight: true
    implicitWidth: Sizes.sidebar.bar + content.panelWindow.rounding + 2
    color: colors.colLayer1

    StyledListView {
        id: navRailList
        anchors.centerIn: parent
        implicitWidth: Sizes.sidebar.bar
        implicitHeight: contentHeight
        hint: true
        clip: true
        popin: false
        radius: Rounding.large
        spacing: sleek ? Padding.large : Padding.verylarge
        model: SidebarData.enabledCategories

        delegate: NavigationRailButton {
            required property int index
            required property string modelData

            fontSize: 12
            showText: !root.sleek

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 1

            implicitWidth: baseSize

            baseSize: navRailList.width / 1.2
            toggled: root.selectedCategory === modelData

            buttonIcon: SidebarData.getIcon(modelData, toggled)
            buttonText: modelData || ""

            highlightColor: root.colors.colSecondaryContainer
            highlightColorHover: root.colors.colSecondaryContainerHover
            highlightColorActive: root.colors.colSecondaryContainerActive
            itemColorActive: root.colors.colOnLayer2

            onClicked: content.changeContent(modelData)
        }
    }
}
