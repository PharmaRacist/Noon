pragma Singleton
pragma ComponentBehavior: Bound

import Noon.Utils
import QtQuick
import Quickshell
import qs.common
import qs.services

/*
    Nice Wrapper for the HyprParser
    - TODO: Create Properties Binding

*/

Singleton {
    id: root

    readonly property alias variables: parser.variables
    readonly property alias parser: parser

    HyprParser {
        id: parser
        path: Qt.resolvedUrl(Directories.hyprConfigs + "/variables.conf")
    }
}
