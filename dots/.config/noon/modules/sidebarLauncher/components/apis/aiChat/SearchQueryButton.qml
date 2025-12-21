import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

RippleButton {
    id: root

    property string query

    implicitHeight: 30
    leftPadding: 6
    rightPadding: 10
    buttonRadius: Rounding.verysmall
    colBackground: Colors.colSurfaceContainerHighest
    colBackgroundHover: Colors.colSurfaceContainerHighestHover
    colRipple: Colors.colSurfaceContainerHighestActive
    onClicked: {
        let url = Mem.options.search.engineBaseUrl + root.query;
        for (let site of (Mem.options.search.excludedSites ?? [])) {
            url += ` -site:${site}`;
        }
        Qt.openUrlExternally(url);
        Mem.states.sidebarLauncher.behavior.expanded = false;
    }

    PointingHandInteraction {
    }

    contentItem: Item {
        anchors.centerIn: parent
        implicitWidth: rowLayout.implicitWidth
        implicitHeight: rowLayout.implicitHeight

        RowLayout {
            id: rowLayout

            anchors.centerIn: parent
            spacing: 5

            MaterialSymbol {
                text: "search"
                font.pixelSize: 20
                color: Colors.m3.m3onSurface
            }

            StyledText {
                id: text

                horizontalAlignment: Text.AlignHCenter
                text: root.query
                color: Colors.m3.m3onSurface
            }

        }

    }

}
