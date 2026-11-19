#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

GENERATOR = Path(__file__).with_name("gen-wallpaper.py")
OUT = Path.home() / "Pictures" / "Backgrounds" / "aurora"
SIZES = {"landscape": (1920, 1080), "portrait": (1080, 1920)}
DEFAULT_SEEDS = [11, 23, 5, 42, 77, 128]
BASE_GLOW = "#ffb8d9"
BASE_FLOOR = "#1c1030"
RIDGE_SHAPE = [(0.80, 0.15, 0.55), (0.86, 0.13, 0.80), (0.91, 0.10, 0.95), (0.96, 0.06, 1.0)]

PALETTES = {
    "purple": (["#2b1a4a", "#4a2d78", "#6e4597", "#a66fae", "#e2a3c4"],
               ["#8d5fa6", "#6a4189", "#4b2b68", "#2f1a45"], "#ffb8d9", "#1c1030", "#9B30FF"),
    "sunset": (["#1a1033", "#3d1d4f", "#8a3b5c", "#d8644a", "#f5a85c"],
               ["#b0524f", "#7d3550", "#4f2140", "#2a1230"], "#ffc18a", "#1a0d1f", "#FF6A1A"),
    "teal": (["#06141f", "#0b2a3d", "#11475a", "#1f7a80", "#7fd1c4"],
             ["#2a6f78", "#1b4d5a", "#113546", "#0a2230"], "#9ff5e6", "#06141f", "#19E6D2"),
    "ocean": (["#050a24", "#0d1a4a", "#1d3378", "#3a5cae", "#8fb3f0"],
              ["#2c4a8f", "#1d336b", "#13234d", "#0a1430"], "#a8c8ff", "#050a20", "#1A5CFF"),
    "emerald": (["#04130f", "#0a2a22", "#145040", "#2e8a5f", "#a6e8a0"],
                ["#2a6b50", "#1c4d3b", "#12352a", "#0a1f19"], "#b8ffcf", "#04130f", "#19FF6E"),
    "crimson": (["#1a0509", "#3d0a16", "#6e1426", "#b02c3b", "#f07a6a"],
                ["#8a2a38", "#621c2a", "#43121d", "#260a10"], "#ffb0a0", "#1a0509", "#FF1A3C"),
}


def load_generator() -> dict:
    source = GENERATOR.read_text()
    namespace = {"__file__": str(GENERATOR)}
    exec(source[: source.index("\nfor name, (w, h)")], namespace)
    return namespace


def render(gen: dict, palette: str, seed: int) -> None:
    sky, ridges, glow, floor, led = PALETTES[palette]
    stops = [0.0, 0.35, 0.62, 0.82, 1.0]
    gen["SKY"] = list(zip(stops, sky))
    gen["RIDGES"] = [(base, rough, color, opacity) for (base, rough, opacity), color in zip(RIDGE_SHAPE, ridges)]
    for orientation, (w, h) in SIZES.items():
        rendered = gen["scene"](w, h, seed)
        full = rendered[0] if isinstance(rendered, tuple) else rendered
        full = full.replace(BASE_GLOW, glow).replace(BASE_FLOOR, floor)
        svg_path = OUT / f"{palette}-{seed}-{orientation}.svg"
        svg_path.write_text(full)
        subprocess.run(["rsvg-convert", "-o", str(svg_path.with_suffix(".png")), str(svg_path)], check=True)
        svg_path.unlink()
    (OUT / f"{palette}-{seed}-landscape.led").write_text(led.lstrip("#") + "\n")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    seeds = [int(arg) for arg in sys.argv[1:]] or DEFAULT_SEEDS
    gen = load_generator()
    for palette in PALETTES:
        for seed in seeds:
            render(gen, palette, seed)
            print(OUT / f"{palette}-{seed}-landscape.png")


if __name__ == "__main__":
    main()
