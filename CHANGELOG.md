## ✨ 1.0.8

- **New Features**
  - **Disabled panel gesture callback**: Added `onDisabledPanelGesture` parameter to detect swipe attempts on disabled panels
  - **Direction awareness**: Callback includes `RevealSide` parameter indicating which edge was swiped (left or right)
  - **Edge-only detection**: Only triggers for edge-based gestures, preventing false positives from full-screen interactions
  - **Modal sheet integration**: Perfect for prompting users with modal sheets when they try to access disabled functionality
- **API**
  - Added `onDisabledPanelGesture: ValueChanged<RevealSide>?` parameter
  - Uses existing `RevealSide` enum for direction information
- **Backwards Compatibility**
  - Fully backwards compatible - optional parameter with no breaking changes
  - Existing gesture behavior unchanged when parameter is not provided

## ✨ 1.0.7

- **New Features**
  - **Full-screen gestures**: Added `enableFullScreenGestures` parameter for horizontal drags from anywhere on screen
  - **ListView compatibility**: Vertical scrolling works normally while horizontal drags trigger slide reveal
  - **PageView compatibility**: When `isRightActive: false`, PageView handles right swipes while slide reveal handles left swipes
  - **Bidirectional gestures**: Revealed hidden pages can now be dragged back to close in the opposite direction
  - **Smart gesture detection**: Automatic vertical scroll prevention when horizontal gesture wins the gesture arena
- **API**
  - Added `enableFullScreenGestures: bool` parameter (defaults to `true` for new feature, `false` maintains original behavior)
- **Backwards Compatibility**
  - Fully backwards compatible - existing implementations work unchanged when `enableFullScreenGestures: false`
  - Original edge-based gesture behavior preserved as fallback

## 🐛 1.0.6

- **Bug fixes**
  - Prevents interaction with main content when sliding is in progress by wrapping it in `AbsorbPointer`

## 🐛 1.0.5

- **Bug fixes**
  - Fixes rendering issue when using `showCupertinoSheet`
- **API**
  - `leftPlaceHolderWidget` & `rightPlaceHolderWidget` are optional, but if not provided their `builder` methods should be provided.

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
