# Animation State Machines

<!-- embed-{$PATH} -->


Master complex animation logic with state transitions and conditional playback.

## What You'll Learn

- Complete state machine implementation
- Complex state transition logic
- Timer-based and condition-based state changes
- Visual state feedback and UI integration
- Cooldown systems and charge mechanics

## Interactive Demo

This advanced state machine demo features:

### 6 Distinct States
1. **IDLE**: Default resting state with gentle breathing animation
2. **MOVING**: Walking/running with directional movement
3. **JUMPING**: Timed jump arc with physics-like movement
4. **ATTACKING**: Combat action with cooldown system
5. **DEFENDING**: Charge-up defensive stance with overcharge risk
6. **STUNNED**: Disabled state with recovery timer

### Advanced Features
- **Visual State Transitions**: Color-coded states with smooth transitions
- **Timer Systems**: State-specific timers and cooldowns
- **Conditional Logic**: Complex transition rules and requirements
- **Status Bars**: Real-time display of cooldowns, charges, and timers
- **Input Buffering**: Responsive controls with state-aware input
- **Visual Effects**: Scale, rotation, and color changes per state

### Controls & Interactions
- **Arrow Keys**: Move character (triggers MOVING state)
- **Spacebar**: Jump (enters JUMPING state with timed duration)
- **Z Key**: Attack (ATTACKING with 2-second cooldown)
- **X Key**: Hold to defend (DEFENDING with charge buildup)
- **State Transitions**: Watch automatic and manual state changes
- **Overcharge**: Hold defend too long to trigger STUNNED state

### Learning Objectives
- Understand state machine architecture
- Learn complex transition condition design
- Master timer-based state management
- See visual feedback integration
- Experience cooldown and charge systems
- Practice state-aware input handling

### Visual Feedback
- **Color Coding**: Each state has distinct colors
- **Scale Effects**: Dynamic scaling based on state
- **Rotation**: State-specific rotation effects
- **UI Panels**: Real-time state information display
- **Transition Tracking**: Previous state history
- **Timer Visualization**: Countdown displays for all systems

## Key Concepts

- **State Machine Architecture**: Enum-based state management
- **Transition Logic**: Enter, update, and exit state functions
- **Timer Management**: Per-state timers and global cooldowns
- **Visual State Representation**: UI integration with state changes
- **Input State Mapping**: Context-sensitive input handling
- **Charge/Cooldown Systems**: Resource management in state machines

## Prerequisites

- [Basic Animation](../basic_animation/) - Learn animation fundamentals
- [Tweening & Easing](../tweening/) - Understand smooth transitions
