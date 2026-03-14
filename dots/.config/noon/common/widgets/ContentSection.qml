import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets

ColumnLayout {
    id: root

    property string title
    default property alias data: sectionContent.data

    Layout.fillWidth: true
    spacing: 8

    StyledText {
        text: root.title
        font.pixelSize: Fonts.sizes.verylarge
    }

    ColumnLayout {
        id: sectionContent

        spacing: 4
    }

}
