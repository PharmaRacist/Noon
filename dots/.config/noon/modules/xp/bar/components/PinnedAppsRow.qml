import "../../common"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import qs.services
import qs.common
import QtQuick.Effects
import qs.common.widgets

RowLayout {
    id: pinnedAppsRow
    Layout.fillHeight: true
    Layout.preferredWidth: childrenRect.implicitWidth + Padding.massive
    Layout.leftMargin: XPadding.small
    spacing: XPadding.verysmall
    Repeater {
        model: Mem.states.favorites.apps ?? []
        StyledIconImage {
            implicitSize: XSizes.taskbar.pinnedItemSize
            source: NoonUtils.iconPath(modelData)
            MouseArea {
                anchors.fill: parent
                onPressed: DesktopEntries.byId(modelData).execute();

            }
        }
    }
}
