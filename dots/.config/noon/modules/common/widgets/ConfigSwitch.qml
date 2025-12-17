import qs.modules.common.widgets
import qs.modules.common
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RippleButton {
    id: root
    Layout.fillWidth: true

    contentItem: RowLayout {
        spacing: 10
        StyledText {
            id: labelWidget
            Layout.fillWidth: true
            text: root.text
            font.pixelSize: Fonts.sizes.normal
            color: Colors.colOnSecondaryContainer
        }
        StyledSwitch {
            id: switchWidget
            down: root.down
            scale: 0.75
            Layout.fillWidth: false
            checked: root.checked
            onClicked: root.clicked()
        }
    }
}
