import QtQuick
import QtQuick.Layouts
import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Tag suggestion description
Item {
    id: root

    property alias text: tagDescriptionText.text
    property bool showArrows: true
    property bool showTab: true

    visible: tagDescriptionText.text.length > 0
    Layout.fillWidth: true
    implicitHeight: tagDescriptionBackground.implicitHeight

    Rectangle {
        id: tagDescriptionBackground

        color: Colors.colLayer2
        anchors.fill: parent
        radius: Rounding.verysmall
        implicitHeight: descriptionRow.implicitHeight + 5 * 2

        RowLayout {
            id: descriptionRow

            spacing: 4

            anchors {
                fill: parent
                leftMargin: 10
                rightMargin: 10
            }

            StyledText {
                id: tagDescriptionText

                Layout.fillWidth: true
                font.pixelSize: Fonts.sizes.verysmall
                color: Colors.colOnLayer2
                wrapMode: Text.Wrap
            }

            KeyboardKey {
                visible: root.showArrows
                key: "↑"
            }

            KeyboardKey {
                visible: root.showArrows
                key: "↓"
            }

            StyledText {
                visible: root.showArrows && root.showTab
                text: qsTr("or")
                font.pixelSize: Fonts.sizes.verysmall
            }

            KeyboardKey {
                id: tagDescriptionKey

                visible: root.showTab
                key: "Tab"
                Layout.alignment: Qt.AlignVCenter
            }

        }

    }

}
