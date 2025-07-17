# Adaptive MIDI Piano

<!-- embed-{$PATH} -->


An enhanced version of the MIDI Piano with responsive UI that adapts to different screen sizes and devices.

## Features

### Adaptive Layout
- **Responsive Key Count**: Automatically adjusts the number of piano keys based on screen width
- **Mobile Optimization**: Larger touch targets and simplified UI on mobile devices  
- **Desktop Enhancement**: More keys and detailed controls on larger screens

### Smart UI Elements
- **Dynamic Controls**: Octave selector, volume control, and real-time screen info
- **Contextual Labels**: Note labels appear on important keys (C, F) and all keys in mobile mode
- **Visual Feedback**: Color-coded activation with different colors for white/black keys

### Screen Size Adaptations
- **Mobile (< 768px width)**: 
  - 2-3 octaves (25-37 keys)
  - Larger touch targets (25x150px white keys)
  - Simplified layout with essential controls
  
- **Desktop (≥ 768px width)**:
  - 4-5 octaves (49-61 keys) 
  - Standard key sizes (20x120px white keys)
  - Full control panel with detailed info

### Technical Features
- **Real-time Adaptation**: Layout updates automatically on window resize
- **MIDI Input Support**: Full MIDI device compatibility
- **Volume Control**: Adjustable audio levels
- **Octave Selection**: Choose different pitch ranges
- **Performance Optimized**: Efficient key creation and cleanup

## Usage

1. **Connect MIDI Device** (optional): The piano will detect and display connected MIDI devices
2. **Click/Touch Keys**: Tap piano keys to play notes
3. **Adjust Octave**: Use the octave slider to change the key range
4. **Control Volume**: Use the volume slider to adjust audio levels
5. **Responsive Design**: Resize the window to see adaptive behavior

## MIDI Compatibility

Works with any MIDI input device that Godot supports, including:
- USB MIDI keyboards
- MIDI controllers
- Virtual MIDI devices

## Implementation Details

- Built with responsive Container nodes (VBoxContainer, HBoxContainer, PanelContainer)
- Uses dynamic scene instantiation for keys
- Implements proper cleanup and memory management
- Provides visual and audio feedback for all interactions

Language: GDScript
Renderer: Compatibility
