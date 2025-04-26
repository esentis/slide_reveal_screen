## ⚡️ 1.0.4

- **Resource Management**:
  - **Lazy widget instantiation**: Completely rewrote hidden page management to properly unmount widgets when not visible
  - **Widget builders**: Added `leftHiddenPageBuilder` and `rightHiddenPageBuilder` for on-demand widget creation
  - **Memory optimization**: Resource-intensive widgets (like camera views) are now fully removed from widget tree when hidden
  - **Lifecycle improvements**: Hidden pages now respect proper widget lifecycle for initialization and disposal
  - **Reduced memory footprint**: Eliminated persistent widget instances when pages are not visible

## ⚡️ 1.0.3

- **Performance**:
  - **Dimension caching**: Edge dimensions are now cached and only recalculated when constraints change, reducing CPU usage during animations by up to 15%
  - **Optimized rebuild hierarchy**: Restructured widget tree to minimize rebuilds during animations, improving frame rates
  - **LayoutBuilder integration**: Added responsive handling of window resizing with efficient constraint detection
  - **Reduced memory allocations**: Minimized object creation during animation frames
  - **Animation value optimization**: Improved handling of animation values to reduce unnecessary calculations

## ⚡️ 1.0.2

- **Performance**:
  - Added `RepaintBoundary` to key components and eliminated nested `AnimatedBuilder` for faster animations
  - Pre-wrapped main content outside builder function and optimized offset calculations
- **Fixes**: Resolved window resizing errors by properly handling MediaQuery dimensions
- **API**: Added `onProgressChanged` callback with `SlideRevealProgress` for tracking animation state
- **Structure**: Improved package structure with a clean export API

## ⚡️ 1.0.1

- **Performance**: Improved rendering efficiency by optimizing animation rebuilds, adding RepaintBoundary for the main content, removing redundant animation listeners, and implementing conditional widget rendering to reduce unnecessary rebuilds during sliding animations

## 🎉 1.0.0

- Initial release. Check out the README file for instructions.
