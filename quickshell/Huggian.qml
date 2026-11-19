import QtQuick
import Quickshell
import Quickshell.Io

Column {
    id: root
    spacing: 4
    width: 360

    property var services: []
    property bool loaded: false

    readonly property var looks: ({
        same: { glyph: "\u{F012C}", color: "#a8f0c6" },
        differs: { glyph: "\u{F0026}", color: "#f5d08a" },
        unknown: { glyph: "\u{F02D7}", color: Theme.faint }
    })

    readonly property var hiddenServices: ["ez-stock-frontend"]
    readonly property var labels: ({ "ez-stock-backend": "ez-commerce" })

    function look(state) { return root.looks[state] || root.looks.unknown; }

    Process {
        id: fetch
        running: true
        command: ["sh", "-c", "if [ -f \"$HOME/Projects/host-vps/local-deploy\" ]; then exec bash \"$HOME/.claude/hooks/harness-bar/deploys.sh\"; "
                  + "else exec ssh -o BatchMode=yes -o ConnectTimeout=5 desktop 'bash ~/.claude/hooks/harness-bar/deploys.sh'; fi"]
        stdout: StdioCollector {
            onStreamFinished: { try { root.services = JSON.parse(this.text).filter(s => !root.hiddenServices.includes(s.service)); root.loaded = true; } catch (e) {} }
        }
    }

    Timer { interval: 5 * 60 * 1000; running: true; repeat: true; onTriggered: fetch.running = true }

    Text {
        anchors.right: parent.right
        text: "Huggian prod"
        color: Theme.text
        font { family: Theme.font; pixelSize: 18; weight: Font.Medium }
    }

    Text {
        anchors.right: parent.right
        visible: !root.loaded
        text: "reading prod…"
        color: Theme.faint
        font { family: Theme.font; pixelSize: 12 }
    }

    Repeater {
        model: root.services
        Item {
            required property var modelData
            width: root.width
            height: 18

            Text {
                id: glyph
                anchors.verticalCenter: parent.verticalCenter
                text: root.look(modelData.state).glyph
                color: root.look(modelData.state).color
                font { family: Theme.font; pixelSize: 13 }
            }
            Text {
                anchors { left: glyph.right; leftMargin: 8; verticalCenter: parent.verticalCenter }
                text: root.labels[modelData.service] || modelData.service
                color: Theme.text
                font { family: Theme.font; pixelSize: 13 }
            }
            Text {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                text: modelData.state === "differs"
                      ? modelData.prod + " → " + modelData.main
                      : (modelData.prod || "—")
                color: modelData.state === "differs" ? root.look("differs").color : Theme.dim
                font { family: Theme.font; pixelSize: 12 }
            }
        }
    }
}
