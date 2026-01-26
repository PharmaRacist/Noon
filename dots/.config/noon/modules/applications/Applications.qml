import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import "mediaplayer"
import "editor"
import "reader"
import "settings"

Scope {
    Settings {}
    WidgetLoader {
        active: GlobalStates.applications.mediaplayer.show
        MediaPlayer {}
    }
    WidgetLoader {
        active: GlobalStates.applications.reader.show
        PDFReader {}
    }
    WidgetLoader {
        active: GlobalStates.applications.editor.show
        Editor {}
    }
    IPC {}
}
