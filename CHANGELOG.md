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
