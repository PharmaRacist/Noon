pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.common

Singleton {
    id: root
    readonly property color colLayer0: "#070707"
    readonly property color colLayer0Hover: Qt.lighter(colLayer0, 3)
    readonly property color colOnLayer0: "#F1F1F1"
    readonly property color colLayer0Active: Qt.darker(colLayer0Hover, 2)
    readonly property color colLayer3: "#FEFEFE"
    readonly property color colOnLayer3: "#070707"
    readonly property color colLayer3Hover: Qt.lighter(colLayer3, 3)
    readonly property color colLayer3Active: Qt.darker(colLayer3Hover, 2)

    readonly property color colPrimary: "#E85720"
    readonly property color colSubtext: "#818181"
    readonly property color colSecondary: "#F0F0F0"
}
