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
            subTitle: Mem.states.sidebar.widgets.enabled.length + " of " + root.db.length + " enabled"
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

                    delegate: StyledDelegateItem {
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: 72
                        Layout.fillWidth: true
                        colActiveColor: Colors.colPrimaryContainer
                        colActiveItemColor: Colors.colPrimary
                        title: modelData.component.replace(/_/g, " ")
                        subtext: {
                            let props = [];
                            if (modelData.expandable)
                                props.push("Expandable");
                            if (Mem.states.sidebar.widgets.pilled.indexOf(modelData.id) !== -1)
                                props.push("Pill");
                            else
                                props.push("Island");
                            if (Mem.states.sidebar.widgets.pinned.indexOf(modelData.id) !== -1)
                                props.push("Pinned");
                            if (Mem.states.sidebar.widgets.expanded.indexOf(modelData.id) !== -1)
                                props.push("Expanded");
                            return props.length > 0 ? props.join(" • ") : "Standard widget";
                        }
                        colSubtext: Colors.colSubtext
                        colTitle: Colors.colOnLayer2
                        materialIcon: modelData.materialIcon || "widgets"
                        enabled: Mem.states.sidebar.widgets.enabled.indexOf(modelData.id) === -1
                        opacity: Mem.states.sidebar.widgets.enabled.indexOf(modelData.id) !== -1 ? 0.5 : 1

                        onClicked: {
                            let list = Mem.states.sidebar.widgets.enabled;
                            let idx = list.indexOf(modelData.id);
                            if (idx === -1) {
                                list.push(modelData.id);
                                Mem.states.sidebar.widgets.enabled = list.slice();
                            }
                        }
                    }
                }
            }
        }

        Spacer {}
    }
}
