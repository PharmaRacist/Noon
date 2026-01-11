import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets

RippleButton {
    id: root

    Layout.alignment: Qt.AlignLeft
    implicitWidth: 40
    implicitHeight: 40
    Layout.leftMargin: 8
    onClicked: {
        parent.expanded = !parent.expanded;
    }
    buttonRadius: Rounding.full

    contentItem: Symbol {
        id: icon

        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 24
        color: Colors.colOnLayer1
        text: root.parent.expanded ? "menu_open" : "menu"
    }

}
