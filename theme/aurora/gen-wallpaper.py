#!/usr/bin/env python3
import random, sys, os

OUT = os.path.dirname(os.path.abspath(__file__))

SKY = [(0.0, "#2b1a4a"), (0.35, "#4a2d78"), (0.62, "#6e4597"), (0.82, "#a66fae"), (1.0, "#e2a3c4")]
RIDGES = [
    # base_y fraction, roughness, color, opacity
    (0.80, 0.15, "#8d5fa6", 0.55),
    (0.86, 0.13, "#6a4189", 0.80),
    (0.91, 0.10, "#4b2b68", 0.95),
    (0.96, 0.06, "#2f1a45", 1.0),
]


def ridge(rng, w, h, base, rough, steps=9):
    pts = [base * h, base * h]
    amp = rough * h
    for _ in range(steps):
        nxt = []
        for a, b in zip(pts, pts[1:]):
            nxt += [a, (a + b) / 2 + rng.uniform(-amp, amp)]
        nxt.append(pts[-1])
        pts = nxt
        amp *= 0.6
    n = len(pts) - 1
    d = " ".join(f"L{w * i / n:.1f},{y:.1f}" for i, y in enumerate(pts))
    return f"M0,{h} L0,{pts[0]:.1f} {d} L{w},{h} Z"


def mountains(rng, w, h):
    out = []
    for base, rough, color, op in RIDGES:
        out.append(f'<path d="{ridge(rng, w, h, base, rough)}" fill="{color}" fill-opacity="{op}"/>')
    out.append(f'<rect x="0" y="{h * 0.78:.0f}" width="{w}" height="{h * 0.22:.0f}" fill="url(#floor)"/>')
    return "\n".join(out)


def stars(rng, w, h):
    out = []
    for _ in range(int(w * h / 9000)):
        x, y = rng.uniform(0, w), rng.uniform(0, h * 0.7) ** 1.0
        r = rng.choice([0.6, 0.8, 1.0, 1.3])
        out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{r}" fill="#fff" fill-opacity="{rng.uniform(0.15, 0.7):.2f}"/>')
    for _ in range(14):
        x, y, s = rng.uniform(0, w), rng.uniform(0, h * 0.55), rng.uniform(3, 7)
        out.append(sparkle(x, y, s, rng.uniform(0.35, 0.8)))
    return "\n".join(out)


def sparkle(x, y, s, op):
    k = s * 0.18
    return (f'<path d="M{x},{y - s} Q{x + k},{y - k} {x + s},{y} Q{x + k},{y + k} {x},{y + s} '
            f'Q{x - k},{y + k} {x - s},{y} Q{x - k},{y - k} {x},{y - s} Z" fill="#fff" fill-opacity="{op:.2f}"/>')


def constellation(ox, oy):
    pts = [(0, 10), (45, 18), (75, 0), (105, 38), (130, 40), (165, 28), (190, 30), (205, 60), (220, 78), (60, 50), (40, 72)]
    edges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8), (1, 9), (9, 10), (3, 9)]
    lines = "".join(
        f'<line x1="{ox + pts[a][0]}" y1="{oy + pts[a][1]}" x2="{ox + pts[b][0]}" y2="{oy + pts[b][1]}"/>' for a, b in edges)
    dots = "".join(f'<circle cx="{ox + x}" cy="{oy + y}" r="2.2"/>' for x, y in pts)
    return (f'<ellipse cx="{ox + 115}" cy="{oy + 40}" rx="140" ry="55" fill="url(#halo)"/>'
            f'<g stroke="#fff" stroke-opacity="0.35" stroke-width="1">{lines}</g><g fill="#fff" fill-opacity="0.85">{dots}</g>')


def defs():
    stops = "".join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in SKY)
    return (f'<defs><linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">{stops}</linearGradient>'
            '<linearGradient id="floor" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#1c1030" stop-opacity="0"/>'
            '<stop offset="1" stop-color="#1c1030" stop-opacity="0.85"/></linearGradient>'
            '<radialGradient id="halo"><stop offset="0" stop-color="#fff" stop-opacity="0.10"/>'
            '<stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>'
            '<radialGradient id="glow" cx="0.5" cy="1" r="0.7"><stop offset="0" stop-color="#ffb8d9" stop-opacity="0.45"/>'
            '<stop offset="1" stop-color="#ffb8d9" stop-opacity="0"/></radialGradient></defs>')


def svg(w, h, body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{defs()}{body}</svg>'


def scene(w, h, seed):
    rng = random.Random(seed)
    sky = (f'<rect width="{w}" height="{h}" fill="url(#sky)"/>'
           f'<rect y="{h * 0.45:.0f}" width="{w}" height="{h * 0.55:.0f}" fill="url(#glow)"/>')
    star_layer = stars(rng, w, h)
    ridge_layer = mountains(random.Random(seed + 1), w, h)
    return svg(w, h, sky + star_layer + ridge_layer)


for name, (w, h) in {"landscape": (1920, 1080), "portrait": (1080, 1920)}.items():
    open(f"{OUT}/wallpaper-{name}.svg", "w").write(scene(w, h, seed=7))
