import QtQuick
import Quickshell
import Quickshell.Io

Column {
    id: root
    spacing: 5
    width: 400

    property var groups: []
    property bool loaded: false

    readonly property var stateColors: ({ same: "#9be0a8", differs: "#f5d08a", unknown: Theme.faint })
    readonly property var hiddenServices: ["ez-stock-frontend"]
    readonly property var labels: ({ "ez-stock-backend": "ez-commerce" })

    function stateColor(state) { return root.stateColors[state] || root.stateColors.unknown; }

    function trimmedTarget(prod, main) {
        const a = prod.split("."), b = main.split(".");
        let shared = 0;
        while (shared < a.length - 1 && a[shared] === b[shared]) shared++;
        return shared > 0 ? "." + b.slice(shared).join(".") : main;
    }

    function version(service) {
        if (service.state === "differs") return service.prod + "→" + root.trimmedTarget(service.prod, service.main);
        return service.prod || "—";
    }

    function group(services) {
        const byName = {};
        const order = [];
        for (const service of services) {
            const label = root.labels[service.service] || service.service;
            const cut = label.indexOf("-");
            const name = cut > 0 ? label.slice(0, cut) : label;
            const member = cut > 0 ? label.slice(cut + 1) : label;
            if (!byName[name]) { byName[name] = []; order.push(name); }
            byName[name].push({ member: member, state: service.state, version: root.version(service) });
        }
        return order.map(name => {
            const members = byName[name];
            const versions = new Set(members.map(m => m.version));
            const shared = versions.size === 1 && !members.some(m => m.state === "differs") ? members[0].version : "";
            return { name: name, members: members, shared: shared };
        });
    }

    Process {
        id: fetch
        running: true
        command: ["sh", "-c", "if [ -f \"$HOME/Projects/host-vps/local-deploy\" ]; then exec bash \"$HOME/.claude/hooks/harness-bar/deploys.sh\"; "
                  + "else exec ssh -o BatchMode=yes -o ConnectTimeout=5 desktop 'bash ~/.claude/hooks/harness-bar/deploys.sh'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.groups = root.group(JSON.parse(this.text).filter(s => !root.hiddenServices.includes(s.service)));
                    root.loaded = true;
                } catch (e) {}
            }
        }
    }

    Timer { interval: 5 * 60 * 1000; running: true; repeat: true; onTriggered: fetch.running = true }

    Text {
        anchors.right: parent.right
        text: root.loaded ? "Huggian" : "Huggian · reading…"
        color: Theme.text
        font { family: Theme.font; pixelSize: 16; weight: Font.Medium }
    }

    Repeater {
        model: root.groups
        Item {
            id: groupRow
            required property var modelData
            width: root.width
            height: 17

            Text {
                id: groupName
                width: 64
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.name
                color: Theme.text
                font { family: Theme.font; pixelSize: 13; weight: Font.DemiBold }
            }
            Row {
                anchors { left: groupName.right; verticalCenter: parent.verticalCenter }
                spacing: 10
                Repeater {
                    model: modelData.members
                    Row {
                        required property var modelData
                        spacing: 4
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 6
                            height: 6
                            radius: 3
                            color: root.stateColor(modelData.state)
                        }
                        Text {
                            id: memberName
                            text: modelData.member
                            color: Theme.text
                            font { family: Theme.font; pixelSize: 11 }
                        }
                        Text {
                            visible: !groupRow.modelData.shared
                            text: modelData.version
                            color: modelData.state === "differs" ? root.stateColor("differs") : Theme.dim
                            font { family: Theme.font; pixelSize: 10 }
                            anchors.baseline: memberName.baseline
                        }
                    }
                }
            }
            Text {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                text: modelData.shared
                color: Theme.dim
                font { family: Theme.font; pixelSize: 10 }
            }
        }
    }
}
