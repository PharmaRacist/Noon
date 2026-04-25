import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: bg
    z: 9999
    clip: true
    property bool _expanded: false
    property alias inputArea: inputArea
    anchors.margins: Padding.huge
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter

    radius: Rounding.huge
    color: Colors.m3.m3surfaceContainerHighest

    Anim on anchors.bottomMargin {
        from: -height - anchors.margins
        to: anchors.margins
        duration: 600
    }

    states: [
        State {
            name: "expanded"
            when: _expanded

            PropertyChanges {
                target: bg
                width: parent?.width - (anchors.margins * 2)
                height: 140
            }
        },
        State {
            name: "collapsed"
            when: !_expanded

            PropertyChanges {
                target: bg
                width: root.isSearching ? 320 : group?.contentWidth
                height: 65
            }
        }
    ]

    transitions: Transition {
        Anim {
            properties: "width,height,x,y,opacity"
        }
    }

    ColumnLayout {
        visible: bg._expanded
        anchors.bottom: group.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: Padding.huge
        anchors.rightMargin: Padding.huge
        spacing: Padding.large

        OptionSpin {
            title: "Search Limit"
            spin.value: Mem.states.services.beats.searchLimit
            spin.from: 16
            spin.to: 1000
            spin.onValueChanged: if (spin.value > 0) {
                Mem.states.services.beats.searchLimit = spin.value;
            }
        }
        OptionSwitch {
            title: "Shuffle Hits"
            button.checked: Mem.states.services.beats.shuffleHits
            button.onCheckedChanged: () => Mem.states.services.beats.shuffleHits = button.checked
        }
    }

    ButtonGroup {
        id: group

        height: 60

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: Padding.small
        anchors.rightMargin: Padding.small

        StyledTextField {
            id: inputArea
            visible: root.isSearching
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            focus: true
            height: 60
            color: Colors.colOnLayer3
            Layout.fillWidth: visible
            background: null
            onAccepted: BeatsHitsService.search(inputArea.text)
        }
        Repeater {
            model: [
                {
                    toggled: root.isSearching,
                    icon: "search",
                    action: () => {
                        root.isSearching = !root.isSearching;
                    }
                },
                {
                    icon: "refresh",
                    action: () => {
                        root.isSearching = false;
                        BeatsHitsService.refresh();
                    }
                },
                {
                    icon: "menu",
                    action: () => {
                        root.isSearching = !root.isSearching;
                        bg._expanded = !bg._expanded;
                    }
                }
            ]
            delegate: GroupButtonWithIcon {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.fillHeight: false
                Layout.fillWidth: false
                toggled: modelData?.toggled ?? false
                baseSize: 55
                materialIcon: modelData.icon
                releaseAction: () => modelData.action()
            }
        }
    }
    component OptionSwitch: RowLayout {
        property alias title: title.text
        property var key
        property alias button: button
        StyledText {
            id: title
            color: Colors.colOnLayer3
            font.pixelSize: Fonts.sizes.small
            Layout.fillWidth: true
        }
        StyledSwitch {
            id: button
        }
    }
    component OptionSpin: RowLayout {
        property alias title: title.text
        property var key
        property alias spin: spin
        StyledText {
            id: title
            color: Colors.colOnLayer3
            font.pixelSize: Fonts.sizes.small
            Layout.fillWidth: true
        }
        StyledSpinBox {
            id: spin
        }
    }
}
