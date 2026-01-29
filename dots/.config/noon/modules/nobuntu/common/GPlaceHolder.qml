import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

ColumnLayout {
    property bool shown: true
    property alias icon: icon._source
    property alias title: title.text
    property alias description: description.text

    opacity: shown ? 1 : 0
    visible: opacity > 0
    spacing: Padding.huge

    StyledIconImage {
        id: icon
        implicitSize: 100
        tintColor: Colors.colSubtext
        Layout.alignment: Qt.AlignCenter
        colorize: true
        tint: 0
    }
    StyledText {
        id: title
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        font {
            pixelSize: Fonts.sizes.small
            variableAxes: Fonts.variableAxes.title
            weight: Font.DemiBold
        }
        truncate: true
        color: Colors.colSubtext
    }
    StyledText {
        id: description
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        font {
            pixelSize: Fonts.sizes.verysmall
            variableAxes: Fonts.variableAxes.main
        }
        truncate: true
        opacity: 0.75
        color: Colors.colSecondary
    }
    Behavior on opacity {
        Anim {}
    }
}
