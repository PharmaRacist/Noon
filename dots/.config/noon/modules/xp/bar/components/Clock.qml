import "../../common"
import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Text {
    id: root

    text: DateTimeService.time.toUpperCase()
    color: XColors.colors.colOnSecondary
    font {
        family: XFonts.family.title
        pixelSize: XFonts.sizes.normal
        weight: 500
    }
}
