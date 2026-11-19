import QtQuick

Rectangle {
    property color tint: "white"
    property bool waiting: false
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    width: 7
    height: 7
    radius: 3.5
    color: waiting ? "transparent" : tint
    border.width: waiting ? 1.5 : 0
    border.color: tint
    opacity: waiting ? 1 : 0.7 + 0.3 * Ticker.wave(1.8)
}
