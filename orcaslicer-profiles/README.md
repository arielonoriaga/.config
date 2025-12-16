# OrcaSlicer Extracted Profiles

This directory contains extracted profiles from your OrcaSlicer configuration.

## PLA Filament Profile

- **PLA-profile.json** - Your custom PLA filament settings
  - Name: "My pla"
  - Inherits from: Generic PLA @System
  - Nozzle temperature: 200°C
  - Retraction length: 5.5mm
  - Retraction speed: 40mm/s
  - Z-hop: 0.5mm

- **PLA-profile.info** - Metadata for the PLA profile

## Printer Profiles

### Process Profile (Print Settings)
- **Printer-process-profile.json** - Your custom print process settings for Ender3v2
  - Name: "My Ender3v2"
  - Inherits from: 0.20mm Standard @Creality Ender3V2
  - Support type: tree(auto)
  - Infill pattern: gyroid
  - Various speed and acceleration settings

- **Printer-process-profile.info** - Metadata for the process profile

### Machine Profile (Printer Configuration)
- **Printer-machine-profile.json** - System machine profile for Creality Ender-3 V2
  - Printer model: Creality Ender-3 V2
  - Nozzle diameter: 0.4mm
  - Printable area: 220x220mm
  - Printable height: 250mm

## Source Location

Original profiles were extracted from:
`~/.var/app/io.github.softfever.OrcaSlicer/config/OrcaSlicer/`

## Usage

To restore these profiles:
1. Copy the `.json` files to the appropriate directories in OrcaSlicer's config folder
2. For filament: `user/default/filament/`
3. For process: `user/default/process/`
4. For machine: `system/Creality/machine/` (or create a custom one in `user/default/machine/`)
