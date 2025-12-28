pragma Singleton
import qs.common.utils
import qs.store

Singleton {
    id: root

    property bool ready: todoView.loaded && optionsView.loaded && statesView.loaded && timersView.loaded
    property alias states: statesView.data
    property alias options: optionsView.data
    property alias timers: timersView.data
    property alias todo: todoView.data
    // Loads Once On Start -- Contains Static Info -- Archive
    property alias store: storeView.data

    ConfigFileView {
        id: optionsView

        state: false
        fileName: "options"

        OptionsSchema {}
    }

    ConfigFileView {
        id: todoView

        fileName: "todo"

        TodoSchema {}
    }

    ConfigFileView {
        id: statesView

        fileName: "states"

        StatesSchema {}
    }

    ConfigFileView {
        id: timersView

        fileName: "timers"

        TimersSchema {}
    }

    ConfigFileView {
        id: storeView
        watchChanges: false
        fileName: "timers"
        StoreSchema {}
    }
}
