pragma Singleton
import QtQuick
import Quickshell
import qs.modules.common.appearance

Singleton {
    id: root
    readonly property QtObject colors: Colors {}
    readonly property QtObject fonts: Fonts {}
    readonly property QtObject anim: Animations {}
    readonly property QtObject rounding: Rounding {}
    readonly property QtObject padding: Padding {}
    readonly property QtObject sizes: Sizes {}
    readonly property QtObject transparency: Transparency {}
}
