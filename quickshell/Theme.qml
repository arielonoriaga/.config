pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property var preferredScreens: (Quickshell.env("AURORA_SCREENS") || "DP-1").split(" ")
    readonly property string font: "GeistMono Nerd Font"
    readonly property color text: "#f3ecfb"
    readonly property color dim: Qt.rgba(0.95, 0.93, 0.98, 0.6)
    readonly property color faint: Qt.rgba(0.95, 0.93, 0.98, 0.32)
    readonly property color pink: "#f5b8da"
    readonly property color deep: "#3a2257"
    readonly property string assets: "file://" + Quickshell.env("HOME") + "/.config/theme/aurora/"
}
