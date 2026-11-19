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


    function jobColor(label) {
        return label.startsWith("cargo") ? "#f5b48a" : "#a3b8ff";
    }

    readonly property var nextSwitch: ({ "auto": "free", "free": "off", "off": "auto", "shared": "auto" })

    function switchLabel(host) {
        if (host.switchState === "free") return "on";
        if (host.switchState === "off") return "off";
        if (host.switchState === "shared") return "shared";
        return "auto·" + host.mode;
    }

    function hostStats(host) {
        if (!host.reachable) return "offline";
        return host.busyCores.toFixed(1) + "/" + host.cores + "c · " + host.freeMem.toFixed(1) + "G · " + host.sessions + "◆";
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
            ourCores: Math.max(0, (h.busy_cores || 0) - (h.foreign_cores || 0)),
            foreignCores: h.foreign_cores || 0,
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

    Timer { interval: (Ticker.desktopVisible ? 10 : 60) * 1000; running: true; repeat: true; onTriggered: fetch.running = true }

    Item {
        width: root.width
        height: 22
        Text {
            id: title
            anchors.verticalCenter: parent.verticalCenter
            text: "Machines"
            color: Theme.text
            font { family: Theme.font; pixelSize: 16; weight: Font.Medium }
        }
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: 4
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.queuedJobs.length > 0 ? "queue" : "queue empty"
                color: Theme.faint
                font { family: Theme.font; pixelSize: 10 }
            }
            Repeater {
                model: root.queuedJobs
                JobDot { required property var modelData; tint: root.jobColor(modelData.label); waiting: true }
            }
        }
    }

    Repeater {
        model: root.hosts
        Column {
            id: hostRow
            required property var modelData
            readonly property var jobs: root.jobsByHost[modelData.name] || []
            readonly property string state: root.availability(modelData)
            width: root.width
            spacing: 3

            Item {
                width: parent.width
                height: 18
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: root.availabilityColor(hostRow.state)
                    }
                    Text {
                        text: modelData.name
                        color: modelData.reachable ? Theme.text : Theme.faint
                        font { family: Theme.font; pixelSize: 13; weight: Font.DemiBold }
                    }
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text {
                            visible: hostRow.jobs.length === 0 && modelData.reachable
                            anchors.verticalCenter: parent.verticalCenter
                            text: "○"
                            color: Theme.faint
                            font { family: Theme.font; pixelSize: 10 }
                        }
                        Repeater {
                            model: hostRow.jobs
                            JobDot { required property var modelData; tint: root.jobColor(modelData.label) }
                        }
                    }
                }
                Row {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: 8
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.hostStats(modelData)
                        color: Theme.dim
                        font { family: Theme.font; pixelSize: 10 }
                    }
                    Rectangle {
                        id: toggle
                        anchors.verticalCenter: parent.verticalCenter
                        readonly property bool forced: modelData.switchState !== "auto"
                        width: toggleText.implicitWidth + 12
                        height: 15
                        radius: 7.5
                        color: toggleArea.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, forced ? 0.16 : 0.08)
                        border.width: forced ? 1 : 0
                        border.color: root.availabilityColor(modelData.switchState === "off" ? "off" : "available")
                        Text {
                            id: toggleText
                            anchors.centerIn: parent
                            text: setter.running ? "…" : root.switchLabel(modelData)
                            color: toggle.forced ? Theme.text : Theme.dim
                            font { family: Theme.font; pixelSize: 9; weight: Font.Medium }
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
                }
            }

            Item {
                width: parent.width
                height: 4
                readonly property real perCore: modelData.cores > 0 ? width / modelData.cores : 0
                Rectangle { anchors.fill: parent; radius: 2; color: Qt.rgba(1, 1, 1, 0.12) }
                Rectangle {
                    id: ours
                    height: parent.height
                    radius: 2
                    width: Math.min(parent.width, modelData.ourCores * parent.perCore)
                    color: "#f5b48a"
                    Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }
                Rectangle {
                    x: ours.width
                    height: parent.height
                    radius: 2
                    width: Math.min(parent.width - ours.width, modelData.foreignCores * parent.perCore)
                    color: Qt.rgba(1, 1, 1, 0.45)
                    Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }
                Rectangle {
                    visible: modelData.reachable && modelData.mode !== "off"
                    x: parent.width * modelData.capPercent / 100 - 1
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: 8
                    radius: 1
                    color: root.availabilityColor(hostRow.state)
                }
            }
        }
    }
}
