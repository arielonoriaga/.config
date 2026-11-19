import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    IpcHandler {
        target: "aurora"
        function reload(): void { Quickshell.reload(false); }
    }

    Variants {
        model: {
            const screens = Quickshell.screens;
            const name = Theme.preferredScreens.find(wanted => screens.some(screen => screen.name === wanted));
            const main = screens.find(screen => screen.name === name) || screens[0];
            return main ? [main] : [];
        }

        PanelWindow {
            required property var modelData
            screen: modelData
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "aurora-desktop"
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            mask: Region {
                item: desktop.calendar
                Region { item: desktop.machines }
            }

            Desktop { id: desktop; anchors.fill: parent }
        }
    }
}
