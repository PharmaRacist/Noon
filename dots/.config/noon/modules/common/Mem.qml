pragma ComponentBehavior: Bound
pragma Singleton
import qs.services
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules.common.widgets
import qs.store

Singleton {
    id: root

    property bool ready: todoView.loaded && optionsView.loaded && statesView.loaded && timersView.loaded
    property alias states: statesView.data
    property alias options: optionsView.data
    property alias timers: timersView.data
    property alias todo: todoView.data

    ConfigFileView {
        id: optionsView
        fileName: "options"
        adapter: OptionsSchema {}
    }

    ConfigFileView {
        id: todoView
        state: true
        fileName: "todo"
        adapter: TodoSchema {}
    }

    ConfigFileView {
        id: statesView
        state: true
        fileName: "states"
        adapter: StatesSchema {}
    }

    ConfigFileView {
        id: timersView
        state: true
        fileName: "timers"
        adapter: TimersSchema {}
    }
}
