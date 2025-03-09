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
  final Widget leftHiddenPage;

  /// The widget displayed as the right hidden page.
  final Widget rightHiddenPage;

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

  /// This will color the region that can be dragged to reveal the hidden pages.
  ///
  /// Defaults to false.
  final bool showDebugColors;

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

  const SlideRevealScreen({
    super.key,
    required this.leftHiddenPage,
    required this.rightHiddenPage,
    required this.child,
    this.controller,
    this.isLeftActive = true,
    this.isRightActive = true,
    this.leftPlaceHolderWidget = const SizedBox.shrink(),
    this.rightPlaceHolderWidget = const SizedBox.shrink(),
    this.leftWidgetVisibilityThreshold = 0.1,
    this.rightWidgetVisibilityThreshold = 0.1,
    this.flingVelocity = 500,
    this.showDebugColors = false,
    this.leftEdgeWidthBuilder,
    this.leftEdgeTopPaddingBuilder,
    this.leftEdgeBottomPaddingBuilder,
    this.rightEdgeWidthBuilder,
    this.rightEdgeTopPaddingBuilder,
    this.rightEdgeBottomPaddingBuilder,
    this.onProgressChanged,
  });

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
      }
    });

    // Add a listener to report progress updates.
    _animationController.addListener(_progressListener);
  }

  void _progressListener() {
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

  // Build the left hidden page with optimized transforms
  Widget _buildLeftHiddenPage(
    double screenWidth,
    bool isLeft,
    BoxConstraints constraints,
  ) {
    return Positioned.fill(
      child: Offstage(
        offstage: !(_animationController.value > 0 && isLeft),
        child: RepaintBoundary(
          child: Transform.translate(
            offset: Offset(
              -screenWidth / 2 +
                  (_animationController.value * (screenWidth / 2)),
              0,
            ),
            child:
                (_animationController.value >
                        widget.leftWidgetVisibilityThreshold)
                    ? widget.leftHiddenPage
                    : widget.leftPlaceHolderWidget,
          ),
        ),
      ),
    );
  }

  // Build the right hidden page with optimized transforms
  Widget _buildRightHiddenPage(
    double screenWidth,
    bool isLeft,
    BoxConstraints constraints,
  ) {
    return Positioned.fill(
      child: Offstage(
        offstage: !(_animationController.value > 0 && !isLeft),
        child: RepaintBoundary(
          child: Transform.translate(
            offset: Offset(
              screenWidth / 2 -
                  (_animationController.value * (screenWidth / 2)),
              0,
            ),
            child:
                (_animationController.value >
                        widget.rightWidgetVisibilityThreshold)
                    ? widget.rightHiddenPage
                    : widget.rightPlaceHolderWidget,
          ),
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

    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(contentOffset, 0),
        child: RepaintBoundary(child: widget.child),
      ),
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
        color:
            widget.showDebugColors
                ? Colors.red.withValues(alpha: 0.5)
                : Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) => _onLeftEdgePanUpdate(details, screenWidth),
          onPanEnd: _onLeftEdgePanEnd,
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
        color:
            widget.showDebugColors
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) => _onRightEdgePanUpdate(details, screenWidth),
          onPanEnd: _onRightEdgePanEnd,
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
                // Left hidden page - only rebuilds when animation changes
                _buildLeftHiddenPage(screenWidth, isLeft, constraints),

                // Right hidden page - only rebuilds when animation changes
                _buildRightHiddenPage(screenWidth, isLeft, constraints),

                // Main content - only rebuilds when animation changes
                _buildMainContent(screenWidth, isLeft, constraints),

                // Gesture detectors - only depend on isActive state, not animation value
                if (widget.isLeftActive)
                  _buildLeftEdgeGestureDetector(
                    screenWidth,
                    isLeft,
                    isAnimationActive,
                    showRight,
                    constraints,
                  ),

                if (widget.isRightActive)
                  _buildRightEdgeGestureDetector(
                    screenWidth,
                    isLeft,
                    isAnimationActive,
                    showLeft,
                    constraints,
                  ),
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
    _animationController.removeListener(_progressListener);

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
