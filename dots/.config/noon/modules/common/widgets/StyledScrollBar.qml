import QtQuick
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.functions

ScrollBar {
    id: root

    policy: ScrollBar.AsNeeded
    topPadding: Rounding.normal
    bottomPadding: Rounding.normal

    contentItem: Rectangle {
        implicitWidth: 4
        implicitHeight: root.visualSize
        radius: width / 2
        color: Colors.colLayer2Hover
        opacity: root.policy === ScrollBar.AlwaysOn || (root.active && root.size < 1) ? 0.5 : 0

        Behavior on opacity {
            Anim {
            }

        }

    }

}
