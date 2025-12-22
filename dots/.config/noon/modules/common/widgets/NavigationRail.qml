import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

// Window content with navigation rail and content pane
ColumnLayout {
    id: root

    property bool expanded: false
    property int currentIndex: 0

    Behavior on spacing {
        Anim {
        }

    }

}
