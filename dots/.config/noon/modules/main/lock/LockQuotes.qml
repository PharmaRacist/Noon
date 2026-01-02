import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

StyledText {
    id: root

    z: 999
    text: `${QuotesService.text}\n${QuotesService.author}`
    color: Colors.colOnLayer0

    font {
        variableAxes: Fonts.variableAxes.display
        pixelSize: Fonts.sizes.subTitle
        family: Fonts.family.reading
    }

    anchors {
        margins: Padding.massive
        top: parent.top
        right: parent.right
    }

    Timer {
        interval: 600000
        running: true
        repeat: true
        onTriggered: QuotesService.refresh()
    }

}
