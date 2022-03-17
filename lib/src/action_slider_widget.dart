import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:action_slider/src/cross_fade.dart';
import 'package:action_slider/src/mode.dart';
import 'package:action_slider/src/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SliderBehavior { move, stretch }

typedef BackgroundBuilder = Widget Function(
    BuildContext, ActionSliderState, Widget?);
typedef ForegroundBuilder = Widget Function(
    BuildContext, ActionSliderState, Widget?);
typedef SlideCallback = Function(ActionSliderController controller);
typedef TapCallback = Function(ActionSliderController controller);

class ActionSliderController extends ChangeNotifier
    implements ValueListenable<SliderMode> {
  SliderMode _value = SliderMode.standard;

  @override
  SliderMode get value => _value;

  ///Sets the state to success
  void success() => _setMode(SliderMode.success);

  ///Sets the state to failure
  void failure() => _setMode(SliderMode.failure);

  ///Resets the slider to its expanded state
  void reset() => _setMode(SliderMode.standard);

  ///Sets the state to loading
  void loading() => _setMode(SliderMode.loading);

  ///The Toggle jumps to [pos] which should be between 0.0 and 1.0.
  void jump([double pos = 0.3]) =>
      _setMode(SliderMode.jump(pos.clamp(0.0, 1.0)));

  ///Allows to define custom [SliderMode]s.
  ///This is useful for other results like success or failure.
  ///You get this modes in the [foregroundBuilder] of [ConfirmationSlider.custom] or in the [customForegroundBuilder] of [ConfirmationSlider.standard].
  void custom(SliderMode mode) => _setMode(mode);

  void _setMode(SliderMode mode, {bool notify = true}) {
    if (value == mode) return;
    _value = mode;
    if (notify) notifyListeners();
  }
}

class ActionSlider extends StatefulWidget {
  ///The width of the sliding toggle.
  final double toggleWidth;

  ///The margin of the sliding toggle.
  final EdgeInsetsGeometry toggleMargin;

  ///The total width of the widget. If this is [null] it uses the whole available width.
  final double? width;

  ///The total height of the widget.
  final double height;

  ///The child which is optionally given to the [outerBackgroundBuilder] for efficiency reasons.
  final Widget? outerBackgroundChild;

  ///The builder for outer background. Overwrites [backgroundColor], [backgroundBorderRadius] and [boxShadow].
  final BackgroundBuilder? outerBackgroundBuilder;

  ///The child which is optionally given to the [backgroundBuilder] for efficiency reasons.
  final Widget? backgroundChild;

  ///The builder for the background of the toggle.
  final BackgroundBuilder? backgroundBuilder;

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

  ///The [Color] of the [Container] in the background.
  final Color? backgroundColor;

  ///[BorderRadius] of the [Container] in the background.
  final BorderRadius backgroundBorderRadius;

  ///The [BoxShadow] of the background [Container].
  final List<BoxShadow> boxShadow;

  ///Callback for sliding completely to the right.
  ///Here you should call the loading, success and failure methods of the
  ///[controller] for controlling the further behaviour/animations of the
  ///slider.
  final SlideCallback? onSlide;

  ///Callback for tapping on the [ActionSlider]. Defaults to (c) => c.jump().
  ///Is only called if the toggle is currently not dragged.
  ///If you want onTap to be called in any case, you should wrap ActionSlider
  ///in a GestureDetector.
  final TapCallback? onTap;

  ///Controller for controlling the widget from everywhere.
  final ActionSliderController? controller;

  ///This [SliderBehavior] defines the behaviour when moving the toggle.
  final SliderBehavior? sliderBehavior;

  ///Constructor with very high customizability
  const ActionSlider.custom({
    Key? key,
    this.outerBackgroundBuilder,
    this.backgroundBuilder,
    required this.foregroundBuilder,
    this.toggleWidth = 55.0,
    this.toggleMargin = const EdgeInsets.all(5.0),
    this.height = 65.0,
    this.slideAnimationDuration = const Duration(milliseconds: 1000),
    this.backgroundColor,
    this.outerBackgroundChild,
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
    this.sliderBehavior = SliderBehavior.move,
    this.onTap = _defaultOnTap,
  }) : super(key: key);

  static _defaultOnTap(ActionSliderController c) => c.jump();

  ///Standard constructor for creating a Slider.
  ///
  ///If [customForegroundBuilder] is not null, the values of [successIcon], [failureIcon], [loadingIcon] and [icon] are ignored.
  ///This is useful if you use your own [SliderMode]s.
  ///You can also use [customForegroundBuilderChild] with the [customForegroundBuilder] for efficiency reasons.
  ///
  ///If [customOuterBackgroundBuilder] is not null, the values of [backgroundColor], [backgroundBorderRadius] and [boxShadow] are ignored.
  ///You can also use [customOuterBackgroundBuilderChild] with the [customOuterBackgroundBuilder] for efficiency reasons.
  ActionSlider.standard({
    Key? key,
    Widget? child,
    Widget? loadingIcon,
    Widget successIcon = const Icon(Icons.check_rounded),
    Widget failureIcon = const Icon(Icons.close_rounded),
    Widget icon = const Icon(Icons.keyboard_arrow_right_rounded),
    ForegroundBuilder? customForegroundBuilder,
    Widget? customForegroundBuilderChild,
    BackgroundBuilder? customBackgroundBuilder,
    Widget? customBackgroundBuilderChild,
    BackgroundBuilder? customOuterBackgroundBuilder,
    Widget? customOuterBackgroundBuilderChild,
    Color? toggleColor,
    Color? backgroundColor,
    double height = 65.0,
    double borderWidth = 5.0,
    bool rolling = false,
    SlideCallback? onSlide,
    TapCallback? onTap = _defaultOnTap,
    ActionSliderController? controller,
    double? width,
    Duration slideAnimationDuration = const Duration(milliseconds: 250),
    Duration reverseSlideAnimationDuration = const Duration(milliseconds: 1000),
    Duration loadingAnimationDuration = const Duration(milliseconds: 350),
    Duration crossFadeDuration = const Duration(milliseconds: 250),
    Curve slideAnimationCurve = Curves.decelerate,
    Curve reverseSlideAnimationCurve = Curves.bounceIn,
    Curve loadingAnimationCurve = Curves.easeInOut,
    AlignmentGeometry iconAlignment = Alignment.center,
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
    SliderBehavior sliderBehavior = SliderBehavior.move,
  }) : this.custom(
            key: key,
            backgroundChild: customBackgroundBuilderChild,
            backgroundBuilder: customBackgroundBuilder ??
                (context, state, _) =>
                    _standardBackgroundBuilder(context, state, child),
            foregroundBuilder: (context, state, child) =>
                _standardForegroundBuilder(
                  context,
                  state,
                  rolling,
                  icon,
                  loadingIcon,
                  successIcon,
                  failureIcon,
                  toggleColor,
                  customForegroundBuilder,
                  customForegroundBuilderChild,
                  foregroundBorderRadius,
                  iconAlignment,
                  crossFadeDuration,
                ),
            outerBackgroundBuilder: customOuterBackgroundBuilder,
            outerBackgroundChild: customOuterBackgroundBuilderChild,
            height: height,
            toggleWidth: height - borderWidth * 2,
            toggleMargin: EdgeInsets.all(borderWidth),
            backgroundColor: backgroundColor,
            onSlide: onSlide,
            onTap: onTap,
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
            sliderBehavior: sliderBehavior);

  static BackgroundBuilder _standardOuterBackgroundBuilder(
    BorderRadius backgroundBorderRadius,
    Color? backgroundColor,
    List<BoxShadow> boxShadow,
    double? width,
  ) {
    return (context, state, child) => Container(
          width: width,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).backgroundColor,
            borderRadius: backgroundBorderRadius,
            boxShadow: boxShadow,
          ),
        );
  }

  static Widget _standardBackgroundBuilder(
      BuildContext context, ActionSliderState state, Widget? child) {
    return Padding(
      padding: EdgeInsets.only(
        left: state.toggleSize.height / 2,
        right: state.toggleSize.height / 2,
      ),
      child: ClipRect(
        child: OverflowBox(
          maxWidth: state.standardSize.width - state.toggleSize.height,
          maxHeight: state.toggleSize.height,
          minWidth: state.standardSize.width - state.toggleSize.height,
          minHeight: state.toggleSize.height,
          child: Align(
            alignment: Alignment.centerRight,
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 1 - state.position,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _standardForegroundBuilder(
    BuildContext context,
    ActionSliderState state,
    bool rotating,
    Widget icon,
    Widget? loadingIcon,
    Widget successIcon,
    Widget failureIcon,
    Color? circleColor,
    ForegroundBuilder? customForegroundBuilder,
    Widget? customForegroundBuilderChild,
    BorderRadius? foregroundBorderRadius,
    AlignmentGeometry iconAlignment,
    Duration crossFadeDuration,
  ) {
    loadingIcon ??= SizedBox(
      width: 24.0,
      height: 24.0,
      child: CircularProgressIndicator(
          strokeWidth: 2.0, color: Theme.of(context).iconTheme.color),
    );
    double radius = state.size.height / 2;

    return Container(
      decoration: BoxDecoration(
          borderRadius: foregroundBorderRadius ??
              BorderRadius.circular(state.toggleSize.height / 2),
          color: circleColor ?? Theme.of(context).primaryColor),
      child: SliderCrossFade<SliderMode>(
        duration: crossFadeDuration * (1 / 0.3),
        current: state.sliderMode,
        builder: (context, mode) {
          if (customForegroundBuilder != null) {
            return customForegroundBuilder(
              context,
              state,
              customForegroundBuilderChild,
            );
          }
          Widget? child;
          if (mode == SliderMode.loading) {
            child = loadingIcon;
          } else if (mode == SliderMode.success) {
            child = successIcon;
          } else if (mode == SliderMode.failure) {
            child = failureIcon;
          } else if (mode == SliderMode.standard || mode.isJump) {
            child = rotating
                ? Transform.rotate(
                    angle: state.position * state.size.width / radius,
                    child: icon)
                : icon;
          } else {
            throw StateError('For using custom SliderModes you have to '
                'set customForegroundBuilder!');
          }
          return Align(alignment: iconAlignment, child: child);
        },
        size: (m1, m2) => m2.result,
      ),
    );
  }

  @override
  _ActionSliderState createState() => _ActionSliderState();
}

class _ActionSliderState extends State<ActionSlider>
    with TickerProviderStateMixin {
  late final AnimationController _slideAnimationController;
  late final AnimationController _loadingAnimationController;
  late final CurvedAnimation _slideAnimation;
  late final CurvedAnimation _loadingAnimation;
  ActionSliderController? _localController;

  ActionSliderController get _controller =>
      widget.controller ?? _localController!;
  SliderState _state = SliderState(position: 0.0, state: SlidingState.released);

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
      if (_state.state != SlidingState.dragged) {
        setState(() {
          _state = _state.copyWith(
              position: _slideAnimation.value * _state.releasePosition);
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
    _slideAnimationController.duration = widget.slideAnimationDuration;
    _slideAnimationController.reverseDuration =
        widget.reverseSlideAnimationDuration;
    _loadingAnimationController.duration = widget.loadingAnimationDuration;
    _slideAnimation.curve = widget.slideAnimationCurve;
    _slideAnimation.reverseCurve = widget.reverseSlideAnimationCurve;
    _loadingAnimation.curve = widget.loadingAnimationCurve;
  }

  void _onModeChange() {
    if (_controller.value.expanded) {
      _slideAnimationController.reverse();
      _loadingAnimationController.reverse();
      if (_controller.value.jumpPosition > 0.0) {
        _controller._setMode(SliderMode.standard, notify: false);
        _state = _state.copyWith(releasePosition: 0.3);
        _slideAnimationController.forward();
      } else {
        if (_slideAnimationController.isCompleted) {
          setState(() {
            _state = _state.copyWith(
                position: 0.0,
                releasePosition: 0.0,
                state: SlidingState.released);
          });
        } else if (_slideAnimationController.status !=
            AnimationStatus.reverse) {
          _state = _state.copyWith(
              position: _slideAnimationController.value,
              releasePosition: _slideAnimationController.value,
              state: SlidingState.released);
          _slideAnimationController.reverse(from: 1.0);
        }
      }
    } else {
      _loadingAnimationController.forward();
      setState(() => _state =
          _state.copyWith(releasePosition: 0.0, state: SlidingState.compact));
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    //double dframe = (widget.height - widget.toggleSize.height) / 2;
    //TODO: More efficiency by using separate widgets and child property of AnimatedBuilder

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            min(widget.width ?? double.infinity, constraints.maxWidth);
        if (maxWidth == double.infinity) {
          throw StateError('The constraints of the ActionSlider '
              'are unbound and no width is set');
        }
        final standardWidth =
            maxWidth - widget.toggleWidth - widget.toggleMargin.horizontal;
        return AnimatedBuilder(
          builder: (context, child) {
            final width =
                maxWidth - (_loadingAnimationController.value * standardWidth);
            final backgroundWidth =
                width - widget.toggleWidth - widget.toggleMargin.horizontal;
            final position =
                (_state.position * backgroundWidth).clamp(0.0, backgroundWidth);

            double togglePosition;
            double toggleWidth;

            if (widget.sliderBehavior == SliderBehavior.move) {
              togglePosition = position;
              toggleWidth = widget.toggleWidth;
            } else {
              togglePosition = 0;
              toggleWidth = position + widget.toggleWidth;
            }

            final toggleHeight = widget.height - widget.toggleMargin.vertical;

            final actionSliderState = ActionSliderState(
              position: _state.position,
              size: Size(width, widget.height),
              standardSize: Size(maxWidth, widget.height),
              slidingState: _state.state,
              sliderMode: _controller.value,
              releasePosition: _state.releasePosition,
              toggleSize: Size(toggleWidth, toggleHeight),
            );

            return GestureDetector(
              onTap: () {
                if (_state.state != SlidingState.released) return;
                widget.onTap?.call(_controller);
              },
              child: SizedBox.fromSize(
                size: actionSliderState.size,
                child: Stack(
                  children: [
                    (widget.outerBackgroundBuilder ??
                        ActionSlider._standardOuterBackgroundBuilder(
                            widget.backgroundBorderRadius,
                            widget.backgroundColor,
                            widget.boxShadow,
                            widget.width))(
                      context,
                      actionSliderState,
                      widget.outerBackgroundChild,
                    ),
                    Padding(
                      padding: widget.toggleMargin,
                      child: Stack(children: [
                        if (widget.backgroundBuilder != null)
                          Positioned.fill(
                            child: Builder(
                              builder: (context) => widget.backgroundBuilder!(
                                context,
                                actionSliderState,
                                widget.backgroundChild,
                              ),
                            ),
                          ),
                        Positioned(
                          left: togglePosition,
                          width: toggleWidth,
                          height: toggleHeight,
                          child: GestureDetector(
                            onHorizontalDragStart: (details) {
                              if (_state.state != SlidingState.released ||
                                  !_controller.value.expanded) return;
                              setState(() {
                                _state = SliderState(
                                  position: ((details.localPosition.dx -
                                              widget.toggleWidth / 2) /
                                          backgroundWidth)
                                      .clamp(0.0, 1.0),
                                  state: SlidingState.dragged,
                                );
                              });
                            },
                            onHorizontalDragUpdate: (details) {
                              if (_state.state == SlidingState.dragged) {
                                double newPosition =
                                    ((details.localPosition.dx -
                                                widget.toggleWidth / 2) /
                                            backgroundWidth)
                                        .clamp(0.0, 1.0);
                                setState(() {
                                  _state = SliderState(
                                    position: newPosition,
                                    state: newPosition < 1.0
                                        ? SlidingState.dragged
                                        : SlidingState.released,
                                  );
                                });
                                if (_state.state == SlidingState.released) {
                                  _onSlide();
                                }
                              }
                            },
                            onHorizontalDragEnd: (details) => setState(() {
                              if (_state.state != SlidingState.dragged) return;
                              _state = _state.copyWith(
                                  state: SlidingState.released,
                                  releasePosition: _state.position);
                              _slideAnimationController.reverse(from: 1.0);
                            }),
                            child: MouseRegion(
                              cursor: _state.state == SlidingState.compact
                                  ? MouseCursor.defer
                                  : (_state.state == SlidingState.released
                                      ? SystemMouseCursors.grab
                                      : SystemMouseCursors.grabbing),
                              child: Builder(
                                builder: (context) => widget.foregroundBuilder(
                                  context,
                                  actionSliderState,
                                  widget.foregroundChild,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          },
          animation: _loadingAnimation,
        );
      },
    );
  }

  void _onSlide() {
    widget.onSlide?.call(_controller);
  }
}
