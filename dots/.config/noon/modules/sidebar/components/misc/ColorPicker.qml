import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.modules.common

Item {
    // readonly property color onPrimaryContainer: "#21005d"

    id: root

    // Material 3 colors
    readonly property color surfaceContainer: "#f3edf7"
    readonly property color surfaceContainerHigh: "#ece6f0"
    readonly property color onSurface: "#1d1b20"
    readonly property color onSurfaceVariant: "#49454f"
    readonly property color outline: "#79747e"
    readonly property color primaryContainer: "#eaddff"

    width: parent.width
    height: 280

    // Color selection state
    QtObject {
        id: selectedColor

        property real hue: 0
        property real saturation: 100
        property real lightness: 50

        function hslToRgb(h, s, l) {
            s /= 100;
            l /= 100;
            let c = (1 - Math.abs(2 * l - 1)) * s;
            let x = c * (1 - Math.abs((h / 60) % 2 - 1));
            let m = l - c / 2;
            let r = 0, g = 0, b = 0;
            if (h >= 0 && h < 60) {
                r = c;
                g = x;
                b = 0;
            } else if (h >= 60 && h < 120) {
                r = x;
                g = c;
                b = 0;
            } else if (h >= 120 && h < 180) {
                r = 0;
                g = c;
                b = x;
            } else if (h >= 180 && h < 240) {
                r = 0;
                g = x;
                b = c;
            } else if (h >= 240 && h < 300) {
                r = x;
                g = 0;
                b = c;
            } else if (h >= 300 && h < 360) {
                r = c;
                g = 0;
                b = x;
            }
            return {
                "r": Math.round((r + m) * 255),
                "g": Math.round((g + m) * 255),
                "b": Math.round((b + m) * 255)
            };
        }

        function toHex() {
            let adjustedL = lightness / (1 + saturation / 100);
            let rgb = hslToRgb(hue, saturation, adjustedL);
            return "#" + ("0" + rgb.r.toString(16)).slice(-2) + ("0" + rgb.g.toString(16)).slice(-2) + ("0" + rgb.b.toString(16)).slice(-2);
        }

        function toRgbString() {
            let adjustedL = lightness / (1 + saturation / 100);
            let rgb = hslToRgb(hue, saturation, adjustedL);
            return rgb.r + ", " + rgb.g + ", " + rgb.b;
        }

        function toHslString() {
            let adjustedL = Math.round(lightness / (1 + saturation / 100));
            return hue + ", " + saturation + "%, " + adjustedL + "%";
        }

        function shouldUseBlackText() {
            return ((saturation < 40 || (45 <= hue && hue <= 195)) && lightness > 60);
        }

    }

    Rectangle {
        anchors.fill: parent
        color: Colors.colLayer1
        radius: Rounding.normal

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Hue selector
            Item {
                Layout.preferredWidth: 32
                Layout.fillHeight: true

                Rectangle {
                    id: hueGradient

                    anchors.fill: parent
                    radius: Rounding.normal

                    Rectangle {
                        id: hueSlider

                        width: parent.width + 4
                        height: 4
                        radius: Rounding.unSharpen
                        color: "transparent"
                        x: -2
                        y: (selectedColor.hue / 360) * (parent.height - height)
                        layer.enabled: true

                        layer.effect: ShaderEffect {
                            property color shadowColor: "#40000000"

                            fragmentShader: "
                                varying highp vec2 qt_TexCoord0;
                                uniform sampler2D source;
                                uniform lowp vec4 shadowColor;
                                uniform lowp float qt_Opacity;
                                void main() {
                                    lowp vec4 tex = texture2D(source, qt_TexCoord0);
                                    gl_FragColor = tex * qt_Opacity;
                                }
                            "
                        }

                    }

                    MouseArea {
                        function updateHue(mouse) {
                            let newHue = Math.max(0, Math.min(1, mouse.y / height)) * 360;
                            selectedColor.hue = Math.round(newHue);
                        }

                        anchors.fill: parent
                        onPressed: updateHue(mouse)
                        onPositionChanged: {
                            if (pressed)
                                updateHue(mouse);

                        }
                    }

                    gradient: Gradient {
                        GradientStop {
                            position: 0
                            color: "#ff6666"
                        }

                        GradientStop {
                            position: 0.167
                            color: "#ffff66"
                        }

                        GradientStop {
                            position: 0.333
                            color: "#66dd66"
                        }

                        GradientStop {
                            position: 0.5
                            color: "#66ffff"
                        }

                        GradientStop {
                            position: 0.667
                            color: "#6666ff"
                        }

                        GradientStop {
                            position: 0.833
                            color: "#ff66ff"
                        }

                        GradientStop {
                            position: 1
                            color: "#ff6666"
                        }

                    }

                }

            }

            // Saturation and Lightness selector
            Item {
                Layout.preferredWidth: 240
                Layout.fillHeight: true

                Rectangle {
                    id: slGradient

                    anchors.fill: parent
                    radius: Rounding.normal
                    color: Qt.hsla(selectedColor.hue / 360, 1, 0.5, 1)

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius

                        gradient: Gradient {
                            orientation: Gradient.Horizontal

                            GradientStop {
                                position: 0
                                color: "white"
                            }

                            GradientStop {
                                position: 1
                                color: "transparent"
                            }

                        }

                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius

                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: "transparent"
                            }

                            GradientStop {
                                position: 1
                                color: "black"
                            }

                        }

                    }

                    Rectangle {
                        id: slCursor

                        width: 16
                        height: 16
                        radius: Rounding.small
                        color: "transparent"
                        border.color: "white"
                        border.width: 2
                        x: (selectedColor.saturation / 100) * (parent.width - width)
                        y: ((100 - selectedColor.lightness) / 100) * (parent.height - height)
                        layer.enabled: true

                        Rectangle {
                            anchors.centerIn: parent
                            width: 8
                            height: 8
                            radius: Rounding.small
                            color: selectedColor.toHex()
                        }

                        layer.effect: ShaderEffect {
                            property color shadowColor: "#60000000"
                        }

                    }

                    MouseArea {
                        function updateSL(mouse) {
                            let newSat = Math.max(0, Math.min(1, mouse.x / width)) * 100;
                            let newLight = 100 - Math.max(0, Math.min(1, mouse.y / height)) * 100;
                            selectedColor.saturation = Math.round(newSat);
                            selectedColor.lightness = Math.round(newLight);
                        }

                        anchors.fill: parent
                        onPressed: updateSL(mouse)
                        onPositionChanged: {
                            if (pressed)
                                updateSL(mouse);

                        }
                    }

                }

            }

            // Result area
            ColumnLayout {
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: Rounding.small
                    color: selectedColor.toHex()

                    Text {
                        anchors.centerIn: parent
                        text: "●"
                        font.pixelSize: 32
                        color: selectedColor.shouldUseBlackText() ? "#1d1b20" : "#ffffff"
                    }

                }

                ResultBox {
                    Layout.fillWidth: true
                    label: "HEX"
                    value: selectedColor.toHex()
                    onCopyClicked: {
                        Quickshell.execDetached("wl-copy", [selectedColor.toHex()]);
                    }
                }

                ResultBox {
                    Layout.fillWidth: true
                    label: "RGB"
                    value: selectedColor.toRgbString()
                    onCopyClicked: {
                        Quickshell.execDetached("wl-copy", ["rgb(" + selectedColor.toRgbString() + ")"]);
                    }
                }

                ResultBox {
                    Layout.fillWidth: true
                    label: "HSL"
                    value: selectedColor.toHslString()
                    onCopyClicked: {
                        Quickshell.execDetached("wl-copy", ["hsl(" + selectedColor.toHslString() + ")"]);
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

            }

        }

    }

    component ResultBox: ColumnLayout {
        property string label
        property string value

        signal copyClicked()

        spacing: 4

        Text {
            Layout.leftMargin: 8
            text: label
            font.pixelSize: 11
            font.weight: Font.Medium
            color: onSurfaceVariant
            font.capitalization: Font.AllUppercase
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            radius: Rounding.small
            color: Colors.colLayer2

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                width: 80
                text: value
                font.pixelSize: Fonts.sizes.normal
                font.family: Fonts.family.monospace
                color: Colors.colOnLayer2
                elide: Text.ElideRight
            }

        }

    }

}
