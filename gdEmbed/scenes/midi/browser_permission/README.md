# MIDI Browser Permission Demo

<!-- embed-{$PATH} -->


Understanding web MIDI permission requirements and proper handling of browser security constraints for cross-platform MIDI applications.

## Features

### 🌐 Platform Detection
- **Automatic Detection**: Identifies web vs desktop platforms
- **Conditional UI**: Shows permission controls only on web
- **Platform-Specific Messages**: Clear feedback about platform capabilities

### 🔒 Permission Management
- **User-Initiated Requests**: Proper permission request handling
- **Status Feedback**: Real-time permission status updates
- **Error Handling**: Graceful handling of permission denials

### 📱 Device Discovery
- **Device Enumeration**: Lists available MIDI input devices
- **Connection Status**: Real-time device connection updates
- **Device Information**: Shows device names and connection state

### 🎹 MIDI Testing
- **Live Input Testing**: Real-time MIDI message display
- **Message Logging**: Detailed log of MIDI events
- **Input Validation**: Confirms MIDI functionality

## Technical Implementation

### Browser Permission Model

Web browsers implement a permission-based security model for MIDI access:

```gdscript
# Check if running on web platform
if OS.has_feature("web"):
    # Web platform - permission required
    show_permission_ui()
else:
    # Desktop platform - direct access
    initialize_midi_directly()
```

### Permission Request Flow

1. **User Interaction Required**: Permission must be requested from a user gesture
2. **Browser Dialog**: Browser shows native permission dialog
3. **User Response**: User allows or denies access
4. **Status Handling**: App responds appropriately to permission result

### Error Handling

```gdscript
func request_midi_permission():
    OS.open_midi_inputs()
    
    # Check if permission was granted
    var devices = OS.get_connected_midi_inputs()
    if devices.size() >= 0:  # Even 0 devices means permission granted
        handle_permission_granted()
    else:
        handle_permission_denied()
```

## Browser Compatibility

| Browser | Web MIDI Support | Permission Model | Notes |
|---------|------------------|------------------|-------|
| **Chrome** | ✅ Full | User permission | Complete implementation |
| **Firefox** | ✅ Full | User permission | Complete implementation |
| **Edge** | ✅ Full | User permission | Complete implementation |
| **Safari** | ❌ None | Not applicable | Web MIDI not supported |

## Platform Differences

### Desktop Platforms
- **Direct Access**: No permission required
- **System Integration**: Uses OS MIDI drivers
- **Device Management**: Full device control available

### Web Platforms
- **Permission Required**: Explicit user consent needed
- **Sandboxed Environment**: Limited device access
- **Browser Dependent**: Implementation varies by browser

## Security Considerations

### Why Permissions Are Required

1. **Privacy Protection**: Prevent unauthorized device access
2. **Security**: Avoid malicious MIDI device exploitation
3. **User Control**: Give users choice over device access
4. **Standards Compliance**: Follow web security best practices

### Best Practices

1. **Clear Communication**: Explain why MIDI access is needed
2. **Graceful Fallback**: Provide alternatives when permission denied
3. **Status Indicators**: Show clear permission status
4. **Re-request Handling**: Allow permission re-requests if initially denied

## Implementation Tips

### User Experience
- Show clear instructions before requesting permission
- Provide immediate feedback after permission request
- Offer alternative input methods if MIDI unavailable
- Remember permission status across sessions

### Error Recovery
- Handle permission denial gracefully
- Provide clear error messages
- Offer retry mechanisms
- Test across different browsers

### Testing
- Test on actual web deployment (not local files)
- Verify behavior with different browsers
- Test permission denial scenarios
- Check device connection/disconnection handling

## Common Issues

### Permission Not Granted
**Symptoms**: No MIDI devices detected, permission dialog doesn't appear
**Solutions**:
- Ensure request comes from user interaction (button click)
- Check browser console for errors
- Verify browser supports Web MIDI
- Try refreshing page and requesting again

### Safari Compatibility
**Issue**: Safari doesn't support Web MIDI API
**Solutions**:
- Show clear message about browser limitations
- Suggest using Chrome, Firefox, or Edge
- Provide alternative input methods

### Local File Testing
**Issue**: Web MIDI may not work with file:// URLs
**Solutions**:
- Test on actual web server (even localhost)
- Use proper HTTPS deployment for production
- Check browser security settings

## Next Steps

After understanding browser permissions, explore:
- [Comprehensive MIDI Demo](../comprehensive_midi_demo/) for full MIDI implementation
- [Audio Systems](../../audio/) for audio processing techniques
- [Input Handling](../../input/) for other input methods

This demo provides the foundation for any web-based MIDI application in Godot, ensuring proper permission handling and cross-platform compatibility.