import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import "mediaplayer"
import "editor"

Scope {
    WidgetLoader {
        enabled: GlobalStates.applications.mediaplayer.show
        MediaPlayer {}
    }
    WidgetLoader {
        enabled: GlobalStates.applications.editor.show
        Editor {}
    }
    IPC {}
}
