import QtQuick
import Quickshell
import Quickshell.Io

Column {
    id: root
    spacing: 8
    width: 300

    property string temp: "--"
    property string feels: ""
    property string desc: ""
    property string place: ""
    property int code: 113
    property string details: ""
    property var hours: []
    property var days: []

    readonly property color rainy: "#a3d4ff"
    readonly property int rainyFrom: 30
    readonly property var weekdays: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

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

    function clock24(text) {
        const [hm, half] = text.split(" ");
        let [h, m] = hm.split(":").map(Number);
        if (half === "PM" && h < 12) h += 12;
        if (half === "AM" && h === 12) h = 0;
        return String(h).padStart(2, "0") + ":" + String(m).padStart(2, "0");
    }

    function middayCode(day) {
        const noon = day.hourly.find(h => h.time === "1200") || day.hourly[0];
        return Number(noon.weatherCode);
    }

    function maxRain(day) { return Math.max(...day.hourly.map(h => Number(h.chanceofrain))); }

    function load(text) {
        const w = JSON.parse(text);
        const now = w.current_condition[0];
        const today = w.weather[0];
        const sun = today.astronomy[0];
        root.temp = now.temp_C;
        root.feels = now.FeelsLikeC;
        root.desc = now.weatherDesc[0].value;
        root.code = Number(now.weatherCode);
        root.place = w.nearest_area[0].areaName[0].value;
        root.details = "\u{F058E} " + now.humidity + "%  \u{F059D} " + now.windspeedKmph + " " + now.winddir16Point
                     + "  UV " + now.uvIndex + "  \u{F059C} " + root.clock24(sun.sunrise) + " \u{F059B} " + root.clock24(sun.sunset);
        const nowMs = Date.now();
        const upcoming = [];
        for (const day of w.weather) {
            for (const h of day.hourly) {
                const hour = Number(h.time) / 100;
                const at = new Date(day.date + "T00:00:00");
                at.setHours(hour);
                if (at.getTime() > nowMs) upcoming.push({ hour: hour, temp: h.tempC, code: Number(h.weatherCode), rain: Number(h.chanceofrain) });
            }
        }
        root.hours = upcoming.slice(0, 6);
        root.days = w.weather.map((day, index) => ({
            label: index === 0 ? "Today" : root.weekdays[new Date(day.date + "T12:00:00").getDay()],
            low: day.mintempC,
            high: day.maxtempC,
            code: root.middayCode(day),
            rain: root.maxRain(day)
        }));
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
        spacing: 10
        GradientText {
            width: 112; height: 58
            pixelSize: 50
            weight: 700
            fadeTo: 0.1
            text: root.temp + "°"
        }
        Column {
            spacing: 1
            topPadding: 4
            Row {
                spacing: 6
                Text {
                    text: root.glyph(root.code, root.isNight(new Date().getHours()))
                    color: Theme.text
                    font { family: Theme.font; pixelSize: 16 }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.desc
                    color: Theme.text
                    font { family: Theme.font; pixelSize: 13; weight: Font.DemiBold }
                }
            }
            Text {
                text: root.place + (root.feels ? " · feels " + root.feels + "°" : "")
                color: Theme.dim
                font { family: Theme.font; pixelSize: 11 }
            }
            Text {
                text: root.details
                color: Theme.dim
                font { family: Theme.font; pixelSize: 10 }
            }
        }
    }

    Row {
        anchors.right: parent.right
        spacing: 12
        Repeater {
            model: root.hours
            Column {
                required property var modelData
                spacing: 1
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: String(modelData.hour).padStart(2, "0")
                    color: Theme.faint
                    font { family: Theme.font; pixelSize: 9 }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.glyph(modelData.code, root.isNight(modelData.hour))
                    color: Theme.text
                    font { family: Theme.font; pixelSize: 13 }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData.temp + "°"
                    color: Theme.text
                    font { family: Theme.font; pixelSize: 10; weight: Font.DemiBold }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData.rain + "%"
                    color: modelData.rain >= root.rainyFrom ? root.rainy : Theme.faint
                    font { family: Theme.font; pixelSize: 9 }
                }
            }
        }
    }

    Column {
        anchors.right: parent.right
        spacing: 2
        Repeater {
            model: root.days
            Row {
                required property var modelData
                anchors.right: parent.right
                spacing: 8
                Text {
                    width: 40
                    text: modelData.label
                    color: Theme.dim
                    font { family: Theme.font; pixelSize: 10 }
                }
                Text {
                    text: root.glyph(modelData.code, false)
                    color: Theme.text
                    font { family: Theme.font; pixelSize: 11 }
                }
                Text {
                    width: 52
                    horizontalAlignment: Text.AlignRight
                    text: modelData.low + "–" + modelData.high + "°"
                    color: Theme.text
                    font { family: Theme.font; pixelSize: 10 }
                }
                Text {
                    width: 30
                    horizontalAlignment: Text.AlignRight
                    text: modelData.rain + "%"
                    color: modelData.rain >= root.rainyFrom ? root.rainy : Theme.faint
                    font { family: Theme.font; pixelSize: 10 }
                }
            }
        }
    }
}
