import QtQuick
import Quickshell
import Quickshell.Io

Column {
    id: root
    spacing: 8
    width: 300

    property var hosts: []
    property var jobsByHost: ({})
    property var queuedJobs: []

    function heatColor(fraction) {
        if (fraction >= 0.8) return "#ff8fa3";
        if (fraction >= 0.5) return "#f5d08a";
        return Theme.text;
    }

    readonly property int smallestJobCpus: 2
    readonly property real smallestJobMemGb: 3

    function availability(host) {
        if (!host.reachable) return "offline";
        if (host.mode === "off") return "off";
        if (host.freeCpus >= root.smallestJobCpus && host.freeMem >= root.smallestJobMemGb) return "available";
        return "full";
    }

    function availabilityColor(state) {
        if (state === "available") return "#9be0a8";
        if (state === "full") return "#f5d08a";
        if (state === "off") return "#ff8fa3";
        return Theme.faint;
    }

    function availabilityLabel(host) {
        const state = root.availability(host);
        if (state === "available" || state === "full") return state + " · " + host.mode + " " + host.capPercent + "%";
        return state;
    }

    function jobColor(label) {
        return label.startsWith("cargo") ? "#f5b48a" : "#a3b8ff";
    }

    readonly property var nextSwitch: ({ "auto": "free", "free": "off", "off": "auto", "shared": "auto" })

    function switchLabel(state) {
        if (state === "free") return "on";
        if (state === "off") return "off";
        if (state === "shared") return "shared";
        return "auto";
    }

    function switchCommand(host, state) {
        const target = root.nextSwitch[state] || "auto";
        const drain = target === "off" ? " --drain" : "";
        return ["sh", "-c", "exec \"$HOME/.claude/coordinator/runq\" set " + host + " " + target + drain];
    }

    function load(text) {
        const report = JSON.parse(text);
        root.hosts = Object.entries(report.hosts || {}).map(([name, h]) => ({
            name: name,
            reachable: Boolean(h.reachable),
            busy: h.reachable && h.cores > 0 ? Math.min(1, h.busy_cores / h.cores) : 0,
            cores: h.cores || 0,
            busyCores: h.busy_cores || 0,
            freeMem: h.free_mem_gb || 0,
            sessions: h.claude_sessions || 0,
            mode: h.mode || "",
            capPercent: h.cap_percent || 0,
            freeCpus: h.free_cpus || 0,
            switchState: h.switch || "auto"
        }));
        const byHost = {};
        for (const job of report.running || []) (byHost[job.host] = byHost[job.host] || []).push(job);
        root.jobsByHost = byHost;
        root.queuedJobs = report.queued || [];
    }

    Process {
        id: fetch
        running: true
        command: ["sh", "-c", "exec \"$HOME/.claude/coordinator/runq\" status --json"]
        stdout: StdioCollector {
            onStreamFinished: { try { root.load(this.text); } catch (e) {} }
        }
    }

    Timer { interval: 10 * 1000; running: true; repeat: true; onTriggered: fetch.running = true }

    Text {
        text: "Machines"
        color: Theme.text
        font { family: Theme.font; pixelSize: 18; weight: Font.Medium }
    }

    Repeater {
        model: root.hosts
        Column {
            required property var modelData
            width: root.width
            spacing: 4

            Item {
                width: parent.width
                height: 20
                Row {
                    spacing: 8
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        anchors.verticalCenter: hostName.verticalCenter
                        color: root.availabilityColor(root.availability(modelData))
                    }
                    Text {
                        id: hostName
                        text: modelData.name
                        color: Theme.text
                        font { family: Theme.font; pixelSize: 15; weight: Font.DemiBold }
                    }
                    Text {
                        anchors.baseline: hostName.baseline
                        text: root.availabilityLabel(modelData)
                        color: root.availabilityColor(root.availability(modelData))
                        font { family: Theme.font; pixelSize: 11; weight: Font.Medium }
                    }
                }
                Rectangle {
                    id: toggle
                    anchors { right: busyText.left; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    width: toggleText.implicitWidth + 14
                    height: 16
                    radius: 8
                    readonly property bool forced: modelData.switchState !== "auto"
                    color: toggleArea.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, forced ? 0.16 : 0.08)
                    border.width: forced ? 1 : 0
                    border.color: root.availabilityColor(modelData.switchState === "off" ? "off" : "available")
                    Text {
                        id: toggleText
                        anchors.centerIn: parent
                        text: setter.running ? "…" : root.switchLabel(modelData.switchState)
                        color: toggle.forced ? Theme.text : Theme.dim
                        font { family: Theme.font; pixelSize: 10; weight: Font.Medium }
                    }
                    MouseArea {
                        id: toggleArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: modelData.reachable && !setter.running
                        onClicked: {
                            setter.command = root.switchCommand(modelData.name, modelData.switchState);
                            setter.running = true;
                        }
                    }
                    Process {
                        id: setter
                        onExited: fetch.running = true
                    }
                }
                Text {
                    id: busyText
                    anchors.right: parent.right
                    text: modelData.reachable ? Math.round(modelData.busy * 100) + "%" : "offline"
                    color: modelData.reachable ? root.heatColor(modelData.busy) : Theme.faint
                    font { family: Theme.font; pixelSize: 15; weight: Font.DemiBold }
                }
            }
            Item {
                width: parent.width
                height: 4
                Rectangle { anchors.fill: parent; radius: 2; color: Qt.rgba(1, 1, 1, 0.14) }
                Rectangle {
                    width: parent.width * modelData.busy
                    height: parent.height
                    radius: 2
                    color: root.heatColor(modelData.busy)
                    Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }
            }
            Text {
                visible: modelData.reachable
                text: modelData.busyCores.toFixed(1) + "/" + modelData.cores + " cores · " + modelData.freeMem.toFixed(1) + " GB free · "
                      + modelData.sessions + (modelData.sessions === 1 ? " session" : " sessions")
                color: Theme.dim
                font { family: Theme.font; pixelSize: 11 }
            }
            Row {
                visible: modelData.reachable
                spacing: 5
                readonly property var jobs: root.jobsByHost[modelData.name] || []
                Text {
                    text: parent.jobs.length > 0 ? "in use" : "○ idle"
                    color: parent.jobs.length > 0 ? Theme.text : Theme.faint
                    font { family: Theme.font; pixelSize: 11 }
                }
                Repeater {
                    model: parent.jobs
                    Rectangle {
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: root.jobColor(modelData.label)
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.7; duration: 900; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }
        }
    }

    Row {
        spacing: 5
        Text {
            text: root.queuedJobs.length > 0 ? "queue" : "queue empty"
            color: Theme.faint
            font { family: Theme.font; pixelSize: 11 }
        }
        Repeater {
            model: root.queuedJobs
            Rectangle {
                required property var modelData
                anchors.verticalCenter: parent.verticalCenter
                width: 8
                height: 8
                radius: 4
                color: "transparent"
                border.width: 1.5
                border.color: root.jobColor(modelData.label)
            }
        }
    }
}
