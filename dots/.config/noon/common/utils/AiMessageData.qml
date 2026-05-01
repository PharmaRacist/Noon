import QtQuick

QtObject {
    property string role
    property string content
    property string rawContent
    property string localFilePath
    property string model
    property bool thinking: true
    property bool queued: false
    property bool done: false
    property var files: []
    property var tools: []
    property var annotationSources: []
    property bool visibleToUser: true
}
