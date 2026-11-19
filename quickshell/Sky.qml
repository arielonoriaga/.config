import QtQuick
import QtQuick.Shapes
import "Zodiac.js" as Zodiac

Item {
    id: sky

    readonly property real unit: width / 1920
    readonly property point origin: Qt.point(50 * unit, 105 * unit)
    property var sign: Zodiac.current(new Date())
    readonly property var nodes: sign.nodes
    readonly property var edges: sign.edges
    readonly property int traceStepMs: 450
    readonly property int traceGlowMs: 2400
    readonly property int tracePeriodMs: 14000
    readonly property int twinklingStars: 60

    function seeded(seed) {
        let state = seed;
        return () => {
            state = (state * 1664525 + 1013904223) % 4294967296;
            return state / 4294967296;
        };
    }

    readonly property var stars: {
        const random = sky.seeded(19);
        const out = [];
        for (let i = 0; i < sky.twinklingStars; i++)
            out.push({ x: random(), y: random() * 0.62, size: 1 + random() * 1.6, period: 2200 + random() * 4200, delay: random() * 4000, peak: 0.45 + random() * 0.5 });
        return out;
    }

    Repeater {
        model: sky.stars
        Rectangle {
            required property var modelData
            x: modelData.x * sky.width
            y: modelData.y * sky.height
            width: modelData.size
            height: modelData.size
            radius: width / 2
            color: "white"
            opacity: 0.1 + (modelData.peak - 0.1) * Ticker.wave(modelData.period / 1000, modelData.delay / 1000)
        }
    }

    Item {
        id: constellation
        x: sky.origin.x + 10 * Ticker.wave(60)
        y: sky.origin.y + 5 * Ticker.wave(46)
        scale: sky.unit
        transformOrigin: Item.TopLeft


        Shape {
            x: sky.sign.width / 2 - 140
            y: sky.sign.height / 2 - 140
            width: 280
            height: 280
            preferredRendererType: Shape.CurveRenderer
            transform: Scale { origin.x: 140; origin.y: 140; yScale: 55 / 140 }
            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillGradient: RadialGradient {
                    centerX: 140; centerY: 140; centerRadius: 140
                    focalX: 140; focalY: 140
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.11) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
                }
                PathAngleArc { centerX: 140; centerY: 140; radiusX: 140; radiusY: 140; startAngle: 0; sweepAngle: 360 }
            }
            opacity: 0.55 + 0.45 * Ticker.wave(10)
        }

        Repeater {
            model: sky.edges
            Rectangle {
                required property var modelData
                required property int index
                readonly property var from: sky.nodes[modelData[0]]
                readonly property var to: sky.nodes[modelData[1]]
                readonly property int lead: index * sky.traceStepMs
                x: from[0]
                y: from[1] - height / 2
                width: Math.hypot(to[0] - from[0], to[1] - from[1])
                height: 1
                color: "white"
                antialiasing: true
                transformOrigin: Item.Left
                rotation: Math.atan2(to[1] - from[1], to[0] - from[0]) * 180 / Math.PI
                readonly property real sinceLit: ((Ticker.seconds * 1000 - lead) % sky.tracePeriodMs + sky.tracePeriodMs) % sky.tracePeriodMs
                opacity: sinceLit < 500 ? 0.2 + 0.55 * sinceLit / 500
                       : sinceLit < 500 + sky.traceGlowMs ? 0.75 - 0.55 * (sinceLit - 500) / sky.traceGlowMs
                       : 0.2
            }
        }

        Text {
            y: -26
            text: sky.sign.name + "  ·  " + sky.sign.range
            color: Qt.rgba(1, 1, 1, 0.42)
            font { family: Theme.font; pixelSize: 11; letterSpacing: 1.5 }
        }

        Repeater {
            model: sky.nodes
            Rectangle {
                required property var modelData
                required property int index
                x: modelData[0] - width / 2
                y: modelData[1] - height / 2
                readonly property bool brightest: index === sky.sign.bright
                width: brightest ? 6.5 : 4.4
                height: width
                radius: width / 2
                color: "white"
                opacity: 0.45 + 0.5 * Ticker.wave(3.6, index * 0.37)
            }
        }
    }

    Item {
        id: meteor
        width: 140 * sky.unit
        height: 1.6
        opacity: 0
        rotation: 24
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 0.92, 0.97, 0.95) }
            }
        }

        function launch() {
            const random = sky.seeded(Date.now() % 100000);
            meteor.x = sky.width * (0.15 + random() * 0.6);
            meteor.y = sky.height * (0.04 + random() * 0.25);
            fall.restart();
        }

        ParallelAnimation {
            id: fall
            NumberAnimation { target: meteor; property: "x"; to: meteor.x + 420 * sky.unit; duration: 1100; easing.type: Easing.InQuad }
            NumberAnimation { target: meteor; property: "y"; to: meteor.y + 190 * sky.unit; duration: 1100; easing.type: Easing.InQuad }
            SequentialAnimation {
                NumberAnimation { target: meteor; property: "opacity"; to: 0.9; duration: 250 }
                NumberAnimation { target: meteor; property: "opacity"; to: 0; duration: 850 }
            }
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 60 * 60 * 1000
        onTriggered: sky.sign = Zodiac.current(new Date())
    }

    Timer {
        running: true
        repeat: true
        interval: 15000 + Math.floor(Math.random() * 30000)
        onTriggered: {
            if (Ticker.desktopVisible) meteor.launch();
            interval = 15000 + Math.floor(Math.random() * 30000);
        }
    }
}
