import 'dart:math';

import 'package:confirm_slider/action_slider.dart';
import 'package:confirm_slider/src/cross_fade.dart';
import 'package:confirm_slider/src/mode.dart';
import 'package:confirm_slider/src/state.dart';
import 'package:flutter/material.dart';

typedef BackgroundBuilder = Widget Function(
    BuildContext, double, double, double, Widget?);
typedef ForegroundBuilder = Widget Function(
    BuildContext, double, double, double, Widget?, SliderMode);
typedef SlideCallback = Function(Function() loading, Function() success,
    Function() failure, Function() reset);

class ActionSliderController extends ValueNotifier<SliderMode> {
  ActionSliderController() : super(SliderMode.standard);

  ///Sets the state to success
  void success() => _setMode(SliderMode.success);

  ///Sets the state to failure
  void failure() => _setMode(SliderMode.failure);

  ///Resets the slider to its expanded state
  void reset() => _setMode(SliderMode.standard);

  ///Sets the state to loading
  void loading() => _setMode(SliderMode.loading);

  ///Allows to define custom [SliderMode]s.
  ///This is useful for other results like success or failure.
  ///You get this modes in the [foregroundBuilder] of [ConfirmationSlider.custom] or in the [customForegroundBuilder] of [ConfirmationSlider.standard].
  void custom(SliderMode mode) => _setMode(mode);

  void _setMode(SliderMode mode) => value = mode;
}

class ActionSlider extends StatefulWidget {
  final List<BoxShadow> boxShadow;

  ///The [Color] of the [Container] in the background.
  final Color? backgroundColor;

  ///The width of the sliding toggle.
  final double toggleWidth;

  ///The height of the sliding toggle.
  final double toggleHeight;

  ///The total width of the widget. If this is [null] it uses the whole available width.
  final double? width;

  ///The total height of the widget.
  final double height;

  ///The child which is optionally given to the [backgroundBuilder] for efficiency reasons.
  final Widget? backgroundChild;

  ///The builder for the background.
  final BackgroundBuilder backgroundBuilder;

  ///The child which is optionally given to the [foregroundBuilder] for efficiency reasons.
  final Widget? foregroundChild;

  ///The builder for the toggle.
  final ForegroundBuilder foregroundBuilder;

  ///The duration for the sliding animation when the user taps anywhere on the widget.
  final Duration slideAnimationDuration;

  ///The duration for the toggle coming back after the user released it or after the sliding animation.
  final Duration reverseSlideAnimationDuration;

  ///The duration for going into the loading mode.
  final Duration loadingAnimationDuration;

  ///The curve for the sliding animation when the user taps anywhere on the widget.
  final Curve slideAnimationCurve;

  ///The curve for the toggle coming back after the user released it or after the sliding animation.
  final Curve reverseSlideAnimationCurve;

  ///The curve for going into the loading mode.
  final Curve loadingAnimationCurve;

  ///[BorderRadius] of the [Container] in the background.
  final BorderRadius backgroundBorderRadius;

  ///Callback for sliding completely to the right.
  ///Here you should call the loading, success and failure methods of the [controller] for controlling the further behaviour/animations of the slider.
  ///Optionally [onSlide] can be a [SlideCallback] for using the widget without an external controller.
  final Function? onSlide;

  ///Controller for controlling the widget from everywhere.
  final ActionSliderController? controller;

  ///Constructor with very high customizability
  const ActionSlider.custom({
    Key? key,
    required this.backgroundBuilder,
    required this.foregroundBuilder,
    this.toggleWidth = 55.0,
    this.toggleHeight = 55.0,
    this.height = 65.0,
    this.slideAnimationDuration = const Duration(milliseconds: 1000),
    this.backgroundColor,
    this.backgroundChild,
    this.foregroundChild,
    this.backgroundBorderRadius =
        const BorderRadius.all(Radius.circular(100.0)),
    this.onSlide,
    this.controller,
    this.loadingAnimationDuration = const Duration(milliseconds: 350),
    this.width,
    this.reverseSlideAnimationDuration = const Duration(milliseconds: 250),
    this.slideAnimationCurve = Curves.decelerate,
    this.reverseSlideAnimationCurve = Curves.bounceIn,
    this.loadingAnimationCurve = Curves.easeInOut,
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black26,
        spreadRadius: 1,
        blurRadius: 2,
        offset: Offset(0, 2),
      )
    ],
  })  : assert(onSlide == null ||
            onSlide is SlideCallback ||
            onSlide is Function()),
        super(key: key);

  ///Standard constructor for creating a Slider.
  ///If [customForegroundBuilder] is not null, the values of [successIcon], [failureIcon], [loadingIcon] and [icon] are ignored.
  ///This is useful if you use your own [SliderMode]s.
  ///You can also use [customForegroundBuilderChild] with the [customForegroundBuilder] for efficiency reasons.
  ActionSlider.standard({
    Key? key,
    Widget? child,
    Widget? loadingIcon,
    Widget successIcon = const Icon(Icons.check_rounded),
    Widget failureIcon = const Icon(Icons.close_rounded),
    Widget icon = const Icon(Icons.keyboard_arrow_right_rounded),
    ForegroundBuilder? customForegroundBuilder,
    Widget? customForegroundBuilderChild,
    Color? circleColor,
    Color? backgroundColor,
    double height = 65.0,
    double circleRadius = 25.0,
    bool rotating = false,
    Function? onSlide,
    ActionSliderController? controller,
    double? width,
    Duration slideAnimationDuration = const Duration(milliseconds: 250),
    Duration reverseSlideAnimationDuration = const Duration(milliseconds: 1000),
    Duration loadingAnimationDuration = const Duration(milliseconds: 350),
    Curve slideAnimationCurve = Curves.decelerate,
    Curve reverseSlideAnimationCurve = Curves.bounceIn,
    Curve loadingAnimationCurve = Curves.easeInOut,
    BorderRadius backgroundBorderRadius =
        const BorderRadius.all(Radius.circular(100.0)),
    BorderRadius? foregroundBorderRadius,
    List<BoxShadow> boxShadow = const [
      BoxShadow(
        color: Colors.black26,
        spreadRadius: 1,
        blurRadius: 2,
        offset: Offset(0, 2),
      )
    ],
  }) : this.custom(
    key: key,
          backgroundChild: child,
          foregroundChild: icon,
          backgroundBuilder: _standardBackgroundBuilder,
          foregroundBuilder: (context, pos, width, height, child, mode) =>
              _standardForegroundBuilder(
            context,
            pos,
            width,
            height,
            mode,
            rotating,
            icon,
            loadingIcon,
            successIcon,
            failureIcon,
            circleColor,
            customForegroundBuilder,
            customForegroundBuilderChild,
            foregroundBorderRadius,
          ),
          height: height,
          toggleWidth: circleRadius * 2,
          toggleHeight: circleRadius * 2,
          backgroundColor: backgroundColor,
          onSlide: onSlide,
          controller: controller,
          width: width,
          slideAnimationDuration: slideAnimationDuration,
          reverseSlideAnimationDuration: reverseSlideAnimationDuration,
          loadingAnimationDuration: loadingAnimationDuration,
          slideAnimationCurve: slideAnimationCurve,
          reverseSlideAnimationCurve: reverseSlideAnimationCurve,
          loadingAnimationCurve: loadingAnimationCurve,
          backgroundBorderRadius: backgroundBorderRadius,
          boxShadow: boxShadow,
        );

  static Widget _standardBackgroundBuilder(BuildContext context, double pos,
      double width, double height, Widget? child) {
    return Align(
      alignment: Alignment.centerRight,
      child: ClipRect(
        child: Align(
          alignment: Alignment.centerRight,
          widthFactor: 1 - pos,
          child: SizedBox(width: width, child: Center(child: child)),
        ),
      ),
    );
  }

  static Widget _standardForegroundBuilder(
    BuildContext context,
    double pos,
    double width,
    double height,
    SliderMode mode,
    bool rotating,
    Widget icon,
    Widget? loadingIcon,
    Widget successIcon,
    Widget failureIcon,
    Color? circleColor,
    ForegroundBuilder? customForegroundBuilder,
    Widget? customForegroundBuilderChild,
    BorderRadius? foregroundBorderRadius,
  ) {
    loadingIcon ??= SizedBox(
      width: 24.0,
      height: 24.0,
      child: CircularProgressIndicator(
          strokeWidth: 2.0, color: Theme.of(context).iconTheme.color),
    );
    double radius = height / 2;

    return Container(
      decoration: BoxDecoration(
          borderRadius: foregroundBorderRadius,
          shape: foregroundBorderRadius == null
              ? BoxShape.circle
              : BoxShape.rectangle,
          color: circleColor ?? Theme.of(context).primaryColor),
      child: CrossFade<SliderMode>(
          current: mode,
          builder: (context, mode) {
            if (customForegroundBuilder != null) {
              return customForegroundBuilder(
                context,
                pos,
                width,
                height,
                customForegroundBuilderChild,
                mode,
              );
            }
            if (mode == SliderMode.loading) return Center(child: loadingIcon);
            if (mode == SliderMode.success) return Center(child: successIcon);
            if (mode == SliderMode.failure) return Center(child: failureIcon);
            if (mode == SliderMode.standard) {
              return Center(
                  child: rotating
                      ? Transform.rotate(
                          angle: pos * width / radius, child: icon)
                      : icon);
            }
            throw StateError('This should not happen :(');
          },
          size: (m1, m2) =>
              m2 == SliderMode.success || m2 == SliderMode.failure),
    );
  }

  @override
  _ActionSliderState createState() => _ActionSliderState();
}

class _ActionSliderState extends State<ActionSlider>
    with TickerProviderStateMixin {
  late final AnimationController _slideAnimationController;
  late final AnimationController _loadingAnimationController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _loadingAnimation;
  ActionSliderController? _localController;

  ActionSliderController get _controller =>
      widget.controller ?? _localController!;
  SliderState state = SliderState(position: 0.0, state: SlidingState.released);

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(
        vsync: this, duration: widget.loadingAnimationDuration);
    _loadingAnimation = CurvedAnimation(
        parent: _loadingAnimationController,
        curve: widget.loadingAnimationCurve);
    _slideAnimationController = AnimationController(
        vsync: this,
        duration: widget.slideAnimationDuration,
        reverseDuration: widget.reverseSlideAnimationDuration);
    _slideAnimation = CurvedAnimation(
        parent: _slideAnimationController,
        curve: widget.slideAnimationCurve,
        reverseCurve: widget.reverseSlideAnimationCurve);
    _slideAnimation.addListener(() {
      //TODO: more efficiency
      if (state.state != SlidingState.dragged) {
        setState(() {
          state = state.copyWith(
              position: _slideAnimation.value * state.releasePosition);
        });
      }
    });
    _slideAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _slideAnimationController.reverse();
      }
    });

    if (widget.controller == null) {
      _localController = ActionSliderController();
    }
    _controller.addListener(_onModeChange);
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _loadingAnimationController.dispose();
    _localController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _localController?.dispose();
      oldWidget.controller?.removeListener(_onModeChange);
      if (widget.controller == null) {
        _localController = null;
      } else if (oldWidget.controller == null) {
        _localController = ActionSliderController();
      }
      _controller.addListener(_onModeChange);
    }
  }

  void _onModeChange() {
    if (_controller.value.expanded) {
      _slideAnimationController.reverse();
      _loadingAnimationController.reverse();
      setState(() => state =
          state.copyWith(releasePosition: 1.0, state: SlidingState.released));
    } else {
      _loadingAnimationController.forward();
      setState(() => state =
          state.copyWith(releasePosition: 1.0, state: SlidingState.loading));
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    double frame = (widget.height - widget.toggleHeight) / 2;
    //TODO: More efficiency by using separate widgets and child property of AnimatedBuilder

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth =
          min(widget.width ?? double.infinity, constraints.maxWidth);
      final standardWidth = maxWidth - widget.toggleWidth - frame * 2;
      return AnimatedBuilder(
        builder: (context, child) {
          final width =
              maxWidth - (_loadingAnimationController.value * standardWidth);
          final backgroundWidth = width - widget.toggleWidth - frame * 2;
          final position =
              (state.position * backgroundWidth).clamp(0.0, backgroundWidth);
          final realPosition = position + widget.toggleWidth / 2 + frame;
          return GestureDetector(
              onHorizontalDragStart: (details) {
                final x = details.localPosition.dx;
                if (x >= realPosition &&
                    x <= realPosition + widget.toggleWidth) {
                  setState(() {
                    state = SliderState(
                      position: ((details.localPosition.dx -
                                  frame -
                                  widget.toggleWidth / 2) /
                              backgroundWidth)
                          .clamp(0.0, 1.0),
                      state: SlidingState.dragged,
                    );
                  });
                }
              },
              onHorizontalDragUpdate: (details) {
                if (state.state == SlidingState.dragged) {
                  double newPosition = ((details.localPosition.dx -
                              frame -
                              widget.toggleWidth / 2) /
                          backgroundWidth)
                      .clamp(0.0, 1.0);
                  setState(() {
                    state = SliderState(
                      position: newPosition,
                      state: newPosition < 1.0
                          ? SlidingState.dragged
                          : SlidingState.released,
                    );
                  });
                  if (state.state == SlidingState.released) _onSlide();
                }
              },
              onHorizontalDragEnd: (details) => setState(() {
                    state = state.copyWith(
                        state: SlidingState.released,
                        releasePosition: state.position);
                    _slideAnimationController.reverse(from: 1.0);
                  }),
              onTap: () {
                if (state.state != SlidingState.released) return;
                state = state.copyWith(releasePosition: 0.3);
                _slideAnimationController.forward();
              },
              child: Container(
                width: width,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? theme.backgroundColor,
                  borderRadius: widget.backgroundBorderRadius,
                  boxShadow: widget.boxShadow,
                ),
                height: widget.height,
                child: Center(
                  child: SizedBox(
                    width: width - frame * 2,
                    height: widget.toggleHeight,
                    child: Stack(children: [
                      Positioned.fill(
                        left: widget.toggleWidth / 2,
                        right: widget.toggleWidth / 2,
                        child: ClipRect(
                          child: OverflowBox(
                            maxWidth: standardWidth,
                            child: Builder(
                              builder: (context) => widget.backgroundBuilder(
                                  context,
                                  state.position,
                                  standardWidth,
                                  widget.toggleHeight,
                                  widget.backgroundChild),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: position,
                        width: widget.toggleWidth,
                        height: widget.toggleHeight,
                        child: MouseRegion(
                          cursor: state.state == SlidingState.loading
                              ? MouseCursor.defer
                              : (state.state == SlidingState.released
                                  ? SystemMouseCursors.grab
                                  : SystemMouseCursors.grabbing),
                          child: Builder(
                            builder: (context) => widget.foregroundBuilder(
                                context,
                                state.position,
                                standardWidth,
                                widget.toggleHeight,
                                widget.foregroundChild,
                                _controller.value),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ));
        },
        animation: _loadingAnimation,
      );
    });
  }

  void _onSlide() {
    if (widget.onSlide == null) return;
    if (widget.onSlide is Function()) {
      widget.onSlide!();
    } else if (widget.onSlide is SlideCallback) {
      widget.onSlide!(_controller.loading, _controller.success,
          _controller.failure, _controller.reset);
    } else {
      throw ArgumentError(
          'onSlide should be null, a Function() or a SlideCallback');
    }
  }
}
