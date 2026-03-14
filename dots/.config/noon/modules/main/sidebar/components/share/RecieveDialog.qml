import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.services

BottomDialog {
    id: root
    collapsedHeight: 170
    revealOnWheel: false
    enableStagedReveal: false
    bottomAreaReveal: false
    color: Colors.colLayer2

    contentItem: CLayout {
        anchors.fill: parent
        anchors.margins: Padding.huge

        BottomDialogHeader {
            title: "Receive Request"
            subTitle: "PIN: " + QuickShareService.pendingTransfer.pin
            target: root
        }

        RLayout {
            Layout.fillWidth: true
            OptionButton {
                materialIcon: "check"
                label: "Accept"
                toggled: true
                downAction: () => {
                    QuickShareService.acceptTransfer();
                    setStatus("Accepting transfer…");
                }
            }

            OptionButton {
                materialIcon: "close"
                label: "Decline"
                downAction: () => {
                    QuickShareService.rejectTransfer();
                    setStatus("Transfer rejected.");
                }
            }
        }
        Spacer {}
    }
}
