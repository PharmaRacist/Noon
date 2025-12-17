import "../"
import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.sidebarLauncher.components.notifs.calendar
import qs.services

StyledPopup {
    CalendarWidget {
        anchors.centerIn: parent
    }
}
