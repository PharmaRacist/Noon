import QtQuick.Layouts
import QtQuick
import qs.common
import qs.common.widgets
import qs.services
import Quickshell

StyledRect {
    id: root
    enabled: true

    property string icon: ""
    property string name: ""
    property string key: ""
    property string hint: ""
    property string type: "switch"
    property string actionName: ""
    property bool reloadOnChange: false
    property bool useStates: false
    property QtObject colors: Colors
    readonly property alias component: mainLoader._item
    property int minValue: 0
    property int maxValue: 100
    property real sliderMinValue: 0
    property real sliderMaxValue: 1
    property var comboBoxValues: []
    property bool fillHeight: false
    property string textPlaceholder: "text"

    signal valueChanged(var newValue)
    signal clicked

    readonly property var typeMap: ({
            "spin": {
                source: "StyledSpinBox",
                isActive: () => getConfigValue() > minValue
            },
            "slider": {
                source: "StyledSlider",
                isActive: () => getConfigValue() > sliderMinValue,
                width: 120
            },
            "combobox": {
                source: "StyledComboBox",
                width: 165
            },
            "text": {
                source: "MaterialTextField",
                width: 165
            },
            "field": {
                source: "MaterialTextField",
                fillWidth: true
            },
            "switch": {
                source: "StyledSwitch"
            },
            "font": {
                source: "StyledFontSelector"
            },
            "action": {
                source: "ActionButton"
            }
        })

    readonly property var currentType: typeMap[type] ?? typeMap["switch"]
    readonly property bool isActive: currentType.isActive ? currentType.isActive() : Boolean(getConfigValue())
    readonly property bool hideTitle: type === "field"

    Layout.fillWidth: true
    Layout.fillHeight: fillHeight
    Layout.preferredHeight: (fillHeight && component) ? component.implicitHeight + 2 * Padding.normal : 65

    color: {
        if (!enabled)
            return colors.colLayer2Disabled;
        if (mouseArea.pressed)
            return colors.colLayer2Active;
        if (mouseArea.containsMouse)
            return colors.colLayer2Hover;
        return colors.colLayer2;
    }

    function getConfigValue() {
        if (key === "" || !Mem)
            return undefined;
        return key.split('.').reduce((cur, k) => cur?.[k], useStates ? Mem.states : Mem.options);
    }

    function setConfigValue(value) {
        if (key === "" || !Mem)
            return;
        const parts = key.split('.');
        const target = parts.slice(0, -1).reduce((cur, k) => {
            if (!cur[k])
                cur[k] = {};
            return cur[k];
        }, useStates ? Mem.states : Mem.options);
        target[parts[parts.length - 1]] = value;
        valueChanged(value);
        if (reloadOnChange)
            NoonUtils.requestDialog("assure", {
                title: "Restart",
                description: "For changes to take Effect",
                acceptText: "Accept",
                onAccepted: () => NoonUtils.execDetached(Directories.scriptsDir + "/reload_shell.sh")
            });
    }

    function applyToItem(val) {
        if (!component)
            return;
        if ("checked" in component)
            component.checked = Boolean(val);
        if ("value" in component)
            component.value = val;
        if ("text" in component)
            component.text = String(val ?? "");
        if ("currentIndex" in component)
            component.currentIndex = Math.max(0, comboBoxValues.findIndex(v => (v?.name ?? v) === val));
    }

    onValueChanged: val => applyToItem(val)

    Connections {
        target: mainLoader._item
        ignoreUnknownSignals: true
        function onMoved() {
            root.setConfigValue(mainLoader._item.value);
        }
        function onValueChanged() {
            root.setConfigValue(mainLoader._item.value);
        }
        function onCurrentIndexChanged() {
            const val = root.comboBoxValues[mainLoader._item.currentIndex];
            root.setConfigValue(val?.name ?? val ?? "");
        }
        function onEditingFinished() {
            root.setConfigValue(mainLoader._item.text);
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled && type === "switch"
        onClicked: {
            setConfigValue(!getConfigValue());
            root.clicked();
            iconAnimation.start();
        }
        onPressed: feedbackAnimation.start()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Padding.small
        anchors.leftMargin: Padding.large
        anchors.rightMargin: Padding.large
        spacing: Padding.huge

        StyledRect {
            visible: !root.hideTitle
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
            radius: Rounding.full
            color: root.isActive ? colors.colPrimary : colors.colLayer3

            Symbol {
                id: iconSymbol
                fill: 1
                font.pixelSize: 18
                text: root.icon
                color: root.isActive ? colors.colOnPrimary : colors.colOnLayer3
                anchors.centerIn: parent
                Behavior on color {
                    CAnim {}
                }

                SequentialAnimation {
                    id: iconAnimation
                    running: false
                    RotationAnimator {
                        target: iconSymbol
                        from: 0
                        to: 360
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

        StyledText {
            visible: !root.hideTitle
            text: root.name
            color: colors.colOnLayer2
            font.pixelSize: Fonts.sizes.normal
            truncate: true
            Layout.fillWidth: true
        }

        StyledLoader {
            id: mainLoader
            source: sanitizeSource("", root.currentType.source)
            Layout.fillWidth: root.currentType.fillWidth ?? false
            Layout.minimumWidth: root.currentType.width ?? 0
            Layout.fillHeight: root.fillHeight
            onLoaded: if (ready) {
                if ("enabled" in item)
                    item.enabled = root.enabled;
                if ("from" in item)
                    item.from = root.type === "spin" ? root.minValue : root.sliderMinValue;
                if ("to" in item)
                    item.to = root.type === "spin" ? root.maxValue : root.sliderMaxValue;
                if ("model" in item)
                    item.model = root.comboBoxValues;
                if ("placeholderText" in item)
                    item.placeholderText = root.textPlaceholder;
                root.applyToItem(root.getConfigValue());
            }
        }
    }

    SequentialAnimation {
        id: feedbackAnimation
        ScaleAnimator {
            target: root
            from: 1
            to: 0.98
            duration: 50
        }
        ScaleAnimator {
            target: root
            from: 0.98
            to: 1
            duration: 100
        }
    }
}
