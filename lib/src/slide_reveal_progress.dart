import 'package:slide_reveal_screen/src/slide_reveal_controller.dart';

/// Represents the current state of the slide reveal animation
enum RevealState {
  /// The panel is fully closed
  closed,

  /// The panel is in the process of opening
  opening,

  /// The panel is fully open
  open,

  /// The panel is in the process of closing
  closing,
}

/// Data class that contains information about the current slide reveal progress
class SlideRevealProgress {
  /// The side that is currently active (null if no side is active)
  final RevealSide? activeSide;

  /// The current animation value (between 0.0 and 1.0)
  final double value;

  /// The current state of the reveal animation
  final RevealState state;

  /// Whether the animation is currently in progress
  bool get isAnimating =>
      state == RevealState.opening || state == RevealState.closing;

  /// Whether any panel is currently open or opening
  bool get isOpen => state == RevealState.open || state == RevealState.opening;

  const SlideRevealProgress({
    required this.activeSide,
    required this.value,
    required this.state,
  });

  @override
  String toString() {
    return 'SlideRevealProgress(side: $activeSide, value: $value, state: $state)';
  }
}
