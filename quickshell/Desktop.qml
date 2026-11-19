import QtQuick
import Quickshell

Item {
    id: root
    property alias calendar: calendar
    property alias machines: machines

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Sky { anchors.fill: parent }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 52
        spacing: 6

        Headline { anchors.horizontalCenter: parent.horizontalCenter }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
            color: Theme.dim
            font { family: Theme.font; pixelSize: 16; weight: Font.Medium }
        }
    }

    GradientText {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 430
        width: 1100
        height: 380
        pixelSize: 330
        text: Qt.formatDateTime(clock.date, "hh:mm").replace(":", "·")
    }

    Calendar { id: calendar; x: 32; y: 220 }

    Weather {
        anchors { right: parent.right; rightMargin: 28 }
        y: 52
    }

    Machines {
        id: machines
        x: 32
        anchors { bottom: parent.bottom; bottomMargin: 40 }
    }

    Huggian {
        anchors { right: parent.right; rightMargin: 28; bottom: parent.bottom; bottomMargin: 40 }
    }
}
