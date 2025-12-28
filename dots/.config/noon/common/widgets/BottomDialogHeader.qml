import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets

RowLayout {
    id: root

    property alias title: titleArea.text
    property alias subTitle: subTitleArea.text
    property QtObject colors: Colors
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
            color: root.colors.colOnLayer2
        }

        StyledText {
            id: subTitleArea

            font.pixelSize: Fonts.sizes.normal
            color: root.colors.colSubtext
        }

    }

    Item {
        Layout.fillWidth: true
    }

}
