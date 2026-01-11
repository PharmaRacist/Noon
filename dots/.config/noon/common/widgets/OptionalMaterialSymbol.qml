import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets

Loader {
    id: root

    required property string icon
    property real iconSize: Fonts.sizes.verylarge

    Layout.alignment: Qt.AlignVCenter
    active: root.icon && root.icon.length > 0
    visible: active

    sourceComponent: Item {
        implicitWidth: materialSymbol.implicitWidth

        Symbol {
            id: materialSymbol

            anchors.centerIn: parent
            iconSize: root.iconSize
            color: root.toggled ? Colors.colOnPrimary : Colors.colOnSecondaryContainer
            text: root.icon
        }

    }

}
