pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.common.utils
import qs.common.functions
import qs.common.widgets
import qs.services
import Noon.Utils.Download

Singleton {
    property alias model: downloadModel

    DownloadModel {
        id: downloadModel
        jsonPath: Directories.standard.state + "/downloads.json"
    }
}
