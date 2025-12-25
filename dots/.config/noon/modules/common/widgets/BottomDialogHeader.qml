import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

RowLayout {
    id: root

    property alias title: titleArea.text
    property alias subTitle: subTitleArea.text

    Layout.fillWidth: true
    Layout.preferredHeight: 50
    Layout.margins: Padding.large

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Padding.small

        StyledText {
            id: titleArea

            font.pixelSize: Fonts.sizes.subTitle
            color: Colors.colOnLayer2
        }

        StyledText {
            id: subTitleArea

            font.pixelSize: Fonts.sizes.normal
            color: Colors.colSubtext
        }

    }

    Item {
        Layout.fillWidth: true
    }

}
