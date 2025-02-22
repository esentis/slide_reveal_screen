import 'package:flutter/material.dart';

/// Represents the side that can be revealed when dragging.
enum RevealSide { left, right }

/// A controller that manages the state and animation for a draggable screen.
///
/// It holds an [AnimationController] to drive the animations when opening or closing
/// hidden screens (left or right). It also tracks which side is currently active.
class SlideRevealController extends ChangeNotifier {
  /// The internal [AnimationController] used to animate transitions.
  final AnimationController _animationController;

  /// The currently active side (if any) where a hidden page is shown.
  RevealSide? _side;

  /// Creates a [SlideRevealController] with the provided [vsync] (a [TickerProvider])
  /// and an optional animation [duration].
  SlideRevealController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
  }) : _animationController = AnimationController(
         vsync: vsync,
         lowerBound: 0,
         upperBound: 1,
         duration: duration,
       ) {
    /// Listen to the animation status to reset the side to null when the animation is dismissed by a fling.
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && _side != null) {
        _side = null;
        notifyListeners();
      }
    });
  }

  /// Provides access to the internal [AnimationController].
  AnimationController get controller => _animationController;

  /// Returns the currently active side (left/right) or `null` if the screen is closed.
  RevealSide? get side => _side;

  /// Opens the left hidden page.
  ///
  /// This method sets the active side to [RevealSide.left],
  /// notifies any listeners of the change, and starts the animation with a positive fling.
  void openLeft() {
    _side = RevealSide.left;
    notifyListeners();
    _animationController.fling(velocity: 1);
  }

  /// Opens the right hidden page.
  ///
  /// Sets the active side to [RevealSide.right],
  /// notifies listeners, and starts the animation.
  void openRight() {
    _side = RevealSide.right;
    notifyListeners();
    _animationController.fling(velocity: 1);
  }

  /// Closes any open hidden page.
  ///
  /// Resets the active side to `null`, notifies listeners,
  /// and reverses the animation with a negative fling.
  void close() {
    _side = null;
    notifyListeners();
    _animationController.fling(velocity: -1);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
