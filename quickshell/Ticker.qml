pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: ticker

    readonly property int framesPerSecond: 20
    readonly property var monitor: Hyprland.monitors.values.find(m => Theme.preferredScreens.includes(m.name)) || null
    readonly property var workspace: monitor ? monitor.activeWorkspace : null
    readonly property bool desktopVisible: !workspace || workspace.toplevels.values.length === 0
    property real seconds: 0

    function wave(periodSeconds, offsetSeconds) {
        return 0.5 - 0.5 * Math.cos(2 * Math.PI * (ticker.seconds - (offsetSeconds || 0)) / periodSeconds);
    }

    Timer {
        running: ticker.desktopVisible
        repeat: true
        interval: 1000 / ticker.framesPerSecond
        onTriggered: ticker.seconds += interval / 1000
    }
}
