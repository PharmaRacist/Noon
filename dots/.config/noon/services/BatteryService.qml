pragma Singleton
pragma ComponentBehavior: Bound
import qs.common
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isPluggedIn: isCharging || chargeState == UPowerDeviceState.PendingCharge
    property real percentage: UPower.displayDevice?.percentage ?? 1
    readonly property bool allowAutomaticSuspend: Mem.options.battery.automaticSuspend

    property bool isLow: available && (percentage <= Mem.options.battery.low / 100)
    property bool isCritical: available && (percentage <= Mem.options.battery.critical / 100)
    property bool isSuspending: available && (percentage <= Mem.options.battery.suspend / 100)

    property bool isLowAndNotCharging: isLow && !isCharging
    property bool isCriticalAndNotCharging: isCritical && !isCharging
    property bool isSuspendingAndNotCharging: allowAutomaticSuspend && isSuspending && !isCharging

    property real energyRate: UPower.displayDevice.changeRate
    property real timeToEmpty: UPower.displayDevice.timeToEmpty
    property real timeToFull: UPower.displayDevice.timeToFull
    onIsLowAndNotCharging: if (isLowAndNotCharging)
        NoonUtils.playSound("power_low")
    onIsChargingChanged: if (isCharging) {
        NoonUtils.playSound("power_plugged");
    } else {
        NoonUtils.playSound("power_unplugged");
    }
    onIsLowAndNotChargingChanged: {
        if (available && isLowAndNotCharging)
            Quickshell.execDetached(["notify-send", qsTr("Low battery"), qsTr("Consider plugging in your device"), "-u", "critical", "-a", "Shell"]);
    }

    onIsCriticalAndNotChargingChanged: {
        if (available && isCriticalAndNotCharging)
            Quickshell.execDetached(["notify-send", qsTr("Critically low battery"), qsTr("Please charge!\nAutomatic suspend triggers at %1").arg(Mem.options.battery.suspend), "-u", "critical", "-a", "Shell"]);
    }

    onIsSuspendingAndNotChargingChanged: {
        if (available && isSuspendingAndNotCharging) {
            NoonUtils.execDetached(`systemctl suspend || loginctl suspend`);
        }
    }
}
