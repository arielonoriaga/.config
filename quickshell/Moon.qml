import QtQuick

Canvas {
    property real age: 0
    onAgeChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        const r = width / 2, cx = r, cy = r;
        const phase = age / 29.530588853;
        const lit = "#f3ecfb", dark = "#5d4380";
        const waxing = phase < 0.5;
        const k = Math.cos(phase * 2 * Math.PI);
        ctx.fillStyle = dark;
        ctx.beginPath(); ctx.arc(cx, cy, r, 0, 2 * Math.PI); ctx.fill();
        ctx.fillStyle = lit;
        ctx.beginPath();
        ctx.arc(cx, cy, r, -Math.PI / 2, Math.PI / 2, !waxing);
        ctx.closePath();
        ctx.fill();
        const rx = Math.abs(k) * r;
        ctx.fillStyle = k > 0 ? dark : lit;
        ctx.beginPath(); ctx.ellipse(cx - rx, 0, rx * 2, r * 2); ctx.fill();
    }
}
