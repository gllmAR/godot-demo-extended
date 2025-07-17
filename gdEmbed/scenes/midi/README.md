# MIDI Systems

<!-- embed-{$PATH} -->


Explore comprehensive MIDI input handling, device management, and musical interface development in Godot. From basic MIDI input to advanced samplers with professional features.

<!-- start-replace-subnav -->
* [MIDI Browser Permission Demo](/godot-demo-extended/gdEmbed/scenes/midi/browser_permission/)
* [Comprehensive MIDI Demo](/godot-demo-extended/gdEmbed/scenes/midi/comprehensive_midi_demo/)
* [MIDI Piano](/godot-demo-extended/gdEmbed/scenes/midi/piano/)
* [Adaptive MIDI Piano](/godot-demo-extended/gdEmbed/scenes/midi/piano_adaptive/)
<!-- end-replace-subnav -->

## Overview

MIDI (Musical Instrument Digital Interface) provides a standardized protocol for digital musical instruments, audio equipment, and software to communicate. This collection demonstrates:

- **Device Management**: Detecting and selecting MIDI input devices
- **Real-Time Processing**: Low-latency MIDI message handling
- **Cross-Platform Support**: Desktop and web platform compatibility
- **Audio Synthesis**: Converting MIDI data to audio output
- **Professional Tools**: Debug logging, envelope shaping, polyphony management

## Categories

### 🔒 Browser Permission Demo
Understanding web MIDI permission requirements and proper handling of browser security constraints.

### 🎹 Comprehensive MIDI Demo  
Complete MIDI implementation featuring device selection, debug display, polyphonic sampler with ADSR envelope shaping.

## Key Concepts

### MIDI Protocol Fundamentals
- **Messages**: Note On/Off, Control Change, Pitch Bend, Aftertouch
- **Channels**: 16 independent MIDI channels (0-15)
- **Data Range**: 7-bit values (0-127) for most MIDI data
- **Timing**: Real-time message processing requirements

### Web MIDI Considerations
- **Permission Model**: Browser security requires explicit user permission
- **Browser Support**: Limited to modern browsers (Chrome, Firefox, Edge)
- **API Differences**: Platform-specific implementation details
- **Fallback Strategies**: Graceful degradation when MIDI unavailable

### Audio Synthesis Concepts
- **Polyphony**: Playing multiple notes simultaneously
- **Voice Management**: Efficient allocation of audio resources
- **Envelope Shaping**: ADSR (Attack, Decay, Sustain, Release) parameters
- **Sample Mapping**: Assigning audio samples to MIDI note ranges

## Technical Implementation

### Godot MIDI API
```gdscript
# Initialize MIDI system
OS.open_midi_inputs()

# Get connected devices
var devices = OS.get_connected_midi_inputs()

# Handle MIDI events
func _input(event):
	if event is InputEventMIDI:
		handle_midi_message(event)
```

### Message Processing
```gdscript
func handle_midi_message(midi_event: InputEventMIDI):
	match midi_event.message:
		MIDI_MESSAGE_NOTE_ON:
			play_note(midi_event.pitch, midi_event.velocity)
		MIDI_MESSAGE_NOTE_OFF:
			stop_note(midi_event.pitch)
		MIDI_MESSAGE_CONTROL_CHANGE:
			handle_controller(midi_event.controller_number, midi_event.controller_value)
```

### ADSR Envelope Implementation
```gdscript
func apply_adsr_envelope(audio_player: AudioStreamPlayer, velocity: float):
	var envelope_tween = create_tween()
	
	# Attack phase
	envelope_tween.tween_method(
		set_volume, 0.0, velocity, attack_time
	)
	
	# Decay to sustain
	envelope_tween.tween_method(
		set_volume, velocity, velocity * sustain_level, decay_time
	).set_delay(attack_time)
```

## Platform Support

| Platform | MIDI Input | Device Selection | Permission Required |
|----------|------------|------------------|---------------------|
| Windows  | ✅ Full    | ✅ Yes           | ❌ No               |
| macOS    | ✅ Full    | ✅ Yes           | ❌ No               |
| Linux    | ✅ Full    | ✅ Yes           | ❌ No               |
| Web      | ✅ Limited | ✅ Yes           | ✅ Yes              |

## Getting Started

1. **Start with Browser Permission** to understand web platform requirements
2. **Progress to Comprehensive Demo** for full MIDI implementation
3. **Connect a MIDI device** for best experience (virtual keyboard available for testing)
4. **Experiment with parameters** to understand audio synthesis concepts

## Common MIDI Controllers

### Standard Controller Numbers
- **CC 1**: Modulation wheel
- **CC 7**: Volume
- **CC 10**: Pan
- **CC 11**: Expression
- **CC 64**: Sustain pedal
- **CC 74**: Filter cutoff

### Note Ranges
- **MIDI Note 60**: Middle C (261.63 Hz)
- **Standard Range**: 0-127 (C-1 to G9)
- **Piano Range**: 21-108 (A0 to C8)

## Advanced Features

### Polyphony Management
- **Voice Stealing**: Oldest note replacement when limit reached
- **Priority Systems**: Note importance-based allocation
- **Resource Monitoring**: CPU and memory usage optimization

### Real-Time Performance
- **Low Latency**: Sub-10ms response times
- **Jitter Reduction**: Consistent timing performance
- **Buffer Management**: Optimal audio buffer sizes

### Professional Integration
- **DAW Compatibility**: Integration with Digital Audio Workstations
- **Plugin Architecture**: Extensible effects and instruments
- **MIDI Mapping**: Customizable controller assignments

This comprehensive MIDI system provides everything needed to create professional musical applications in Godot, from simple note triggers to complex synthesizers and samplers.
