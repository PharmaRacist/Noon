//@ pragma UseQApplication
//@ pragma RespectSystemStyle
//@ pragma Env QT_AUTO_SCREEN_SCALE_FACTOR=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QML_XHR_ALLOW_FILE_READ=1
//@ pragma Env QML_XHR_ALLOW_FILE_WRITE=1

import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import qs.modules.main
import qs.modules.xp
import qs.modules.nobuntu
import qs.modules.applications

ShellRoot {
    readonly property string mode: Mem.options.desktop.shell.mode ?? "main"
    readonly property Component main: Main {}
    readonly property Component xp: XP {}
    readonly property Component nobuntu: NoBuntu {}
    readonly property var _shell_map: ({
            "main": main,
            "xp": xp,
            "nobuntu": nobuntu
        })

    WidgetLoader {
        reloadOn: mode
        component: _shell_map[mode]
    }

    WidgetLoader {
        Applications {}
    }
}
