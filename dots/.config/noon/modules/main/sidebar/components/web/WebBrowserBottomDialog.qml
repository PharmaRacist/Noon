import qs.services
import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

BottomDialog {
    id: root
    property string url: ""
    expandedHeight: 150
    collapsedHeight: parent.height * 0.5
    show: GlobalStates.main.dialogs.showWifiDialog
    enableStagedReveal: true
    bottomAreaReveal: true
    hoverHeight: 120
    contentItem: Item {
        clip: true
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Padding.normal
            spacing: Padding.large
            clip: true
            StyledTextField {
                id: inputArea
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: Rounding.verylarge
                onTextChanged: root.url = text
                onAccepted: root.url = text
            }
            Spacer {}
            StyledListView {
                visible: false
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: FirefoxBookmarksService.bookmarks
                delegate: StyledDelegateItem {
                    required property var modelData
                }
            }
        }
    }
    enableShadows: true
}
