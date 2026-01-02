import "../common"
import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

StyledText {
    id: root

    text: DateTimeService.hour + ":" + DateTimeService.minute

    font {
        family: XFonts.family.title
        pixelSize: XFonts.sizes.normal
        weight: 500
    }

}
