import QtQuick
import QtQuick.Layouts
import "dialogs"
import "notifications"
import qs.common
import qs.common.widgets

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: Padding.normal

        UpperWidgetGroup {}

        NotificationList {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    StyledLoader {
        anchors.fill: parent
        active: GlobalStates.main.dialogs.current.length > 0
        source: sanitizeSource("dialogs/", GlobalStates.main.dialogs.current.trim() + "Dialog")
        onSourceChanged: {
            console.log(source);
        }
        asynchronous: true
    }
}
