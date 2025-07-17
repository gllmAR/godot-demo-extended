# Comprehensive MIDI Demo

<!-- embed-{$PATH} -->


A complete demonstration of MIDI input handling in Godot, featuring device selection, real-time debug display, and a polyphonic sampler with ADSR envelope shaping.

## Features

### 🎛️ MIDI Device Management
- **Device Detection**: Automatically discovers connected MIDI devices
- **Device Selection**: Choose from available MIDI input devices
- **Web MIDI Support**: Handles browser permission requests for Web MIDI API
- **Cross-Platform**: Works on desktop (Linux, macOS, Windows) and web browsers

### 🐛 Real-Time MIDI Debug
- **Message Logging**: Live display of all incoming MIDI messages
- **Message Types**: Note On/Off, Control Change, Pitch Bend, Aftertouch
- **Detailed Info**: Channel, note number, velocity, controller values
- **Auto-Scrolling**: Keeps latest messages visible
- **Log Management**: Clear log functionality with automatic size limits

### 🔊 Polyphonic Sampler
- **Multi-Sample Playback**: Plays multiple notes simultaneously
- **Velocity Sensitivity**: Responds to MIDI velocity for dynamic expression
- **Polyphony Management**: Intelligent voice management (8-note polyphony)
- **Sample Mapping**: Maps MIDI notes to available audio samples
- **Volume Control**: Real-time volume adjustment

### 🎚️ ADSR Envelope Shaping
- **Attack**: 0-1000ms attack time for note onset
- **Decay**: 0-2000ms decay time to sustain level
- **Sustain**: 0-100% sustain level for held notes
- **Release**: 0-3000ms release time for note endings
- **Real-Time Control**: Adjust envelope parameters during playback
- **Per-Note Processing**: Each note gets its own envelope instance

### 🎹 Visual Feedback
- **Piano Keyboard**: Visual representation of piano keys
- **Key Highlighting**: Active notes highlighted in real-time
- **MIDI Status**: Connection and device status indicators
- **Envelope Display**: Visual representation of ADSR envelope

## Controls

### MIDI Input
- Connect any MIDI keyboard or controller
- All standard MIDI messages supported
- Channel-independent operation (responds to all channels)

### Virtual Keyboard (for testing without MIDI device)
- **White Keys**: A, S, D, F, G, H, J (C, D, E, F, G, A, B)
- **Black Keys**: W, E, T, Y, U (C#, D#, F#, G#, A#)

### MIDI Controller Mapping
- **CC 7**: Volume control (overrides volume slider)
- **CC 74**: Attack time control (0-1000ms)
- **Pitch Bend**: Real-time pitch modulation of all active notes

## Technical Implementation

### Web MIDI Considerations
- **Browser Support**: Chrome, Firefox, Edge (Safari not supported)
- **Permission Handling**: Automatic permission request on web platforms
- **Fallback**: Clear error messages when MIDI not available

### Audio Engine
- **Low Latency**: Optimized for real-time performance
- **Sample Management**: Efficient loading and playback of audio samples
- **Memory Management**: Automatic cleanup of finished notes
- **Thread Safety**: Proper handling of audio thread operations

### ADSR Implementation
- **Tween-Based**: Uses Godot's Tween system for smooth envelopes
- **Parallel Processing**: Multiple simultaneous envelopes
- **Interruption Handling**: Graceful handling of note retriggering
- **Volume Mapping**: Linear to dB conversion for natural-sounding volume curves

## Sample Audio Content

The demo includes sample audio files:
- **Mallet Sample**: Percussive mallet instrument sample
- **Synth Sample**: Synthesized dream pad sample
- **Generated Tones**: Runtime-generated sine waves for full note range

## Educational Value

This demo teaches:
- **MIDI Protocol**: Understanding MIDI message types and data structure
- **Real-Time Audio**: Low-latency audio processing techniques
- **Envelope Shaping**: Sound synthesis fundamentals
- **Polyphony Management**: Efficient voice allocation strategies
- **Cross-Platform Development**: Handling platform-specific features
- **Web Audio**: Modern web audio capabilities and limitations

## Next Steps

- Explore [Advanced Audio Player](../audio/advance_audioplayer/) for more audio processing
- Learn about [Input Handling](../input/) for other input methods
- Study [Animation Systems](../animation/) for visual feedback techniques

## Browser Compatibility

| Browser | MIDI Support | Notes |
|---------|--------------|-------|
| Chrome | ✅ Full | Complete Web MIDI API support |
| Firefox | ✅ Full | Complete Web MIDI API support |
| Edge | ✅ Full | Complete Web MIDI API support |
| Safari | ❌ None | Web MIDI API not supported |

## Troubleshooting

### No MIDI Devices Found
1. Ensure MIDI device is connected and recognized by your OS
2. Try refreshing devices
3. Check device power and USB connections
4. Restart the demo if needed

### Web Permission Issues
1. Click "Request MIDI Permission" button
2. Allow access when browser prompts
3. Refresh page if permission was previously denied
4. Check browser console for error messages

### Audio Issues
1. Check volume slider settings
2. Verify ADSR envelope settings aren't too extreme
3. Try reducing polyphony if experiencing dropouts
4. Check browser's audio settings and permissions
