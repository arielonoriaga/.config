#!/usr/bin/env python3
import html
import json
from pathlib import Path

ROOT = Path('/sys/devices/platform/msi-ec')

def read(name):
    try:
        return (ROOT / name).read_text().strip()
    except OSError:
        return None

def monitor():
    boost = read('cooler_boost')
    mode = read('fan_mode')
    speed = read('cpu/realtime_fan_speed')
    speed = f'{speed}%' if speed and speed.isdigit() else 'N/A'
    state = 'BOOST' if boost == 'on' else (mode.upper() if mode else 'N/A')
    details = [f'Cooler Boost: {boost or "unavailable"}',
               f'Fan mode: {mode or "unavailable"}',
               f'CPU fan: {speed} (driver-reported; not RPM)']
    for component in ('cpu', 'gpu'):
        temp = read(f'{component}/realtime_temperature')
        if temp and temp.isdigit():
            details.append(f'{component.upper()} temperature: {temp}°C')
    return {'text': f'󰈐 {speed} {state}',
            'tooltip': html.escape('\n'.join(details)),
            'class': 'unavailable' if boost not in ('on', 'off') else ('boost' if boost == 'on' else 'normal')}

if __name__ == '__main__':
    print(json.dumps(monitor()))
