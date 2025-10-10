# Custom CLI Tools

A collection of useful bash scripts for development and deployment tasks.

## Tools

### 🏗️ build-and-sign
Creates a clean, signed build package with integrity verification.

**Usage:**
```bash
./build-and-sign <source-folder> <output-prefix>
./build-and-sign --help
```

**Example:**
```bash
./build-and-sign my-project dragon-dance-build
```

**What it does:**
1. Creates a clean copy of the source folder (removes `node_modules`, `.git`, `.github`, `dist`)
2. Removes existing checksum and archive files (`*.md5`, `*.sha1`, `*.zip`)
3. Generates MD5 and SHA1 checksums for all files
4. Creates a ZIP archive of the clean copy
5. Cleans up temporary files

**Output:**
- `{prefix}.zip` - Clean archive of the project
- `{prefix}.md5` - MD5 checksums for all files
- `{prefix}.sha1` - SHA1 checksums for all files

### 🧹 copy-clean
Creates a clean copy of a project folder without development artifacts.

**Usage:**
```bash
./copy-clean <source-folder> <destination-folder>
./copy-clean --help
```

**Example:**
```bash
./copy-clean my-project clean-project
```

**What it does:**
1. Copies the source folder to destination
2. Removes development folders: `node_modules`, `.git`, `.github`, `dist`
3. Removes checksum and archive files: `*.md5`, `*.sha1`, `*.zip`

### 🎵 mp3-compressor
Converts MP3 files to compressed M4A format using AAC encoding.

**Usage:**
```bash
./mp3-compressor [input-file-or-directory] [output-directory]
./mp3-compressor --help
```

**Examples:**
```bash
# Process MP3s in current directory
./mp3-compressor

# Convert single MP3 file
./mp3-compressor song.mp3

# Convert single MP3 file to specific output directory
./mp3-compressor song.mp3 /output

# Process MP3s from specific input directory
./mp3-compressor /path/to/mp3s

# Process MP3s from input to specific output directory
./mp3-compressor /path/to/mp3s /path/to/output
```

**What it does:**
1. Converts MP3 files to M4A format (supports both single files and directories)
2. Uses mono audio (1 channel) with 96k AAC bitrate for smaller file sizes
3. Provides progress feedback during conversion
4. Requires `ffmpeg` to be installed

### 🎬 mp4-optimizer
Optimizes MP4 videos for Phaser 3 games with iOS compatibility.

**Usage:**
```bash
./mp4-optimizer [input-file-or-directory] [output-directory] [quality]
./mp4-optimizer --help
```

**Examples:**
```bash
# Optimize MP4s in current directory (web quality)
./mp4-optimizer

# Optimize single MP4 file
./mp4-optimizer video.mp4

# Optimize with specific quality and output directory
./mp4-optimizer video.mp4 /output high

# Optimize directory with web preset for iOS
./mp4-optimizer /videos /output web
```

**Quality Presets:**
- **web** - iOS-optimized for web games (default, CRF 25, 720p max)
- **high** - Best quality, larger files (CRF 18, 1080p max)
- **medium** - Balanced quality/size (CRF 23, 720p max)
- **low** - Smaller files, acceptable quality (CRF 28, 480p max)

**What it does:**
1. **iOS Web Compatibility:** H.264 baseline profile, AAC-LC audio, moov atom optimization
2. **Phaser 3 Optimization:** File size reduction, consistent frame rates, fast loading
3. **Performance Tuning:** 30fps max, resolution limits, hardware acceleration support
4. **Progressive Download:** Fast streaming start for web games
5. **File Size Reporting:** Shows compression ratio and size reduction

**iOS-Specific Features:**
- Maximum iOS Safari compatibility
- Memory-efficient encoding for mobile devices
- Progressive download support
- Pixel format optimization for hardware acceleration

### 🔏 signer
Generates integrity checksums for files in a folder.

**Usage:**
```bash
./signer <folder> <prefix>
./signer --help
```

**Example:**
```bash
./signer dist dragon-dance-build
```

**What it does:**
1. Generates MD5 checksums for all files in the specified folder
2. Generates SHA1 checksums for all files in the specified folder

**Output:**
- `{prefix}.md5` - MD5 checksums
- `{prefix}.sha1` - SHA1 checksums

## Requirements

- **bash** - All scripts are bash-based
- **ffmpeg** - Required for `mp3-compressor` and `mp4-optimizer`
- **Standard Unix tools** - `find`, `md5sum`, `sha1sum`, `zip`, `cp`, `rm`

## Getting Help

All scripts support help flags for detailed usage information:
```bash
./script-name --help
./script-name -h
```

## Installation

1. Clone this repository
2. Make scripts executable:
   ```bash
   chmod +x *
   ```
3. Optionally, add to your PATH for global access

## Use Cases

- **build-and-sign**: Preparing release packages with integrity verification
- **copy-clean**: Creating clean project copies for sharing or archiving
- **mp3-compressor**: Reducing audio file sizes for web or mobile applications
- **mp4-optimizer**: Optimizing videos for Phaser 3 games with iOS Safari compatibility
- **signer**: Generating checksums for file integrity verification
