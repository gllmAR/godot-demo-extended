# Top-Down Movement

<!-- embed-{$PATH} -->


Learn 8-directional movement mechanics for top-down games.

## Features

- **8-directional movement** with WASD or arrow keys
- **Vector normalization** toggle to understand diagonal movement speed
- **Real-time analysis** of direction, magnitude, and speed
- **Visual grid** for spatial reference
- **Movement trail** for visual feedback

## Key Concepts

### Vector Normalization
When moving diagonally (e.g., pressing both W and D), the movement vector has a magnitude greater than 1. Without normalization, diagonal movement would be faster than cardinal directions.

```gdscript
# Raw input: diagonal vector (1, 1) has length ~1.414
var input = Vector2(1, 1)

# Normalized: (0.707, 0.707) has length 1.0
var normalized_input = input.normalized()
```

### 8-Directional Movement
Unlike 4-directional movement, this allows for smooth diagonal movement in addition to cardinal directions (up, down, left, right).

### Movement Analysis
The demo shows real-time data about:
- **Direction**: Angle in degrees
- **Magnitude**: Length of input vector
- **Speed**: Actual movement speed in pixels per second

## Controls

- **WASD** or **Arrow Keys**: Move in 8 directions
- **Toggle Normalization**: See the effect on diagonal movement speed
- **Speed Slider**: Adjust movement speed

## Try This

1. Move diagonally and observe the red warning when normalization is off
2. Toggle normalization to see how it affects movement consistency
3. Check the direction angle as you move in different directions
4. Notice how the trail shows your movement path

## Interactive Demo

This demo shows top-down movement including:
- WASD or arrow key movement
- Diagonal movement handling
- Character facing direction
- Smooth movement transitions

## Key Concepts

- **Vector Normalization**: Ensuring consistent movement speed
- **8-Directional Input**: Handling diagonal movement
- **Facing Direction**: Rotating character based on movement
- **Camera Following**: Keeping player centered

## Prerequisites

- [Basic Movement](../basic_movement/) - Understand fundamental movement

## Next Steps

- Alternative: [Platformer Movement](../platformer_movement/) for side-scrolling games
