# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **slide_reveal_screen**, a Flutter package that provides a customizable sliding UI component for revealing hidden side panels. Users can drag from screen edges to reveal left or right hidden pages with smooth animations and configurable thresholds.

## Development Commands

### Package Development
```bash
# Analyze code quality
flutter analyze

# Run tests
flutter test

# Check package publishing readiness
flutter pub publish --dry-run
```

### Example App Development
```bash
# Run the example app (from example directory)
cd example && flutter run

# Or run from root
flutter run -t example/lib/main.dart

# Build example app
cd example && flutter build apk
cd example && flutter build ios
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Architecture Overview

### Core Components

**Main Widget (`SlideRevealScreen`)**: Stateful widget that manages the sliding panel behavior with performance optimizations including lazy widget instantiation, dimension caching, and strategic RepaintBoundary usage.

**Controller (`SlideRevealController`)**: ChangeNotifier-based controller for programmatic control of the slide state, implementing the observer pattern for external state management.

**Progress Tracking (`SlideRevealProgress`)**: Data classes that track sliding progress and provide callbacks for state changes.

### Key Architectural Patterns

- **Stateful Widget + Controller Pattern**: External control via `SlideRevealController`
- **Builder Pattern**: Support for both direct widgets and builder functions
- **Performance Optimization**: Lazy instantiation, caching, and conditional rendering
- **Animation-Driven State**: Uses `AnimationController` with gesture detection
- **Resource Management**: Proper widget lifecycle with mounting/unmounting

### File Structure
```
lib/
├── slider_reveal_screen.dart          # Main export (entry point)
└── src/
    ├── slide_reveal_screen.dart       # Core widget (711 lines)
    ├── slide_reveal_controller.dart   # Animation controller
    └── slide_reveal_progress.dart     # Progress data classes
```

## Development Practices

### Code Quality
- Uses `flutter_lints` with strict linting rules
- Follows semantic versioning (currently v1.0.5)
- Git workflow with emoji commit prefixes
- Comprehensive changelog documentation

### Performance Considerations
- Hidden pages only built when needed (lazy instantiation)
- Edge dimensions cached to reduce calculations during animations
- Strategic use of RepaintBoundary for rendering optimization
- ValueListenableBuilder for efficient animation listening
- Memory-efficient widget lifecycle management

### API Design Principles
- **Flexibility**: Supports both widgets and builder functions
- **Control**: External controller for programmatic manipulation  
- **Customization**: Configurable thresholds, dimensions, and animations
- **Performance**: Optimized for smooth 60fps animations
- **Resource Efficiency**: Proper disposal and memory management

## Dependencies

- **Runtime**: Only Flutter SDK (no external dependencies)
- **Development**: `flutter_lints` for code quality
- **Target**: Flutter >=1.17.0, Dart ^3.7.0
- **Platforms**: All Flutter platforms supported

## Common Development Patterns

When adding features:
1. Follow the existing lazy instantiation pattern for performance
2. Use `ValueListenableBuilder` for animation-related UI updates  
3. Implement proper dispose() methods for controllers and animations
4. Cache expensive calculations in build methods
5. Use RepaintBoundary strategically around animated widgets

When modifying animations:
- All animations go through the central `AnimationController`
- Gesture detection is handled via `PanGestureRecognizer`
- State changes should trigger through the controller pattern
- Always consider performance impact of animation changes