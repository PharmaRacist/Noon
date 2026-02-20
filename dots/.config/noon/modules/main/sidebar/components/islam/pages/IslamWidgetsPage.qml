import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.common
import qs.common.widgets
import "../widgets"

GridLayout {
    id: root
    z: 99
    property bool expanded: false
    columns: expanded ? 2 : 1
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: Padding.normal

    rowSpacing: Padding.large
    columnSpacing: Padding.large

    Repeater {
        model: ["AllPrayers", "RandomAyah", "RandomZekr"]
        delegate: StyledLoader {
            required property var modelData
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: _item?.implicitHeight || 0
            Layout.fillWidth: true
            asynchronous: true
            source: "../widgets/" + modelData + ".qml" || ""
        }
    }
    Spacer {}
}
