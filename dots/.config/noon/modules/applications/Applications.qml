import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import "mediaplayer"

Scope {
    WidgetLoader {
        enabled: GlobalStates.applications.mediaplayer.show
        MediaPlayer {}
    }
    IPC {}
}
