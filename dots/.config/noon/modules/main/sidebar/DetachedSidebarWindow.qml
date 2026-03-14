import QtQuick
import qs.store
import qs.common
import qs.common.widgets

AppWindow {
    id: root
    property string category
    property bool expanded: width > Sizes.sidebar.quarter * 0.9
    color: SidebarData.getColors(category).colLayer0

    ContentChild {
        anchors.fill: parent
        _detached: true
        anchors.margins: ["Beats", "Notes"].includes(category) ? 0 : Padding.massive
        category: root.category
        parentRoot: root
    }

    Component.onCompleted: SidebarData.detachedContent.push(category)
    onVisibleChanged: !visible ? kill() : null

    function kill() {
        let states = SidebarData.detachedContent;
        let item = states.filter(item => item === category);
        states.pop(states.indexOf(item));
    }
}
