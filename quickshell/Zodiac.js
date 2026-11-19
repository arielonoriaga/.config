.pragma library

const BOX_WIDTH = 230;
const BOX_HEIGHT = 95;

const SIGNS = [
    { name: "Capricornus", from: [12, 22], until: [1, 19], bright: 0,
      nodes: [[0, 10], [15, 20], [60, 80], [110, 75], [170, 55], [195, 40], [150, 40], [80, 30]],
      edges: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 1]] },
    { name: "Aquarius", from: [1, 20], until: [2, 18], bright: 1,
      nodes: [[0, 20], [40, 10], [80, 25], [100, 15], [115, 25], [125, 10], [90, 50], [110, 75], [150, 85], [60, 70], [30, 90]],
      edges: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 7], [7, 8], [6, 9], [9, 10]] },
    { name: "Pisces", from: [2, 19], until: [3, 20], bright: 7,
      nodes: [[0, 60], [15, 45], [35, 48], [30, 68], [10, 72], [90, 70], [150, 82], [205, 88], [185, 55], [175, 25], [160, 5]],
      edges: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 0], [2, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10]] },
    { name: "Aries", from: [3, 21], until: [4, 19], bright: 1,
      nodes: [[0, 40], [80, 20], [115, 32], [125, 45]],
      edges: [[0, 1], [1, 2], [2, 3]] },
    { name: "Taurus", from: [4, 20], until: [5, 20], bright: 3,
      nodes: [[0, 5], [40, 28], [85, 46], [60, 58], [25, 72], [130, 52], [175, 40]],
      edges: [[0, 1], [1, 2], [2, 3], [3, 4], [2, 5], [5, 6]] },
    { name: "Gemini", from: [5, 21], until: [6, 20], bright: 4,
      nodes: [[0, 10], [70, 0], [140, 5], [200, 0], [0, 45], [75, 40], [145, 50], [205, 45], [170, 20], [175, 65]],
      edges: [[0, 1], [1, 2], [2, 3], [4, 5], [5, 6], [6, 7], [0, 4], [2, 8], [6, 9]] },
    { name: "Cancer", from: [6, 21], until: [7, 22], bright: 4,
      nodes: [[100, 40], [95, 15], [60, 0], [150, 70], [40, 80]],
      edges: [[0, 1], [1, 2], [0, 3], [0, 4]] },
    { name: "Leo", from: [7, 23], until: [8, 22], bright: 0,
      nodes: [[40, 70], [45, 45], [55, 25], [40, 10], [20, 0], [0, 15], [150, 25], [220, 45], [150, 55]],
      edges: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 7], [7, 8], [8, 0], [6, 8]] },
    { name: "Virgo", from: [8, 23], until: [9, 22], bright: 0,
      nodes: [[150, 85], [120, 55], [90, 35], [50, 30], [10, 20], [150, 35], [190, 15], [110, 15]],
      edges: [[0, 1], [1, 2], [2, 3], [3, 4], [1, 5], [5, 6], [2, 7]] },
    { name: "Libra", from: [9, 23], until: [10, 22], bright: 1,
      nodes: [[40, 55], [95, 10], [145, 45], [120, 85], [25, 90]],
      edges: [[0, 1], [1, 2], [2, 0], [2, 3], [0, 4]] },
    { name: "Scorpius", from: [10, 23], until: [11, 21], bright: 4,
      nodes: [[0, 0], [5, 25], [15, 48], [45, 30], [65, 35], [85, 45], [105, 60], [120, 80], [145, 90], [175, 88], [195, 75], [205, 55], [190, 40], [175, 45]],
      edges: [[0, 1], [1, 2], [1, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12], [12, 13]] },
    { name: "Sagittarius", from: [11, 22], until: [12, 21], bright: 1,
      nodes: [[10, 60], [40, 75], [45, 45], [70, 20], [95, 45], [135, 35], [140, 65], [100, 75]],
      edges: [[0, 1], [0, 2], [1, 2], [2, 3], [2, 4], [3, 4], [4, 5], [5, 6], [6, 7], [7, 4], [7, 1]] }
];

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function dayKey(month, day) { return month * 100 + day; }

function contains(sign, key) {
    const from = dayKey(sign.from[0], sign.from[1]);
    const until = dayKey(sign.until[0], sign.until[1]);
    return from <= until ? key >= from && key <= until : key >= from || key <= until;
}

function fitted(nodes) {
    const xs = nodes.map(n => n[0]), ys = nodes.map(n => n[1]);
    const minX = Math.min(...xs), minY = Math.min(...ys);
    const spanX = Math.max(...xs) - minX || 1, spanY = Math.max(...ys) - minY || 1;
    const scale = Math.min(BOX_WIDTH / spanX, BOX_HEIGHT / spanY);
    return nodes.map(([x, y]) => [(x - minX) * scale, (y - minY) * scale]);
}

function range(sign) {
    return MONTHS[sign.from[0] - 1] + " " + sign.from[1] + " – " + MONTHS[sign.until[0] - 1] + " " + sign.until[1];
}

function current(date) {
    const key = dayKey(date.getMonth() + 1, date.getDate());
    const sign = SIGNS.find(s => contains(s, key)) || SIGNS[0];
    const nodes = fitted(sign.nodes);
    const xs = nodes.map(n => n[0]), ys = nodes.map(n => n[1]);
    return {
        name: sign.name,
        range: range(sign),
        nodes: nodes,
        edges: sign.edges,
        bright: sign.bright,
        width: Math.max(...xs),
        height: Math.max(...ys)
    };
}
