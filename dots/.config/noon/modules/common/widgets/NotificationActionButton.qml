import qs.modules.common
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

RippleButton {
    id: button
    property string buttonText
    property string urgency

    implicitHeight: 30
    leftPadding: 15
    rightPadding: 15
    buttonRadius: Rounding.small
    colBackground: (urgency == NotificationUrgency.Critical) ? Colors.colSecondaryContainer : Colors.colSurfaceContainerHighest
    colBackgroundHover: (urgency == NotificationUrgency.Critical) ? Colors.colSecondaryContainerHover : Colors.colSurfaceContainerHighestHover
    colRipple: (urgency == NotificationUrgency.Critical) ? Colors.colSecondaryContainerActive : Colors.colSurfaceContainerHighestActive

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: (urgency == NotificationUrgency.Critical) ? Colors.m3.m3onSurfaceVariant : Colors.m3.m3onSurface
    }
}