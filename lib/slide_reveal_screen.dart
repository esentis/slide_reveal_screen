import 'package:flutter/material.dart';
import 'package:slide_reveal_screen/slide_reveal_controller.dart';

/// A widget that provides a draggable screen with two hidden pages.
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

  /// An optional controller to manage the draggable screen.
  ///
  /// If no controller is provided, the widget creates its own.
  final SlideRevealController? controller;

  /// The main content of the screen.
  final Widget child;

  /// A placeholder widget to display for the left side if the hidden page isn’t fully visible.
  ///
  /// This is when [leftWidgetVisibilityThreshold] is not reached.
  final Widget leftPlaceHolderWidget;

  /// A placeholder widget for the right side when its hidden page isn’t fully visible.
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

  /// The [SlideRevealController] managing the draggable screen state.
  SlideRevealController? _slideRevealController;

  /// The screen width, used to compute drag distances.
  double _screenWidth = 0;

  /// A flag that indicates whether the user is dragging from the left.
  /// When `null`, no drag direction has been determined yet.
  bool? _draggingFromLeft;

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
      }
    });

    // Listen for changes to the animation value and update the UI.
    _animationController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    });
  }

  /// A listener that responds to external changes on the [SlideRevealController].
  ///
  /// It checks which side (left or right) is active based on the controller's
  /// [side] property and updates the local [_draggingFromLeft] flag accordingly.
  /// It then schedules a UI rebuild in the next frame.
  void _externalControllerListener() {
    if (_slideRevealController!.side != null) {
      _draggingFromLeft = _slideRevealController!.side == RevealSide.left;
    } else {
      _draggingFromLeft = null;
    }
    // Schedule a rebuild after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  /// Called when the user drags on the left edge of the screen.
  ///
  /// This updates the animation value by calculating the change based on
  /// the drag delta and screen width.
  void _onLeftEdgePanUpdate(DragUpdateDetails details) {
    _draggingFromLeft ??= true;
    final double delta = details.delta.dx;
    final double newValue = _animationController.value + delta / _screenWidth;
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
  void _onRightEdgePanUpdate(DragUpdateDetails details) {
    _draggingFromLeft ??= false;
    final double delta = details.delta.dx;
    final double newValue = _animationController.value - delta / _screenWidth;
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

  @override
  Widget build(BuildContext context) {
    // Obtain the screen width from MediaQuery for gesture calculations.
    _screenWidth = MediaQuery.of(context).size.width;

    // Determine the active drag direction.
    // If no drag has started, check the controller's state.
    final bool isLeft =
        _draggingFromLeft ?? _slideRevealController?.side == RevealSide.left;
    // Check if the animation has any progress.
    final bool isAnimationActive = _animationController.value > 0;

    // Determine which hidden page should be visible.
    final bool showLeft = isAnimationActive && isLeft;
    final bool showRight = isAnimationActive && !isLeft;

    final double computedLeftEdgeWidth =
        widget.leftEdgeWidthBuilder != null
            ? widget.leftEdgeWidthBuilder!(context, isLeft)
            : 30;

    final double computedLeftEdgeTop =
        widget.leftEdgeTopPaddingBuilder != null
            ? widget.leftEdgeTopPaddingBuilder!(context, isLeft)
            : 0;

    final double computedLeftEdgeBottom =
        widget.leftEdgeBottomPaddingBuilder != null
            ? widget.leftEdgeBottomPaddingBuilder!(context, isLeft)
            : 0;

    final double computedRightEdgeWidth =
        widget.rightEdgeWidthBuilder != null
            ? widget.rightEdgeWidthBuilder!(context, !isLeft)
            : 30;

    final double computedRightEdgeTop =
        widget.rightEdgeTopPaddingBuilder != null
            ? widget.rightEdgeTopPaddingBuilder!(context, !isLeft)
            : 0;

    final double computedRightEdgeBottom =
        widget.rightEdgeBottomPaddingBuilder != null
            ? widget.rightEdgeBottomPaddingBuilder!(context, !isLeft)
            : 0;

    return Stack(
      children: [
        // Left hidden page layer.
        Positioned.fill(
          child: Offstage(
            offstage: !showLeft,
            child: Transform.translate(
              // The horizontal offset creates a parallax effect.
              offset: Offset(
                -_screenWidth / 2 +
                    (_animationController.value * (_screenWidth / 2)),
                0,
              ),
              // Show the left hidden page if the animation value is above the threshold,
              // otherwise show the placeholder.
              child:
                  (_animationController.value >
                          widget.leftWidgetVisibilityThreshold)
                      ? widget.leftHiddenPage
                      : widget.leftPlaceHolderWidget,
            ),
          ),
        ),
        // Right hidden page layer.
        Positioned.fill(
          child: Offstage(
            offstage: !showRight,
            child: Transform.translate(
              offset: Offset(
                _screenWidth / 2 -
                    (_animationController.value * (_screenWidth / 2)),
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
        // Main content layer, which translates based on the animation value.
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final double offset =
                  isLeft
                      ? _animationController.value * _screenWidth
                      : -_animationController.value * _screenWidth;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: widget.child,
          ),
        ),
        // Gesture detector for the left edge.
        if (widget.isLeftActive)
          Positioned(
            top: computedLeftEdgeTop,
            left: showLeft ? null : 0,
            right: showLeft ? 0 : null,
            bottom: computedLeftEdgeBottom,
            width: showRight ? 0 : computedLeftEdgeWidth,
            child: ColoredBox(
              color:
                  widget.showDebugColors
                      ? Colors.red.withValues(alpha: 0.5)
                      : Colors.transparent,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: _onLeftEdgePanUpdate,
                onPanEnd: _onLeftEdgePanEnd,
              ),
            ),
          ),
        // Gesture detector for the right edge.
        if (widget.isRightActive)
          Positioned(
            // If the right hidden page is active, add the app bar height and padding to the top.
            // Because at right page is an appbar with a back button.
            top: computedRightEdgeTop,
            left: showRight ? 0 : null,
            right: showRight ? null : 0,
            bottom: computedRightEdgeBottom,
            width: showLeft ? 0 : computedRightEdgeWidth,
            child: ColoredBox(
              color:
                  widget.showDebugColors
                      ? Colors.green.withValues(alpha: 0.5)
                      : Colors.transparent,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: _onRightEdgePanUpdate,
                onPanEnd: _onRightEdgePanEnd,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // If the controller was created internally (i.e. not provided externally),
    // dispose it. Otherwise, simply remove the listener.
    if (widget.controller == null) {
      _slideRevealController?.dispose();
    } else {
      _slideRevealController?.removeListener(_externalControllerListener);
    }
    super.dispose();
  }
}
