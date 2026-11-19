import QtQuick
import Quickshell

Column {
    id: root
    spacing: 4
    width: 820

    readonly property bool hasTrack: Player.title.length > 0
    readonly property string line: hasTrack ? Player.title : greeting()
    readonly property int split: hasTrack ? Math.round(line.length * Player.progress) : line.length

    SystemClock { id: clock; precision: SystemClock.Hours }

    function greeting() {
        const h = clock.date.getHours();
        if (h < 6) return "Still up?";
        if (h < 12) return "Good morning";
        if (h < 19) return "Good afternoon";
        return "Good evening";
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.hasTrack ? Player.artist : "Nothing playing"
        color: Theme.faint
        font { family: Theme.font; pixelSize: 12 }
    }

    Row {
        id: words
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            text: root.line.slice(0, root.split)
            color: Theme.text
            font { family: Theme.font; pixelSize: 26; weight: Font.DemiBold }
        }
        Text {
            text: root.line.slice(root.split)
            color: Theme.faint
            font { family: Theme.font; pixelSize: 26; weight: Font.DemiBold }
        }
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(root.width, words.width + 20)
        height: 12
        visible: root.hasTrack

        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 1; color: Theme.faint }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * Player.progress
            height: 2
            radius: 1
            color: Theme.text
            Behavior on width { NumberAnimation { duration: 900 } }
        }
        Sparkle {
            x: parent.width * Player.progress - width / 2
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 13
            Behavior on x { NumberAnimation { duration: 900 } }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.hasTrack ? Player.album : ""
        color: Theme.faint
        font { family: Theme.font; pixelSize: 12 }
    }
}
