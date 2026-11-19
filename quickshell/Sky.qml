import QtQuick
import QtQuick.Shapes

Item {
    id: sky

    readonly property real unit: width / 1920
    readonly property point origin: Qt.point(50 * unit, 105 * unit)
    readonly property var nodes: [[0, 10], [45, 18], [75, 0], [105, 38], [130, 40], [165, 28], [190, 30], [205, 60], [220, 78], [60, 50], [40, 72]]
    readonly property var edges: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [1, 9], [9, 10], [3, 9]]
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
            opacity: 0.1
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PauseAnimation { duration: modelData.delay }
                NumberAnimation { to: modelData.peak; duration: modelData.period / 2; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.1; duration: modelData.period / 2; easing.type: Easing.InOutSine }
            }
        }
    }

    Item {
        id: constellation
        x: sky.origin.x
        y: sky.origin.y
        scale: sky.unit
        transformOrigin: Item.TopLeft

        SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation { from: sky.origin.x; to: sky.origin.x + 10; duration: 30000; easing.type: Easing.InOutSine }
            NumberAnimation { to: sky.origin.x; duration: 30000; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation { from: sky.origin.y; to: sky.origin.y + 5; duration: 23000; easing.type: Easing.InOutSine }
            NumberAnimation { to: sky.origin.y; duration: 23000; easing.type: Easing.InOutSine }
        }

        Shape {
            x: 115 - 140
            y: 40 - 140
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
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.55; to: 1; duration: 5000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.55; duration: 5000; easing.type: Easing.InOutSine }
            }
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
                opacity: 0.2
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    PauseAnimation { duration: lead }
                    NumberAnimation { to: 0.75; duration: 500; easing.type: Easing.OutQuad }
                    NumberAnimation { to: 0.2; duration: sky.traceGlowMs; easing.type: Easing.InOutSine }
                    PauseAnimation { duration: sky.tracePeriodMs - lead - 500 - sky.traceGlowMs }
                }
            }
        }

        Repeater {
            model: sky.nodes
            Rectangle {
                required property var modelData
                required property int index
                x: modelData[0] - width / 2
                y: modelData[1] - height / 2
                width: 4.4
                height: 4.4
                radius: 2.2
                color: "white"
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    PauseAnimation { duration: index * 370 }
                    NumberAnimation { from: 0.85; to: 0.45; duration: 1800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.95; duration: 1800; easing.type: Easing.InOutSine }
                }
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
        interval: 15000 + Math.floor(Math.random() * 30000)
        onTriggered: {
            meteor.launch();
            interval = 15000 + Math.floor(Math.random() * 30000);
        }
    }
}
