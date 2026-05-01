import qs.common
import qs.common.widgets
import QtQuick

MaterialLoadingIndicator {
    id: root

    property var messageData
    property int blockCount: 0

    visible: loading
    loading: blockCount === 0 && !(messageData?.done ?? false) && !(messageData?.queued ?? false)
    anchors.left: parent.left
    anchors.leftMargin: Padding.huge
}
