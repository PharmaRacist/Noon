import QtQuick.Layouts
import qs.common
import qs.services
import qs.common.widgets

ColumnLayout {
    id:root

    Layout.fillWidth:true
    Layout.margins:Padding.verylarge

    spacing: Padding.small

    StyledText {
        font {
            variableAxes:Fonts.variableAxes.main
            pixelSize:Fonts.sizes.normal
            weight:700
        }
        truncate:true
        text:Qt.formatDateTime(DateTimeService.clock.date, "dddd")
        color:Colors.colSubtext
        opacity:0.65
    }
    StyledText {
        font {
            variableAxes:Fonts.variableAxes.title
            pixelSize:Fonts.sizes.huge
            weight:Font.Bold
        }
        truncate:true
        text:  Qt.formatDateTime(DateTimeService.clock.date, "MMMM dd yyyy")
        color:Colors.colOnLayer2
    }
}
