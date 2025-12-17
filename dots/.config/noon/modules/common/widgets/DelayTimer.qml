import QtQuick
import Quickshell
import qs.modules.common

Timer {
    interval: Mem.options.arbitraryRaceConditionDelay
}
