import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.common
import qs.common.widgets
import "../widgets"

Item {
    id: root
    property bool expanded: false
    anchors.fill: parent

    StyledFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: layout.implicitHeight
        clip: true

        GridLayout {
            id: layout
            z: 99
            columns: root.expanded ? 2 : 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Padding.normal

            rowSpacing: Padding.large
            columnSpacing: Padding.large

            Repeater {
                model: ["AllPrayers", "RandomAyah", "RandomZekr", "HijriDay", "FastingProgress"]
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
    }

}
