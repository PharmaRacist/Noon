import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import "./../common"

GButtonWithIcon {
    Layout.fillWidth: true
    Layout.margins: Padding.small
    Layout.preferredHeight: width
    buttonRadius: Rounding.large
    iconSize: 40
    iconSource: "view-app-grid-symbolic"
    colBackground: "transparent"
    colBackgroundHover: Colors.colLayer0Hover
    colBackgroundActive: Colors.colLayer0Active
    onPressed: NoonUtils.callIpc("nobuntu toggle_overview")
}
