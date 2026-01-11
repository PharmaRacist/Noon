import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

StyledPopup {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        Row {
            spacing: 6

            Symbol {
                anchors.verticalCenter: parent.verticalCenter
                text: "memory"
                fill: 1
                font.pixelSize: Fonts.sizes.large
                color: Colors.m3.m3onSurfaceVariant
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                StyledText {
                    text: qsTr("System Resources")
                    color: Colors.m3.m3onSurfaceVariant
                    font.pixelSize: Fonts.sizes.large
                    font.weight: Font.Medium
                }

            }

        }

        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            Symbol {
                text: "speed"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("CPU Usage:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                font.weight: Font.Medium
                color: Colors.m3.m3onSurfaceVariant
                text: `${ResourcesService.stats.cpu_percent.toFixed(1)}%`
            }

        }

        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            Symbol {
                text: "device_thermostat"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("CPU Temp:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: `${ResourcesService.stats.cpu_temp.toFixed(1)} °C`
            }

        }

        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            Symbol {
                text: "speed"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("CPU Clock:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: `${ResourcesService.stats.cpu_freq_ghz.toFixed(2)} GHz`
            }

        }

        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            Symbol {
                text: "memory_alt"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Mem:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                property double memUsed: ResourcesService.stats.mem_total - ResourcesService.stats.mem_available
                property double memPercent: (memUsed / ResourcesService.stats.mem_total) * 100

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: `${memPercent.toFixed(1)}% (${(memUsed / 1073741824).toFixed(1)} / ${(ResourcesService.stats.mem_total / 1073741824).toFixed(1)} GB)`
            }

        }

        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: ResourcesService.stats.swap_total > 0

            Symbol {
                text: "sync_alt"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Swap:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                property double swapUsed: ResourcesService.stats.swap_total - ResourcesService.stats.swap_free
                property double swapPercent: (swapUsed / ResourcesService.stats.swap_total) * 100

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: `${swapPercent.toFixed(1)}% (${(swapUsed / 1073741824).toFixed(1)} / ${(ResourcesService.stats.swap_total / 1073741824).toFixed(1)} GB)`
            }

        }

        Repeater {
            model: ResourcesService.stats.gpus

            Column {
                spacing: 4
                Layout.fillWidth: true

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.m3.m3outlineVariant
                    opacity: 0.5
                }

                StyledText {
                    text: `GPU ${modelData.index}: ${modelData.name}`
                    color: Colors.m3.m3onSurfaceVariant
                    font.weight: Font.Medium
                    font.pixelSize: Fonts.sizes.normal
                }

                RowLayout {
                    spacing: 5
                    width: parent.width

                    Symbol {
                        text: "monitor_heart"
                        color: Colors.m3.m3onSurfaceVariant
                        font.pixelSize: Fonts.sizes.large
                    }

                    StyledText {
                        text: qsTr("Utilization:")
                        color: Colors.m3.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        color: Colors.m3.m3onSurfaceVariant
                        text: `${modelData.utilization.toFixed(1)}%`
                    }

                }

                RowLayout {
                    spacing: 5
                    width: parent.width
                    visible: modelData.temperature > 0

                    Symbol {
                        text: "device_thermostat"
                        color: Colors.m3.m3onSurfaceVariant
                        font.pixelSize: Fonts.sizes.large
                    }

                    StyledText {
                        text: qsTr("Temperature:")
                        color: Colors.m3.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        color: Colors.m3.m3onSurfaceVariant
                        text: `${modelData.temperature.toFixed(1)} °C`
                    }

                }

                RowLayout {
                    spacing: 5
                    width: parent.width
                    visible: modelData.memory_total > 1

                    Symbol {
                        text: "memory"
                        color: Colors.m3.m3onSurfaceVariant
                        font.pixelSize: Fonts.sizes.large
                    }

                    StyledText {
                        text: qsTr("VRAM:")
                        color: Colors.m3.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        color: Colors.m3.m3onSurfaceVariant
                        text: `${((modelData.memory_used / modelData.memory_total) * 100).toFixed(1)}% (${modelData.memory_used.toFixed(0)} / ${modelData.memory_total.toFixed(0)} MB)`
                    }

                }

                RowLayout {
                    spacing: 5
                    width: parent.width
                    visible: modelData.power_draw > 0

                    Symbol {
                        text: "bolt"
                        color: Colors.m3.m3onSurfaceVariant
                        font.pixelSize: Fonts.sizes.large
                    }

                    StyledText {
                        text: qsTr("Power:")
                        color: Colors.m3.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        color: Colors.m3.m3onSurfaceVariant
                        text: `${modelData.power_draw.toFixed(1)} / ${modelData.power_limit.toFixed(0)} W`
                    }

                }

            }

        }

    }

}
