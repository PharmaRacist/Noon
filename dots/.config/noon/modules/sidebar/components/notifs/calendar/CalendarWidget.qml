import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "calendar_layout.js" as CalendarLayout
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    property int monthShift: 0
    property var viewingDate: CalendarLayout.getDateInXMonthsTime(monthShift)
    property var calendarLayout: CalendarLayout.getCalendarLayout(viewingDate, monthShift === 0)
    property bool scrollEnabled: true

    implicitWidth: calendarColumn.width
    implicitHeight: calendarColumn.height
    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown)
                monthShift++;
            else if (event.key === Qt.Key_PageUp)
                monthShift--;
            event.accepted = true;
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (event) => {
            if (root.scrollEnabled) {
                if (event.angleDelta.y > 0)
                    monthShift--;
                else if (event.angleDelta.y < 0)
                    monthShift++;
            }
        }
    }

    ColumnLayout {
        id: calendarColumn

        anchors.centerIn: parent
        spacing: 16

        // Calendar header
        RowLayout {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            spacing: 5

            CalendarHeaderButton {
                forceCircle: true
                onClicked: {
                    monthShift--;
                }

                contentItem: MaterialSymbol {
                    text: "chevron_left"
                    font.pixelSize: Fonts.sizes.verylarge
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.colOnLayer1
                }

            }

            CalendarHeaderButton {
                clip: true
                buttonText: viewingDate.toLocaleDateString(Qt.locale(), "MMMM")
                tooltipText: (monthShift === 0) ? "" : qsTr("Jump to current month")
                Layout.fillWidth: true
                onClicked: {
                    monthShift = 0;
                }
            }

            CalendarHeaderButton {
                forceCircle: true
                onClicked: {
                    monthShift++;
                }

                contentItem: MaterialSymbol {
                    text: "chevron_right"
                    font.pixelSize: Fonts.sizes.verylarge
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.colOnLayer1
                }

            }

        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 4

            // Week days row
            RowLayout {
                id: weekDaysRow

                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: false
                spacing: 5

                Repeater {
                    model: CalendarLayout.weekDays

                    delegate: CalendarDayButton {
                        day: modelData.day
                        isToday: modelData.today
                        bold: true
                        enabled: false
                    }

                }

            }

            // Real week rows
            Repeater {
                id: calendarRows

                // model: calendarLayout
                model: 6

                delegate: RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: false
                    spacing: 6

                    Repeater {
                        model: Array(7).fill(modelData)

                        delegate: CalendarDayButton {
                            day: calendarLayout[modelData][index].day
                            isToday: calendarLayout[modelData][index].today
                        }

                    }

                }

            }

        }

    }

}
