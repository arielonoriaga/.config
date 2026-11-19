#!/usr/bin/env python3
import colorsys
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

from PIL import Image

HUE_BINS = 24
SAMPLE_SIZE = (96, 96)
BOLD_SATURATION = 0.9
MIN_PIXEL_SATURATION = 0.25
MIN_PIXEL_BRIGHTNESS = 0.15
MIN_COLORFUL_SHARE = 0.005
NEUTRAL_LED_COLOR = "FFFFFF"

MODE_BY_DEVICE_TYPE = {
    "Corsair": "direct",
    "Redragon": "static",
    "ZOTAC": "static",
    "AORUS": "direct",
}


def active_wallpaper() -> Path:
    out = subprocess.run(["hyprctl", "hyprpaper", "listactive"], capture_output=True, text=True).stdout
    for line in out.splitlines():
        if ": " in line:
            return Path(line.split(": ", 1)[1].strip())
    sys.exit("no active hyprpaper wallpaper")


def palette_led_color(image_path: Path) -> str | None:
    sidecar = image_path.with_suffix(".led")
    return sidecar.read_text().strip() if sidecar.exists() else None


def dominant_led_color(image_path: Path) -> str:
    image = Image.open(image_path).convert("RGB").resize(SAMPLE_SIZE)
    weights = defaultdict(float)
    sums = defaultdict(lambda: [0.0, 0.0, 0.0])
    colorful_pixels = 0
    for r, g, b in image.get_flattened_data():
        h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        if s < MIN_PIXEL_SATURATION or v < MIN_PIXEL_BRIGHTNESS:
            continue
        colorful_pixels += 1
        weight = s * v
        bin_index = int(h * HUE_BINS) % HUE_BINS
        weights[bin_index] += weight
        acc = sums[bin_index]
        acc[0] += r * weight
        acc[1] += g * weight
        acc[2] += b * weight
    pixel_count = SAMPLE_SIZE[0] * SAMPLE_SIZE[1]
    if colorful_pixels / pixel_count < MIN_COLORFUL_SHARE:
        return NEUTRAL_LED_COLOR
    def neighborhood(center: int) -> list[int]:
        return [(center + offset) % HUE_BINS for offset in (-1, 0, 1)]

    top = max(range(HUE_BINS), key=lambda i: sum(weights[j] for j in neighborhood(i)))
    top_weight = sum(weights[j] for j in neighborhood(top))
    r, g, b = (sum(sums[j][c] for j in neighborhood(top)) / top_weight / 255 for c in range(3))
    h, _, _ = colorsys.rgb_to_hsv(r, g, b)
    led = colorsys.hsv_to_rgb(h, BOLD_SATURATION, 1.0)
    return "".join(f"{round(c * 255):02X}" for c in led)


def device_args(color: str) -> list[str]:
    listing = subprocess.run(["openrgb", "-l"], capture_output=True, text=True).stdout
    args = []
    for line in listing.splitlines():
        index, _, name = line.partition(": ")
        if not index.isdigit():
            continue
        mode = next((m for key, m in MODE_BY_DEVICE_TYPE.items() if key in name), None)
        if mode:
            args += ["-d", index, "-m", mode, "-c", color]
    return args


def main() -> None:
    positional = [arg for arg in sys.argv[1:] if not arg.startswith("--")]
    image_path = Path(positional[0]) if positional else active_wallpaper()
    color = positional[1] if len(positional) > 1 else palette_led_color(image_path) or dominant_led_color(image_path)
    print(f"{image_path} -> #{color}")
    if "--dry-run" in sys.argv:
        return
    subprocess.run(["openrgb", *device_args(color)], capture_output=True, text=True, check=True)


if __name__ == "__main__":
    main()
