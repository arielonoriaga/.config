import QtQuick
import Quickshell
import Quickshell.Io

Column {
    id: root
    spacing: 4
    width: 224

    SystemClock { id: clock; precision: SystemClock.Minutes }

    readonly property date today: clock.date
    readonly property string todayKey: isoDay(today)
    property string selected: todayKey
    property var days: ({})
    property bool configured: true

    readonly property real moonAge: {
        const synodic = 29.530588853;
        const days = (today.getTime() - Date.UTC(2000, 0, 6, 18, 14)) / 86400000;
        return ((days % synodic) + synodic) % synodic;
    }
    readonly property string moonName: {
        const names = ["New moon", "Waxing crescent", "First quarter", "Waxing gibbous",
                       "Full moon", "Waning gibbous", "Last quarter", "Waning crescent"];
        return names[Math.floor((moonAge / 29.530588853) * 8 + 0.5) % 8];
    }
    readonly property var cells: {
        const y = today.getFullYear(), m = today.getMonth();
        const first = new Date(y, m, 1).getDay();
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(y, m, 1 - first + i);
            out.push({ day: d.getDate(), key: isoDay(d), current: d.getMonth() === m });
        }
        return out;
    }
    readonly property var selectedEvents: days[selected] || []

    function isoDay(d) {
        return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
    }

    onTodayKeyChanged: selected = todayKey

    Process {
        id: fetch
        running: true
        command: ["python3", "-I", Quickshell.shellDir + "/calendar-events.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const report = JSON.parse(this.text);
                    root.configured = report.configured;
                    root.days = report.days;
                } catch (e) {}
            }
        }
    }

    Timer { interval: 10 * 60 * 1000; running: true; repeat: true; onTriggered: fetch.running = true }

    Item {
        width: parent.width
        height: 30
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(root.today, "MMMM")
            color: Theme.text
            font { family: Theme.font; pixelSize: 22; weight: Font.Medium }
        }
        Moon {
            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
            width: 18; height: 18
            age: root.moonAge
        }
    }

    Text {
        text: root.moonName
        color: Theme.faint
        font { family: Theme.font; pixelSize: 10 }
        bottomPadding: 4
    }

    Grid {
        columns: 7
        Repeater {
            model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            Text {
                required property string modelData
                width: 32; height: 18
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: Theme.faint
                font { family: Theme.font; pixelSize: 10 }
            }
        }
        Repeater {
            model: root.cells
            Item {
                id: cell
                required property var modelData
                readonly property bool isToday: modelData.key === root.todayKey
                readonly property bool isSelected: modelData.key === root.selected
                readonly property bool busy: (root.days[modelData.key] || []).length > 0
                width: 32; height: 28

                Rectangle {
                    anchors.centerIn: parent
                    width: 26; height: 26; radius: 13
                    visible: cell.isSelected && !cell.isToday
                    color: "transparent"
                    border { width: 1; color: Theme.text }
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 26; height: 26; radius: 13
                    visible: hover.containsMouse && !cell.isSelected
                    color: Qt.rgba(1, 1, 1, 0.1)
                }
                Sparkle {
                    anchors.centerIn: parent
                    visible: cell.isToday
                    font.pixelSize: 36
                    opacity: 0.9
                }
                Text {
                    anchors.centerIn: parent
                    text: cell.modelData.day
                    color: cell.isToday ? Theme.deep : cell.modelData.current ? Theme.text : Theme.faint
                    opacity: cell.modelData.current ? 1 : 0.55
                    font { family: Theme.font; pixelSize: 13; weight: cell.isToday ? Font.Bold : Font.Normal }
                }
                Rectangle {
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 1 }
                    width: 4; height: 4; radius: 2
                    visible: cell.busy
                    color: Theme.pink
                }
                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selected = cell.modelData.key
                }
            }
        }
    }

    Text {
        topPadding: 8
        text: Qt.formatDate(new Date(root.selected + "T12:00:00"), "dddd d MMM")
        color: Theme.dim
        font { family: Theme.font; pixelSize: 11; weight: Font.Medium }
    }

    Text {
        visible: root.selectedEvents.length === 0
        width: parent.width
        wrapMode: Text.Wrap
        text: root.configured ? "No events" : "Link Google Calendar: put its secret iCal URL in ~/.local/share/aurora/calendars"
        color: Theme.faint
        font { family: Theme.font; pixelSize: 11 }
    }

    ListView {
        width: parent.width
        height: Math.min(contentHeight, 120)
        visible: root.selectedEvents.length > 0
        clip: true
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds
        model: root.selectedEvents
        delegate: Row {
            required property var modelData
            width: ListView.view.width
            spacing: 8
            Text {
                width: 40
                text: modelData.time || "all day"
                color: Theme.pink
                font { family: Theme.font; pixelSize: 11 }
            }
            Text {
                width: parent.width - 48
                text: modelData.title
                elide: Text.ElideRight
                color: Theme.text
                font { family: Theme.font; pixelSize: 12 }
            }
        }
    }
}
