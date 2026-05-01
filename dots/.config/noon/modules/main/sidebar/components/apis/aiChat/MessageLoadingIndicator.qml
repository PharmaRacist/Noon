import qs.common
import qs.common.widgets
import QtQuick

Item {
    property var messageData
    property int blockCount: 0
    property bool loading: blockCount === 0 && !(messageData?.done ?? false) && !(messageData?.queued ?? false)
    anchors.left: parent.left
    implicitHeight: 40
    implicitWidth: 40
    Rectangle {
        Anim on width {
            running: loading
            duration: 1200
            easing.type: Easing.InOutCirc
            loops: Animation.Infinite
            from: 10
            to: 20
        }
        height: width
        anchors.centerIn: parent
        radius: Rounding.full
        color: Colors.colOnSurface
        visible: loading
    }
}
