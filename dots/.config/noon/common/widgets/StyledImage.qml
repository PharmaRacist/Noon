import QtQuick
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

Image {
    asynchronous: true
    retainWhileLoading: true
    visible: opacity > 0
    opacity: (status === Image.Ready) ? 1 : 0

    Behavior on opacity {
        Anim {
        }

    }

}
