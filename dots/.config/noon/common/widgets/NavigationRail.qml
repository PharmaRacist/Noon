import QtQuick
import QtQuick.Layouts
import qs.common

ColumnLayout {
    id: root

    property bool expanded: false
    property int currentIndex: 0

    Behavior on spacing {
        Anim {}
    }
}
