import QtQuick

Canvas {
    id: canvas
    property string text: ""
    property int pixelSize: 100
    property int weight: 600
    property real fadeTo: 0
    renderTarget: Canvas.FramebufferObject
    implicitHeight: pixelSize * 1.15

    onTextChanged: requestPaint()
    onWidthChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        const g = ctx.createLinearGradient(0, 0, 0, height);
        g.addColorStop(0, Qt.rgba(1, 0.98, 1, 0.97));
        g.addColorStop(0.5, Qt.rgba(1, 0.9, 0.98, 0.62));
        g.addColorStop(1, Qt.rgba(0.98, 0.8, 0.94, fadeTo));
        ctx.fillStyle = g;
        ctx.font = weight + " " + pixelSize + "px '" + Theme.font + "'";
        ctx.textAlign = "center";
        ctx.textBaseline = "top";
        ctx.fillText(text.replace(/0/g, "O"), width / 2, 0);
    }
}
