import Noon
import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

StyledPopup {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        StyledText {
            text: "System Resources"
            color: Colors.m3.m3onSurface
            font.pixelSize: Fonts.sizes.large
            font.weight: Font.Bold
            Layout.bottomMargin: 8
        }

        Repeater {
            model: [
                {
                    label: "CPU Usage",
                    value: `${ResourcesService.stats.cpu_percent.toFixed(1)}%`
                },
                {
                    label: "CPU Temp",
                    value: `${ResourcesService.stats.cpu_temp.toFixed(1)} °C`
                },
                {
                    label: "CPU Clock",
                    value: `${ResourcesService.stats.cpu_freq_ghz.toFixed(2)} GHz`
                },
                {
                    label: "Memory",
                    value: (() => {
                            let used = ResourcesService.stats.mem_total - ResourcesService.stats.mem_available;
                            let pct = (used / ResourcesService.stats.mem_total) * 100;
                            return `${pct.toFixed(1)}% (${(used / 1073741824).toFixed(1)}G / ${(ResourcesService.stats.mem_total / 1073741824).toFixed(1)}G)`;
                        })()
                }
            ]

            delegate: RowLayout {
                Layout.fillWidth: true

                StyledText {
                    text: modelData.label
                    color: Colors.m3.m3onSurfaceVariant
                    font.pixelSize: Fonts.sizes.normal
                    font.weight: Font.Medium
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: modelData.value
                    color: Colors.m3.m3primary
                    font.pixelSize: Fonts.sizes.normal
                    font.weight: Font.DemiBold
                }
            }
        }

        Repeater {
            model: ResourcesService.stats.gpus
            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.m3.m3outlineVariant
                    opacity: 0.2
                    Layout.topMargin: 10
                    Layout.bottomMargin: 4
                }

                StyledText {
                    text: modelData.name.toUpperCase()
                    color: Colors.m3.m3onSurfaceVariant
                    font.pixelSize: Fonts.sizes.small
                    font.weight: Font.Black
                    font.letterSpacing: 1.1
                    opacity: 0.8
                }

                Repeater {
                    model: [
                        {
                            l: "Utilization",
                            v: `${modelData.utilization.toFixed(1)}%`,
                            vis: true
                        },
                        {
                            l: "Temperature",
                            v: `${modelData.temperature.toFixed(1)} °C`,
                            vis: modelData.temperature > 0
                        },
                        {
                            l: "VRAM",
                            v: `${((modelData.memory_used / modelData.memory_total) * 100).toFixed(1)}%`,
                            vis: modelData.memory_total > 1
                        },
                        {
                            l: "Power",
                            v: `${modelData.power_draw.toFixed(1)}W`,
                            vis: modelData.power_draw > 0
                        }
                    ]
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        visible: modelData.vis

                        StyledText {
                            text: modelData.l
                            color: Colors.m3.m3onSurfaceVariant
                            font.pixelSize: Fonts.sizes.small
                            opacity: 0.7
                        }
                        StyledText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            text: modelData.v
                            color: Colors.m3.m3onSurface
                            font.pixelSize: Fonts.sizes.small
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }
    }
}
