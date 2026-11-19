import QtQuick
import Quickshell
import Quickshell.Io

Column {
    id: root
    spacing: 10
    width: 260

    property string temp: "--"
    property string desc: ""
    property string place: ""
    property int code: 113
    property var hours: []

    function glyph(code, night) {
        const has = list => list.indexOf(code) >= 0;
        if (has([200, 386, 389, 392, 395])) return "\u{F0593}";
        if (has([179, 182, 185, 227, 230, 317, 320, 323, 326, 329, 332, 335, 338, 350, 362, 365, 368, 371, 374, 377])) return "\u{F0598}";
        if (has([176, 263, 266, 281, 284, 293, 296, 299, 302, 305, 308, 311, 314, 353, 356, 359])) return "\u{F0597}";
        if (has([143, 248, 260])) return "\u{F0591}";
        if (has([119, 122])) return "\u{F0590}";
        if (code === 116) return night ? "\u{F0F31}" : "\u{F0595}";
        return night ? "\u{F0594}" : "\u{F0599}";
    }

    function isNight(hour) { return hour < 7 || hour >= 20; }

    function load(text) {
        const w = JSON.parse(text);
        const now = w.current_condition[0];
        root.temp = now.temp_C;
        root.desc = now.weatherDesc[0].value;
        root.code = Number(now.weatherCode);
        root.place = w.nearest_area[0].areaName[0].value;
        const nowMs = Date.now();
        const upcoming = [];
        for (const day of w.weather) {
            for (const h of day.hourly) {
                const hour = Number(h.time) / 100;
                const at = new Date(day.date + "T00:00:00");
                at.setHours(hour);
                if (at.getTime() > nowMs) upcoming.push({ hour: hour, temp: h.tempC, code: Number(h.weatherCode) });
            }
        }
        root.hours = upcoming.slice(0, 5);
    }

    Process {
        id: fetch
        running: true
        command: ["curl", "-sf", "--max-time", "15", "https://wttr.in/?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: { try { root.load(this.text); } catch (e) {} }
        }
    }

    Timer { interval: 30 * 60 * 1000; running: true; repeat: true; onTriggered: fetch.running = true }

    Row {
        anchors.right: parent.right
        spacing: 12
        GradientText {
            width: 170; height: 82
            pixelSize: 70
            weight: 700
            fadeTo: 0.1
            text: root.temp + "°"
        }
        Column {
            spacing: 2
            topPadding: 6
            Text {
                text: root.glyph(root.code, root.isNight(new Date().getHours()))
                color: Theme.text
                font { family: Theme.font; pixelSize: 22 }
            }
            Text { text: root.desc; color: Theme.text; font { family: Theme.font; pixelSize: 13; weight: Font.DemiBold } }
            Text { text: root.place; color: Theme.dim; font { family: Theme.font; pixelSize: 11 } }
        }
    }

    Row {
        anchors.right: parent.right
        spacing: 14
        Repeater {
            model: root.hours
            Column {
                required property var modelData
                spacing: 3
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: String(modelData.hour).padStart(2, "0") + ":00"
                    color: Theme.dim
                    font { family: Theme.font; pixelSize: 10 }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.glyph(modelData.code, root.isNight(modelData.hour))
                    color: Theme.text
                    font { family: Theme.font; pixelSize: 14 }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData.temp + "°"
                    color: Theme.text
                    font { family: Theme.font; pixelSize: 11; weight: Font.DemiBold }
                }
            }
        }
    }
}
