# Advanced Audio Player

<!-- embed-{$PATH} -->


An enhanced version of the professional audio player with additional features for advanced audio manipulation and analysis.

## Overview

This demo demonstrates:
- **Enhanced waveform visualization** with professional styling
- **Advanced loop controls** with multiple loop types
- **Precision time manipulation** with extreme slow-down capabilities
- **Professional transport controls** with industry-standard behavior
- **Real-time audio analysis** capabilities
- **Advanced file format support** for professional workflows

## Interactive Demo

## Key Features

### Enhanced Audio Controls
- **Extreme pitch range**: 0.000001x to 4.0x for detailed audio analysis
- **Professional loop types**: Forward, Ping-Pong with visual indicators
- **Sample-accurate positioning** for precise editing
- **Real-time waveform updates** during playback

### Advanced Interface
- **Separated loop controls**: Independent enable/disable and type selection
- **Visual feedback system** with color-coded status indicators
- **Keyboard shortcuts** for quick octave changes (+ / Page Up, - / Page Down)
- **Professional time display** with millisecond precision

### Technical Enhancements
- **Improved handle interaction** with larger hit areas
- **Smart loop region manipulation** maintaining relative distances
- **Enhanced drag feedback** with real-time value display
- **Optimized rendering** for smooth real-time updates

## Controls

### Transport Controls
- **▶ Play/Pause**: Toggle playback
- **⏹ Stop**: Stop and reset to beginning
- **🔄 Loop Enable**: Toggle loop on/off (yellow when active)
- **🔄/↔️ Loop Type**: Cycle between Forward (🔄) and Ping-Pong (↔️) modes

### Waveform Interaction
- **Click to seek**: Click anywhere on waveform to jump to position
- **Handle dragging**: Drag loop handles for precise control
  - **Green handle (top)**: Loop start point
  - **Red handle (bottom)**: Loop end point
  - **Blue handle (below)**: Move entire loop region
- **Right-click shortcuts**: Right-click for start, Shift+right-click for end

### Advanced Controls
- **VOL**: Volume control (-30dB to +6dB)
- **PITCH**: Extreme range pitch control (0.000001x to 4.0x)
- **Octave buttons**: 1/2, 1x, x2 for quick pitch changes
- **Keyboard shortcuts**: +/- or Page Up/Down for octave changes

## Technical Implementation

### Enhanced Loop System
```gdscript
# Separate loop enable and type controls
func _on_loop_type_pressed():
    current_loop_type = (current_loop_type + 1) % 2
    _update_loop_type_display()
    if is_looping:
        _apply_current_loop_type()
```

### Precision Controls
- **Sample-accurate loop points** with automatic validation
- **Minimum loop size enforcement** (1ms or 2 samples minimum)
- **Smart boundary checking** to prevent invalid configurations
- **Real-time constraint validation** during user interaction

