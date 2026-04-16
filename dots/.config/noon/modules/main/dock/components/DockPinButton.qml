import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

GroupButtonWithIcon {
    id: root
    buttonRadius: Rounding.normal
    Layout.fillHeight: true
    baseWidth: height
    Layout.margins: Padding.huge
    Layout.rightMargin: 0
    toggled: Mem.states.dock.pinned
    materialIcon: "push_pin"
    releaseAction: () => Mem.states.dock.pinned = !Mem.states.dock.pinned
}
