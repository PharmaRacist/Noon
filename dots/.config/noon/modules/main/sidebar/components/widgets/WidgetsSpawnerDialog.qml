import QtQuick
import QtQuick.Controls
import qs.common
import qs.store
import qs.common.widgets
import QtQuick.Layouts

BottomDialog {
    id: root
    required property var db
    collapsedHeight: 650
    enableStagedReveal: false
    bottomAreaReveal: true
    hoverHeight: 200
    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Padding.verylarge
        spacing: Padding.normal

        BottomDialogHeader {
            title: "Islands"
            subTitle: root.db.filter(item => item.enabled).length + " of " + root.db.length + " enabled"
            target: root
        }

        BottomDialogSeparator {}

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: Padding.normal

                Repeater {
                    id: dialogRepeater
                    model: root.db
                    Layout.fillWidth: true
                    delegate: StyledDelegateItem {
                        Layout.fillWidth: true
                        colActiveColor: Colors.colPrimaryContainer
                        colActiveItemColor: Colors.colPrimary
                        title: modelData.component.replace(/_/g, " ")
                        subtext: {
                            let props = [];
                            if (modelData.expandable)
                                props.push("Expandable");
                            if (modelData.pill)
                                props.push("Pill");
                            return props.length > 0 ? props.join(" • ") : "Standard widget";
                        }
                        colSubtext: Colors.colSubtext
                        colTitle: Colors.colOnLayer2
                        materialIcon: modelData.pill ? "tablet" : "grid_view"
                        implicitHeight: 64
                        enabled: !root.db[index].enabled
                        opacity: root.db[index].enabled ? 0.5 : 1

                        onClicked: {
                            if (!root.db[index].enabled) {
                                root.db[index].enabled = true;
                                let item = widgetRepeater.itemAt(index);
                                if (item) {
                                    item.active = true;
                                }
                                Qt.callLater(root.arrangeAll);
                                dialogRepeater.model = root.db.slice();
                            }
                        }
                    }
                }
            }
        }
        Spacer {}
    }
}
