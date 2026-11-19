pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    readonly property var player: {
        const players = Mpris.players.values.filter(p => p.isPlaying || p.trackArtist);
        for (const p of players) if (p.isPlaying && p.trackArtist) return p;
        return players.length > 0 ? players[0] : null;
    }
    readonly property bool playing: player !== null && player.isPlaying
    readonly property string title: player ? player.trackTitle : ""
    readonly property string artist: player ? player.trackArtist : ""
    readonly property string album: player ? player.trackAlbum : ""
    readonly property string art: player ? player.trackArtUrl : ""
    readonly property real position: player ? player.position : 0
    readonly property real length: player ? player.length : 0
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0

    function clock(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    Timer {
        running: Player.playing
        interval: 1000
        repeat: true
        onTriggered: Player.player.positionChanged()
    }
}
