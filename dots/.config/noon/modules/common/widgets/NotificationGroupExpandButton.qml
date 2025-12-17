import qs.modules.common
import qs.services
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

RippleButton { // Expand button
    id: root
    required property int count
    required property bool expanded
    property real fontSize: Fonts.sizes.small ?? 12
    property real iconSize: Fonts.sizes.normal ?? 16
    implicitHeight: fontSize + 4 * 2
    implicitWidth: Math.max(contentItem.implicitWidth + 5 * 2, 30)
    Layout.alignment: Qt.AlignVCenter
    Layout.fillHeight: false

    buttonRadius: Rounding.full
    colBackground: ColorUtils.mix(Colors.colLayer2, Colors.colLayer2Hover, 0.5)
    colBackgroundHover: Colors.colLayer2Hover ?? "#E5DFED"
    colRipple: Colors.colLayer2Active ?? "#D6CEE2"

    contentItem: Item {
        anchors.centerIn: parent
        implicitWidth: contentRow.implicitWidth
        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 3
            StyledText {
                Layout.leftMargin: 4
                visible: root.count > 1
                text: root.count
                font.pixelSize: root.fontSize
            }
            MaterialSymbol {
                text: "keyboard_arrow_down"
                font.pixelSize: root.iconSize
                color: Colors.colOnLayer2
                rotation: expanded ? 180 : 0
                Behavior on rotation {
                    FAnim {}
                }
            }
        }
    }
}
