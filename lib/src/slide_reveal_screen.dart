import 'package:flutter/material.dart';
import 'package:slide_reveal_screen/src/slide_reveal_controller.dart';
import 'package:slide_reveal_screen/src/slide_reveal_progress.dart';

/// A widget that provides a slideable screen with two hidden pages.
///
/// This widget allows you to reveal a left or right hidden page by dragging
/// from the edge of the screen.
///
/// The widget takes in the hidden pages, a main content widget, optional
/// placeholder widgets, and various configuration parameters.
class SlideRevealScreen extends StatefulWidget {
  /// The widget displayed as the left hidden page.
  /// Either this or [leftHiddenPageBuilder] must be provided.
  final Widget? leftHiddenPage;

  /// The widget displayed as the right hidden page.
  /// Either this or [rightHiddenPageBuilder] must be provided.
  final Widget? rightHiddenPage;

  /// An optional controller to manage the slide reveal widget.
  ///
  /// If no controller is provided, the widget creates its own.
  final SlideRevealController? controller;

  /// The main content of the screen.
  final Widget child;

  /// A placeholder widget to display for the left side if the hidden page isn't fully visible.
  ///
  /// This is when [leftWidgetVisibilityThreshold] is not reached.
  final Widget leftPlaceHolderWidget;

  /// A placeholder widget for the right side when its hidden page isn't fully visible.
  ///
  /// This is when [rightWidgetVisibilityThreshold] is not reached.
  final Widget rightPlaceHolderWidget;

  /// Whether the left hidden page is active (i.e., enabled).
  final bool isLeftActive;

  /// Whether the right hidden page is active.
  final bool isRightActive;

  /// The threshold (a value between 0 and 1) for revealing the left hidden page.
  final double leftWidgetVisibilityThreshold;

  /// The threshold for revealing the right hidden page.
  final double rightWidgetVisibilityThreshold;

  /// The velocity at which the user flings the screen to reveal the hidden page.
  ///
  /// This is used to determine whether to complete or reverse the animation.
  ///
  /// If the velocity is greater than this value, the animation will complete.
  final num flingVelocity;

  /// A builder function that returns the width of the left edge.
  ///
  /// The function takes in the [BuildContext] and a boolean flag indicating
  /// whether the left hidden page is active.
  final double Function(BuildContext context, bool isActive)?
  leftEdgeWidthBuilder;

  /// A builder function that returns the top padding of the left edge.
  ///
  /// The function takes in the [BuildContext] and a boolean flag indicating
  /// whether the left hidden page is active.
  final double Function(BuildContext context, bool isActive)?
  leftEdgeTopPaddingBuilder;

  /// A builder function that returns the bottom padding of the left edge.
  ///
  /// The function takes in the [BuildContext] and a boolean flag indicating
  /// whether the left hidden page is active.
  final double Function(BuildContext context, bool isActive)?
  leftEdgeBottomPaddingBuilder;

  /// A builder function that returns the width of the right edge.
  ///
  /// The function takes in the [BuildContext] and a boolean flag indicating
  /// whether the right hidden page is active.
  final double Function(BuildContext context, bool isActive)?
  rightEdgeWidthBuilder;

  /// A builder function that returns the top padding of the right edge.
  ///
  /// The function takes in the [BuildContext] and a boolean flag indicating
  /// whether the right hidden page is active.
  final double Function(BuildContext context, bool isActive)?
  rightEdgeTopPaddingBuilder;

  /// A builder function that returns the bottom padding of the right edge.
  ///
  /// The function takes in the [BuildContext] and a boolean flag indicating
  /// whether the right hidden page is active.
  final double Function(BuildContext context, bool isActive)?
  rightEdgeBottomPaddingBuilder;

  /// Callback that gets invoked whenever the slide reveal progress changes.
  final ValueChanged<SlideRevealProgress>? onProgressChanged;

  /// Callback that gets invoked when a user attempts to swipe on a disabled panel.
  /// Only triggered for edge-based gestures, not full-screen gestures.
  /// The callback receives the direction (left or right) where the gesture started.
  final ValueChanged<RevealSide>? onDisabledPanelGesture;

  /// A widget builder for the left hidden page.
  /// This allows for dynamic creation of the widget only when needed.
  /// Either this or [leftHiddenPage] must be provided.
  final Widget Function()? leftHiddenPageBuilder;

  /// A widget builder for the right hidden page.
  /// This allows for dynamic creation of the widget only when needed.
  /// Either this or [rightHiddenPage] must be provided.
  final Widget Function()? rightHiddenPageBuilder;

  /// **EXPERIMENTAL FEATURE**
  ///
  /// Enables full-screen horizontal gestures for slide reveal.
  /// When true, horizontal drags from anywhere on the screen trigger slide reveal.
  /// When false, only edge-based gestures work (default behavior).
  final bool enableFullScreenGestures;

  const SlideRevealScreen({
    super.key,
    this.leftHiddenPage,
    this.rightHiddenPage,
    required this.child,
    this.controller,
    this.isLeftActive = true,
    this.isRightActive = true,
    this.leftPlaceHolderWidget = const SizedBox.shrink(),
    this.rightPlaceHolderWidget = const SizedBox.shrink(),
    this.leftWidgetVisibilityThreshold = 0.1,
    this.rightWidgetVisibilityThreshold = 0.1,
    this.flingVelocity = 500,
    this.leftEdgeWidthBuilder,
    this.leftEdgeTopPaddingBuilder,
    this.leftEdgeBottomPaddingBuilder,
    this.rightEdgeWidthBuilder,
    this.rightEdgeTopPaddingBuilder,
    this.rightEdgeBottomPaddingBuilder,
    this.onProgressChanged,
    this.leftHiddenPageBuilder,
    this.rightHiddenPageBuilder,
    this.enableFullScreenGestures = false,
    this.onDisabledPanelGesture,
  }) : assert(
         leftHiddenPage != null || leftHiddenPageBuilder != null,
         'Either leftHiddenPage or leftHiddenPageBuilder must be provided',
       ),
       assert(
         rightHiddenPage != null || rightHiddenPageBuilder != null,
         'Either rightHiddenPage or rightHiddenPageBuilder must be provided',
       );

  @override
  SlideRevealScreenState createState() => SlideRevealScreenState();
}

/// The state class for [SlideRevealScreen].
///
/// This class manages the animation, gesture detection, and UI updates
/// for revealing the left or right hidden pages based on user interactions
/// or external controller changes.
class SlideRevealScreenState extends State<SlideRevealScreen>
    with SingleTickerProviderStateMixin {
  /// The [AnimationController] used for driving the animation.
  late AnimationController _animationController;

  /// The [SlideRevealController] managing the state of the widget.
  SlideRevealController? _slideRevealController;

  /// A flag that indicates whether the user is dragging from the left.
  /// When `null`, no drag direction has been determined yet.
  bool? _draggingFromLeft;

  // Used to detect the animation direction
  double _previousValue = 0.0;

  // Cached dimensions to optimize rebuilds
  BoxConstraints? _previousConstraints;

  // Cache for computed dimensions
  final Map<String, double> _dimensionCache = {};

  // Cache for computed layout values
  bool? _cachedIsLeft;
  bool? _cachedShowLeft;
  bool? _cachedShowRight;
  bool? _cachedIsAnimationActive;

  // Tracks whether widgets should be built based on visibility
  bool _shouldBuildLeftPage = false;
  bool _shouldBuildRightPage = false;

  // Track previous visibility to detect changes
  bool _wasLeftPageVisible = false;
  bool _wasRightPageVisible = false;

  @override
  void initState() {
    super.initState();

    // Use the externally provided controller if available.
    if (widget.controller != null) {
      _slideRevealController = widget.controller;
      _animationController = _slideRevealController!.controller;
      // Add a listener to respond to changes made externally.
      _slideRevealController!.addListener(_externalControllerListener);
    } else {
      // Otherwise, create a new controller.
      _slideRevealController = SlideRevealController(vsync: this);
      _animationController = _slideRevealController!.controller;
    }

    // Listen to changes in the animation status to reset the drag direction.
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _draggingFromLeft = null;
        // Clear cached values related to animation state
        _cachedIsLeft = null;
        _cachedShowLeft = null;
        _cachedShowRight = null;
        _cachedIsAnimationActive = null;

        // When fully closed, we know both pages should be unmounted
        _updateHiddenPagesVisibility(0.0);
      }
    });

    // Add a listener to report progress updates and manage widget visibility
    _animationController.addListener(_animationListener);
  }

  void _animationListener() {
    _updateHiddenPagesVisibility(_animationController.value);

    if (widget.onProgressChanged != null) {
      // Determine active side using the controller's side or local drag state.
      RevealSide? activeSide = _slideRevealController!.side;
      if (activeSide == null && _draggingFromLeft != null) {
        activeSide = _draggingFromLeft! ? RevealSide.left : RevealSide.right;
      }

      // Determine the RevealState based on the animation value.
      RevealState state;
      if (_animationController.value == 0.0) {
        state = RevealState.closed;
      } else if (_animationController.value == 1.0) {
        state = RevealState.open;
      } else {
        final double delta = _animationController.value - _previousValue;
        if (delta > 0) {
          state = RevealState.opening;
        } else if (delta < 0) {
          state = RevealState.closing;
        } else {
          state =
              activeSide != null ? RevealState.opening : RevealState.closing;
        }
      }

      _previousValue = _animationController.value;

      final progress = SlideRevealProgress(
        activeSide: activeSide,
        value: _animationController.value,
        state: state,
      );
      widget.onProgressChanged!(progress);
    }
  }

  /// Determines whether hidden pages should be built based on animation value
  /// and triggers appropriate callbacks when visibility changes
  void _updateHiddenPagesVisibility(double animationValue) {
    final bool isLeft = _getIsLeft();

    // Determine if pages should be visible based on animation and direction
    final bool leftPageVisible = animationValue > 0 && isLeft;
    final bool rightPageVisible = animationValue > 0 && !isLeft;

    // Check for visibility changes
    if (leftPageVisible != _wasLeftPageVisible ||
        rightPageVisible != _wasRightPageVisible) {
      setState(() {
        // If animation is completely closed, we can safely unmount both pages
        if (animationValue == 0) {
          _shouldBuildLeftPage = false;
          _shouldBuildRightPage = false;
        } else {
          // When a page becomes visible, we need to build it
          if (leftPageVisible) _shouldBuildLeftPage = true;
          if (rightPageVisible) _shouldBuildRightPage = true;

          // When a page is hidden and animation is complete, we can unmount it
          if (!leftPageVisible && animationValue == 0) {
            _shouldBuildLeftPage = false;
          }
          if (!rightPageVisible && animationValue == 0) {
            _shouldBuildRightPage = false;
          }
        }
      });

      _wasLeftPageVisible = leftPageVisible;
      _wasRightPageVisible = rightPageVisible;
    }
  }

  /// A listener that responds to external changes on the [SlideRevealController].
  ///
  /// It checks which side (left or right) is active based on the controller's
  /// [side] property and updates the local [_draggingFromLeft] flag accordingly.
  /// It then schedules a UI rebuild in the next frame.
  void _externalControllerListener() {
    if (_slideRevealController!.side != null) {
      _draggingFromLeft = _slideRevealController!.side == RevealSide.left;
      // Clear cached values when external controller changes direction
      _cachedIsLeft = null;
      _cachedShowLeft = null;
      _cachedShowRight = null;
    } else {
      _draggingFromLeft = null;
    }
    setState(() {});
  }

  /// Called when the user starts dragging on a disabled left panel.
  /// Triggers the disabled panel gesture callback.
  void _onDisabledLeftPanStart(DragStartDetails details) {
    if (widget.onDisabledPanelGesture != null) {
      widget.onDisabledPanelGesture!(RevealSide.left);
    }
  }

  /// Called when the user starts dragging on a disabled right panel.
  /// Triggers the disabled panel gesture callback.
  void _onDisabledRightPanStart(DragStartDetails details) {
    if (widget.onDisabledPanelGesture != null) {
      widget.onDisabledPanelGesture!(RevealSide.right);
    }
  }

  /// Called when the user drags on the left edge of the screen.
  ///
  /// This updates the animation value by calculating the change based on
  /// the drag delta and screen width.
  void _onLeftEdgePanUpdate(DragUpdateDetails details, double screenWidth) {
    // Check if drag direction has changed
    if (_draggingFromLeft == null || _draggingFromLeft == false) {
      _draggingFromLeft = true;
      // Reset the cache to force recalculation
      _cachedIsLeft = null;
      _cachedShowLeft = null;
      _cachedShowRight = null;
    }

    final double delta = details.delta.dx;
    final double newValue = _animationController.value + delta / screenWidth;
    _animationController.value = newValue.clamp(0.0, 1.0);
  }

  /// Called when the user finishes dragging on the left edge.
  ///
  /// It determines whether to complete or reverse the animation based on the
  /// current animation value and the velocity of the gesture.
  void _onLeftEdgePanEnd(DragEndDetails details) {
    if (_animationController.value > 0.5 ||
        details.velocity.pixelsPerSecond.dx > widget.flingVelocity) {
      _animationController.fling(velocity: 1);
    } else {
      _animationController.fling(velocity: -1);
    }
  }

  /// Called when the user drags on the right edge of the screen.
  ///
  /// Similar to the left edge update but inverts the delta calculation.
  void _onRightEdgePanUpdate(DragUpdateDetails details, double screenWidth) {
    // Check if drag direction has changed
    if (_draggingFromLeft == null || _draggingFromLeft == true) {
      _draggingFromLeft = false;
      // Reset the cache to force recalculation
      _cachedIsLeft = null;
      _cachedShowLeft = null;
      _cachedShowRight = null;
    }

    final double delta = details.delta.dx;
    final double newValue = _animationController.value - delta / screenWidth;
    _animationController.value = newValue.clamp(0.0, 1.0);
  }

  /// Called when the user finishes dragging on the right edge.
  ///
  /// It decides whether to complete or reverse the animation based on the
  /// current animation value and gesture velocity.
  void _onRightEdgePanEnd(DragEndDetails details) {
    if (_animationController.value > 0.5 ||
        details.velocity.pixelsPerSecond.dx < -widget.flingVelocity) {
      _animationController.fling(velocity: 1);
    } else {
      _animationController.fling(velocity: -1);
    }
  }

  /// Called when the user performs a full-screen horizontal drag.
  /// Determines the direction and updates the animation accordingly.
  void _onFullScreenPanUpdate(DragUpdateDetails details, double screenWidth) {
    final double delta = details.delta.dx;
    final bool isAnimationActive = _animationController.value > 0.0;
    final bool currentIsLeft = _getIsLeft();

    // Determine drag direction if not set
    if (_draggingFromLeft == null) {
      if (isAnimationActive) {
        // If a page is already revealed, allow dragging in the closing direction
        if (currentIsLeft && delta < 0) {
          // Left page is revealed, allow dragging left to close
          _draggingFromLeft = true;
          _cachedIsLeft = null;
          _cachedShowLeft = null;
          _cachedShowRight = null;
        } else if (!currentIsLeft && delta > 0) {
          // Right page is revealed, allow dragging right to close
          _draggingFromLeft = false;
          _cachedIsLeft = null;
          _cachedShowLeft = null;
          _cachedShowRight = null;
        } else {
          return; // Not a closing gesture
        }
      } else {
        // No page revealed, normal opening logic
        if (delta > 0) {
          // Dragging right (revealing left page)
          if (widget.isLeftActive) {
            _draggingFromLeft = true;
            _cachedIsLeft = null;
            _cachedShowLeft = null;
            _cachedShowRight = null;
          } else {
            return; // Left not active, ignore this gesture
          }
        } else if (delta < 0) {
          // Dragging left (revealing right page)
          if (widget.isRightActive) {
            _draggingFromLeft = false;
            _cachedIsLeft = null;
            _cachedShowLeft = null;
            _cachedShowRight = null;
          } else {
            return; // Right not active, ignore this gesture
          }
        } else {
          return; // No significant movement yet
        }
      }
    }

    // Handle gesture based on current state and direction
    if (_draggingFromLeft! && widget.isLeftActive) {
      // Left page gesture (opening or closing)
      final double newValue = _animationController.value + delta / screenWidth;
      _animationController.value = newValue.clamp(0.0, 1.0);
    } else if (!_draggingFromLeft! && widget.isRightActive) {
      // Right page gesture (opening or closing)
      final double newValue = _animationController.value - delta / screenWidth;
      _animationController.value = newValue.clamp(0.0, 1.0);
    }
  }

  /// Called when the user finishes a full-screen horizontal drag.
  void _onFullScreenPanEnd(DragEndDetails details) {
    if (_draggingFromLeft == null) return;

    final double velocity = details.velocity.pixelsPerSecond.dx;

    if (_draggingFromLeft!) {
      // Left page reveal logic
      if (_animationController.value > 0.5 || velocity > widget.flingVelocity) {
        _animationController.fling(velocity: 1);
      } else {
        _animationController.fling(velocity: -1);
      }
    } else {
      // Right page reveal logic
      if (_animationController.value > 0.5 ||
          velocity < -widget.flingVelocity) {
        _animationController.fling(velocity: 1);
      } else {
        _animationController.fling(velocity: -1);
      }
    }
  }

  /// Gets a cached dimension or computes it if not available.
  /// Automatically invalidates cache when constraints change.
  double _getCachedDimension(
    String key,
    double Function() computeFn,
    BoxConstraints constraints, [
    bool forceRecompute = false,
  ]) {
    // Check if constraints have changed or forced recompute
    if (_previousConstraints != constraints || forceRecompute) {
      // Only clear the cache if constraints changed
      if (_previousConstraints != constraints) {
        _dimensionCache.clear();
        _previousConstraints = constraints;
      }
    }

    // Return cached value or compute new one
    if (!_dimensionCache.containsKey(key)) {
      _dimensionCache[key] = computeFn();
    }

    return _dimensionCache[key]!;
  }

  // Build the left hidden page with lazy instantiation
  Widget _buildLeftHiddenPage(
    double screenWidth,
    bool isLeft,
    BoxConstraints constraints,
  ) {
    if (!_shouldBuildLeftPage) {
      return const SizedBox.shrink(); // Don't build at all if not needed
    }

    Widget pageContent =
        (_animationController.value > widget.leftWidgetVisibilityThreshold)
            ? widget.leftHiddenPageBuilder != null
                ? widget.leftHiddenPageBuilder!() // Use builder if available
                : widget.leftHiddenPage! // Otherwise use the direct widget
            : widget.leftPlaceHolderWidget;

    // Add gesture detection to hidden page if full-screen gestures are enabled
    if (widget.enableFullScreenGestures) {
      pageContent = _FullScreenGestureHandler(
        screenWidth: screenWidth,
        onHorizontalPanUpdate:
            (details) => _onFullScreenPanUpdate(details, screenWidth),
        onHorizontalPanEnd: _onFullScreenPanEnd,
        isLeftActive: widget.isLeftActive,
        isRightActive: widget.isRightActive,
        child: pageContent,
      );
    }

    return Positioned.fill(
      child: RepaintBoundary(
        child: Transform.translate(
          offset: Offset(
            -screenWidth / 2 + (_animationController.value * (screenWidth / 2)),
            0,
          ),
          child: pageContent,
        ),
      ),
    );
  }

  // Build the right hidden page with lazy instantiation
  Widget _buildRightHiddenPage(
    double screenWidth,
    bool isLeft,
    BoxConstraints constraints,
  ) {
    if (!_shouldBuildRightPage) {
      return const SizedBox.shrink(); // Don't build at all if not needed
    }

    Widget pageContent =
        (_animationController.value > widget.rightWidgetVisibilityThreshold)
            ? widget.rightHiddenPageBuilder != null
                ? widget.rightHiddenPageBuilder!() // Use builder if available
                : widget.rightHiddenPage! // Otherwise use the direct widget
            : widget.rightPlaceHolderWidget;

    // Add gesture detection to hidden page if full-screen gestures are enabled
    if (widget.enableFullScreenGestures) {
      pageContent = _FullScreenGestureHandler(
        screenWidth: screenWidth,
        onHorizontalPanUpdate:
            (details) => _onFullScreenPanUpdate(details, screenWidth),
        onHorizontalPanEnd: _onFullScreenPanEnd,
        isLeftActive: widget.isLeftActive,
        isRightActive: widget.isRightActive,
        child: pageContent,
      );
    }

    return Positioned.fill(
      child: RepaintBoundary(
        child: Transform.translate(
          offset: Offset(
            screenWidth / 2 - (_animationController.value * (screenWidth / 2)),
            0,
          ),
          child: pageContent,
        ),
      ),
    );
  }

  // Build the main content with optimized transform
  Widget _buildMainContent(
    double screenWidth,
    bool isLeft,
    BoxConstraints constraints,
  ) {
    final double contentOffset =
        isLeft
            ? _animationController.value * screenWidth
            : -_animationController.value * screenWidth;

    Widget content = RepaintBoundary(child: widget.child);

    // Wrap with gesture detection if full-screen gestures are enabled
    if (widget.enableFullScreenGestures) {
      content = _FullScreenGestureHandler(
        screenWidth: screenWidth,
        onHorizontalPanUpdate:
            (details) => _onFullScreenPanUpdate(details, screenWidth),
        onHorizontalPanEnd: _onFullScreenPanEnd,
        isLeftActive: widget.isLeftActive,
        isRightActive: widget.isRightActive,
        child: content,
      );
    }

    return Transform.translate(
      offset: Offset(contentOffset, 0),
      child: content,
    );
  }

  // Build the left edge gesture detector with cached dimensions
  Widget _buildLeftEdgeGestureDetector(
    double screenWidth,
    bool isLeft,
    bool isAnimationActive,
    bool showRight,
    BoxConstraints constraints,
  ) {
    // Cache computation with unique keys
    final String widthKey = 'leftEdgeWidth_${isLeft}_${constraints.maxWidth}';
    final String topKey = 'leftEdgeTop_${isLeft}_${constraints.maxHeight}';
    final String bottomKey =
        'leftEdgeBottom_${isLeft}_${constraints.maxHeight}';

    final double computedLeftEdgeWidth = _getCachedDimension(
      widthKey,
      () => widget.leftEdgeWidthBuilder?.call(context, isLeft) ?? 30,
      constraints,
    );

    final double computedLeftEdgeTop = _getCachedDimension(
      topKey,
      () => widget.leftEdgeTopPaddingBuilder?.call(context, isLeft) ?? 0,
      constraints,
    );

    final double computedLeftEdgeBottom = _getCachedDimension(
      bottomKey,
      () => widget.leftEdgeBottomPaddingBuilder?.call(context, isLeft) ?? 0,
      constraints,
    );

    return Positioned(
      top: computedLeftEdgeTop,
      left: isAnimationActive && isLeft ? null : 0,
      right: isAnimationActive && isLeft ? 0 : null,
      bottom: computedLeftEdgeBottom,
      width: showRight ? 0 : computedLeftEdgeWidth,
      child: ColoredBox(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: widget.isLeftActive ? null : _onDisabledLeftPanStart,
          onPanUpdate:
              widget.isLeftActive
                  ? (details) => _onLeftEdgePanUpdate(details, screenWidth)
                  : null,
          onPanEnd: widget.isLeftActive ? _onLeftEdgePanEnd : null,
        ),
      ),
    );
  }

  // Build the right edge gesture detector with cached dimensions
  Widget _buildRightEdgeGestureDetector(
    double screenWidth,
    bool isLeft,
    bool isAnimationActive,
    bool showLeft,
    BoxConstraints constraints,
  ) {
    // Cache computation with unique keys
    final String widthKey = 'rightEdgeWidth_${!isLeft}_${constraints.maxWidth}';
    final String topKey = 'rightEdgeTop_${!isLeft}_${constraints.maxHeight}';
    final String bottomKey =
        'rightEdgeBottom_${!isLeft}_${constraints.maxHeight}';

    final double computedRightEdgeWidth = _getCachedDimension(
      widthKey,
      () => widget.rightEdgeWidthBuilder?.call(context, !isLeft) ?? 30,
      constraints,
    );

    final double computedRightEdgeTop = _getCachedDimension(
      topKey,
      () => widget.rightEdgeTopPaddingBuilder?.call(context, !isLeft) ?? 0,
      constraints,
    );

    final double computedRightEdgeBottom = _getCachedDimension(
      bottomKey,
      () => widget.rightEdgeBottomPaddingBuilder?.call(context, !isLeft) ?? 0,
      constraints,
    );

    return Positioned(
      top: computedRightEdgeTop,
      left: isAnimationActive && !isLeft ? 0 : null,
      right: isAnimationActive && !isLeft ? null : 0,
      bottom: computedRightEdgeBottom,
      width: showLeft ? 0 : computedRightEdgeWidth,
      child: ColoredBox(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: widget.isRightActive ? null : _onDisabledRightPanStart,
          onPanUpdate:
              widget.isRightActive
                  ? (details) => _onRightEdgePanUpdate(details, screenWidth)
                  : null,
          onPanEnd: widget.isRightActive ? _onRightEdgePanEnd : null,
        ),
      ),
    );
  }

  // Get or compute animation-dependent state
  bool _getIsLeft() {
    // Always check if dragging direction has changed
    bool newIsLeft =
        _draggingFromLeft ?? (_slideRevealController?.side == RevealSide.left);

    // Update cache when value changes or not yet set
    if (_cachedIsLeft == null || _cachedIsLeft != newIsLeft) {
      _cachedIsLeft = newIsLeft;
      // Force recalculation of dependent states
      _cachedShowLeft = null;
      _cachedShowRight = null;
    }

    return _cachedIsLeft!;
  }

  bool _getIsAnimationActive(double animationValue) {
    bool newIsActive = animationValue > 0;

    // Update cache when animation state changes
    if (_cachedIsAnimationActive == null ||
        _cachedIsAnimationActive != newIsActive) {
      _cachedIsAnimationActive = newIsActive;
      // Force recalculation of dependent values
      _cachedShowLeft = null;
      _cachedShowRight = null;
    }

    return _cachedIsAnimationActive!;
  }

  bool _getShowLeft(bool isLeft, bool isAnimationActive) {
    _cachedShowLeft ??= isAnimationActive && isLeft;
    return _cachedShowLeft!;
  }

  bool _getShowRight(bool isLeft, bool isAnimationActive) {
    _cachedShowRight ??= isAnimationActive && !isLeft;
    return _cachedShowRight!;
  }

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder to respond to size changes
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen width from constraints
        final double screenWidth = constraints.maxWidth;

        // Check if constraints have changed
        final bool constraintsChanged = _previousConstraints != constraints;
        if (constraintsChanged) {
          // Clear cached values when constraints change
          _dimensionCache.clear();
          _previousConstraints = constraints;
        }

        return ValueListenableBuilder<double>(
          valueListenable: _animationController,
          builder: (context, animationValue, _) {
            // Cache and compute state values
            final bool isLeft = _getIsLeft();
            final bool isAnimationActive = _getIsAnimationActive(
              animationValue,
            );
            final bool showLeft = _getShowLeft(isLeft, isAnimationActive);
            final bool showRight = _getShowRight(isLeft, isAnimationActive);

            return Stack(
              children: [
                _buildLeftHiddenPage(screenWidth, isLeft, constraints),

                _buildRightHiddenPage(screenWidth, isLeft, constraints),
                IgnorePointer(
                  ignoring: _animationController.value != 0.0,
                  child: _buildMainContent(screenWidth, isLeft, constraints),
                ),
                // Edge-based gesture detection (only when full-screen gestures are disabled)
                if (!widget.enableFullScreenGestures) ...[
                  // Always build left edge detector (handles both active and disabled states)
                  _buildLeftEdgeGestureDetector(
                    screenWidth,
                    isLeft,
                    isAnimationActive,
                    showRight,
                    constraints,
                  ),

                  // Always build right edge detector (handles both active and disabled states)
                  _buildRightEdgeGestureDetector(
                    screenWidth,
                    isLeft,
                    isAnimationActive,
                    showLeft,
                    constraints,
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Clean up all resources
    _animationController.removeListener(_animationListener);

    // Clear caches
    _dimensionCache.clear();

    if (widget.controller == null) {
      _slideRevealController?.dispose();
    } else {
      _slideRevealController?.removeListener(_externalControllerListener);
    }
    super.dispose();
  }
}

/// A specialized widget that handles full-screen horizontal gestures
/// without interfering with tap events or vertical scrolling
class _FullScreenGestureHandler extends StatefulWidget {
  final double screenWidth;
  final Function(DragUpdateDetails) onHorizontalPanUpdate;
  final Function(DragEndDetails) onHorizontalPanEnd;
  final bool isLeftActive;
  final bool isRightActive;
  final Widget child;

  const _FullScreenGestureHandler({
    required this.screenWidth,
    required this.onHorizontalPanUpdate,
    required this.onHorizontalPanEnd,
    required this.isLeftActive,
    required this.isRightActive,
    required this.child,
  });

  @override
  _FullScreenGestureHandlerState createState() =>
      _FullScreenGestureHandlerState();
}

class _FullScreenGestureHandlerState extends State<_FullScreenGestureHandler> {
  bool _isTrackingHorizontalGesture = false;
  Offset? _startPosition;
  double _totalDeltaX = 0.0;
  DateTime? _lastMoveTime;
  double _lastDeltaX = 0.0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Stack(
        children: [
          // When horizontal gesture is active, absorb pointer events from the child
          // This prevents ListView vertical scrolling during horizontal slide gestures
          AbsorbPointer(
            absorbing: _isTrackingHorizontalGesture,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _startPosition = event.position;
    _isTrackingHorizontalGesture = false;
    _totalDeltaX = 0.0;
    _lastMoveTime = DateTime.now();
    _lastDeltaX = 0.0;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_startPosition == null) return;

    final delta = event.delta;
    final deltaX = delta.dx;

    // Track velocity
    _lastDeltaX = deltaX;
    _lastMoveTime = DateTime.now();

    // Accumulate total horizontal movement
    _totalDeltaX += deltaX;

    if (!_isTrackingHorizontalGesture) {
      // Check if this is clearly a horizontal gesture
      final horizontalDistance = _totalDeltaX.abs();
      final verticalDistance = (event.position.dy - _startPosition!.dy).abs();

      // Use more lenient thresholds for gesture detection
      // This allows both opening and closing gestures to be detected easily
      if (horizontalDistance > 5.0 && horizontalDistance > verticalDistance) {
        // Always allow horizontal gestures - the pan update logic will determine validity
        setState(() {
          _isTrackingHorizontalGesture = true;
        });
        // Send a synthetic pan start
        widget.onHorizontalPanUpdate(
          DragUpdateDetails(
            globalPosition: event.position,
            delta: Offset(_totalDeltaX, 0), // Send accumulated delta
            localPosition: event.localPosition,
            sourceTimeStamp: event.timeStamp,
          ),
        );
      }
    } else {
      // We're already tracking, send the update
      widget.onHorizontalPanUpdate(
        DragUpdateDetails(
          globalPosition: event.position,
          delta: delta,
          localPosition: event.localPosition,
          sourceTimeStamp: event.timeStamp,
        ),
      );
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isTrackingHorizontalGesture) {
      // Calculate rough velocity based on last movement
      double velocityX = 0.0;
      if (_lastMoveTime != null) {
        final timeDiff =
            DateTime.now().difference(_lastMoveTime!).inMilliseconds;
        if (timeDiff > 0 && timeDiff < 100) {
          // Only use recent movements
          velocityX = _lastDeltaX * 1000 / timeDiff; // pixels per second
        }
      }

      widget.onHorizontalPanEnd(
        DragEndDetails(
          velocity: Velocity(pixelsPerSecond: Offset(velocityX, 0)),
          globalPosition: event.position,
          localPosition: event.localPosition,
        ),
      );
    }
    _reset();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _reset();
  }

  void _reset() {
    if (mounted) {
      setState(() {
        _startPosition = null;
        _isTrackingHorizontalGesture = false;
        _totalDeltaX = 0.0;
        _lastMoveTime = null;
        _lastDeltaX = 0.0;
      });
    }
  }
}
