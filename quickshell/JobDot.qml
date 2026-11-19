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
    SequentialAnimation on opacity {
        running: !waiting
        loops: Animation.Infinite
        NumberAnimation { to: 0.7; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
    }
}
