import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

Item {
    id: root
    property bool verticalMode: false
    property bool expanded: mouseArea.containsMouse
    property alias text: text.text
    property alias icon: icon.text
    property Component popup

    Layout.fillWidth: verticalMode
    Layout.fillHeight: !verticalMode
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    implicitHeight: verticalMode ? content.implicitHeight + Padding.large : parent.height
    width: verticalMode ? parent.width : content.implicitWidth + Padding.normal

    Loader {
        active: popup ? popup : null
        sourceComponent: popup ? popup : null
        onLoaded: if (item !== null)
            item.hoverTarget = Qt.binding(() => mouseArea)
    }

    MouseArea {
        id: mouseArea
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: expanded = !expanded
        hoverEnabled: true
    }

    GridLayout {
        id: content

        anchors.centerIn: parent
        rows: verticalMode ? 2 : 1
        columns: verticalMode ? 1 : 2
        rowSpacing: Padding.tiny
        columnSpacing: Padding.tiny

        Symbol {
            id: icon
            fill: 1
            font.pixelSize: Math.round(root.width / 3)
            color: Colors.colOnLayer1
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Revealer {
            id: revealer

            reveal: root.containsMouse || root.expanded
            vertical: root.verticalMode
            Layout.alignment: Qt.AlignHCenter

            StyledText {
                id: text
                visible: parent.reveal
                anchors.centerIn: parent
                font.pixelSize: verticalMode ? Fonts.sizes.small : Fonts.sizes.normal
                color: Colors.colOnLayer1
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
