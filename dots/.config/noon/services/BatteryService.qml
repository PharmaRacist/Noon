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

    Connections {
        target: PowerProfiles
        function onDegradationReasonChanged() {
            const reason = PowerProfiles.degradationReason;
            if (reason === PerformanceDegradationReason.HighTemperature)
                NoonUtils.toast("High Temperature", "emergency_heat", "warn");
            if (reason === PerformanceDegradationReason.LapDetected)
                NoonUtils.toast("Move the laptop away from your body", "heat", "warn");
        }
    }

    onIsLowAndNotCharging: if (isLowAndNotCharging)
        NoonUtils.playSound("power_low")
    onIsChargingChanged: if (isCharging) {
        NoonUtils.playSound("power_plugged");
        NoonUtils.toast("Charging", "battery_charging_full", "success");
    } else {
        NoonUtils.playSound("power_unplugged");
        NoonUtils.toast("Discharging", "battery_error");
    }
    onIsLowAndNotChargingChanged: {
        if (available && isLowAndNotCharging)
            NoonUtils.toast("Low Battery Plug in your device", "battery_error", "warn");
    }

    onIsCriticalAndNotChargingChanged: {
        if (available && isCriticalAndNotCharging)
            NoonUtils.toast("Critical Battery Percentage", "battery_error", "error");
    }

    onIsSuspendingAndNotChargingChanged: {
        if (available && isSuspendingAndNotCharging) {
            NoonUtils.execDetached(`systemctl suspend`);
        }
    }
}
