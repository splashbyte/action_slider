import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:action_slider/src/cross_fade.dart';
import 'package:action_slider/src/mode.dart';
import 'package:action_slider/src/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SliderBehavior { move, stretch }

enum ThresholdType {
  ///The action should be triggered as soon as the threshold is reached.
  ///The slider does not have to be released for this.
  instant,

  ///The action should only be triggered when the threshold is reached
  ///and the slider is released.
  release,
}

typedef BackgroundBuilder = Widget Function(
    BuildContext, ActionSliderState, Widget?);
typedef ForegroundBuilder = Widget Function(
    BuildContext, ActionSliderState, Widget?);
typedef Action = Function(ActionSliderController controller);
typedef StateChangeCallback = Function(ActionSliderState? oldState,
    ActionSliderState state, ActionSliderController controller);
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
  final Action? action;

  ///Callback when the [ActionSliderState] changes.
  ///With this you can define more individual behavior than with [action], if it is necessary.
  final StateChangeCallback? stateChangeCallback;

  ///Callback for tapping on the [ActionSlider]. Defaults to (c) => c.jump().
  ///Is only called if the toggle is currently not dragged.
  ///If you want onTap to be called in any case, you should wrap ActionSlider
  ///in a GestureDetector.
  final TapCallback? onTap;

  ///Controller for controlling the widget from everywhere.
  final ActionSliderController? controller;

  ///This [SliderBehavior] defines the behaviour when moving the toggle.
  final SliderBehavior? sliderBehavior;

  ///The threshold at which the action should be triggered. Should be between 0.0 and 1.0.
  final double actionThreshold;

  ///The [ThresholdType] of the [actionThreshold].
  final ThresholdType actionThresholdType;

  ///The direction of the slider.
  ///
  /// If set to [null], the [TextDirection] is fetched from the [BuildContext].
  final TextDirection? direction;

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
    this.action,
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
    this.actionThreshold = 1.0,
    this.actionThresholdType = ThresholdType.instant,
    this.stateChangeCallback,
    this.direction = TextDirection.ltr,
  }) : super(key: key);

  static _defaultOnTap(ActionSliderController c) => c.jump();

  ///Standard constructor for creating a Slider.
  ///
  ///If [customForegroundBuilder] is not null, the values of [successIcon], [failureIcon], [loadingIcon] and [icon] are ignored.
  ///This is useful if you use your own [SliderMode]s.
  ///You can also use [customForegroundBuilderChild] with the [customForegroundBuilder] for efficiency reasons.
  ///
  ///If [customBackgroundBuilder] is not null, the value of [child] is ignored.
  ///You can also use [customBackgroundBuilderChild] with the [customBackgroundBuilder] for efficiency reasons.
  ///
  ///If [customOuterBackgroundBuilder] is not null, the values of [backgroundColor], [backgroundBorderRadius] and [boxShadow] are ignored.
  ///You can also use [customOuterBackgroundBuilderChild] with the [customOuterBackgroundBuilder] for efficiency reasons.
  ActionSlider.standard({
    Key? key,
    Widget? child,
    Widget? loadingIcon,
    Widget successIcon = const Icon(Icons.check_rounded),
    Widget failureIcon = const Icon(Icons.close_rounded),
    Widget? icon,
    ForegroundBuilder? customForegroundBuilder,
    Widget? customForegroundBuilderChild,
    BackgroundBuilder? customBackgroundBuilder,
    Widget? customBackgroundBuilderChild,
    BackgroundBuilder? customOuterBackgroundBuilder,
    Widget? customOuterBackgroundBuilderChild,
    Color? toggleColor,
    this.backgroundColor,
    this.height = 65.0,
    double borderWidth = 5.0,
    bool rolling = false,
    this.action,
    this.onTap = _defaultOnTap,
    this.controller,
    this.width,
    this.slideAnimationDuration = const Duration(milliseconds: 250),
    this.reverseSlideAnimationDuration = const Duration(milliseconds: 1000),
    this.loadingAnimationDuration = const Duration(milliseconds: 350),
    Duration crossFadeDuration = const Duration(milliseconds: 250),
    this.slideAnimationCurve = Curves.decelerate,
    this.reverseSlideAnimationCurve = Curves.bounceIn,
    this.loadingAnimationCurve = Curves.easeInOut,
    AlignmentGeometry iconAlignment = Alignment.center,
    this.backgroundBorderRadius =
    const BorderRadius.all(Radius.circular(100.0)),
    BorderRadius? foregroundBorderRadius,
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black26,
        spreadRadius: 1,
        blurRadius: 2,
        offset: Offset(0, 2),
      )
    ],
    this.sliderBehavior = SliderBehavior.move,
    this.actionThreshold = 1.0,
    this.actionThresholdType = ThresholdType.instant,
    this.stateChangeCallback,
    this.direction = TextDirection.ltr,
  })
      : backgroundChild = customBackgroundBuilderChild,
        backgroundBuilder = (customBackgroundBuilder ??
                (context, state, _) =>
                _standardBackgroundBuilder(context, state, child)),
        foregroundBuilder =
        ((context, state, child) =>
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
            )),
        outerBackgroundBuilder = customOuterBackgroundBuilder,
        outerBackgroundChild = customOuterBackgroundBuilderChild,
        toggleWidth = height - borderWidth * 2,
        toggleMargin = EdgeInsets.all(borderWidth),
        foregroundChild = null,
        super(key: key);

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
    Alignment clipAlignment = state.direction == TextDirection.rtl
        ? Alignment.centerLeft
        : Alignment.centerRight;
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
            alignment: clipAlignment,
            child: ClipRect(
              child: Align(
                alignment: clipAlignment,
                widthFactor: 1 - state.position,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _standardForegroundBuilder(BuildContext context,
      ActionSliderState state,
      bool rotating,
      Widget? icon,
      Widget? loadingIcon,
      Widget successIcon,
      Widget failureIcon,
      Color? circleColor,
      ForegroundBuilder? customForegroundBuilder,
      Widget? customForegroundBuilderChild,
      BorderRadius? foregroundBorderRadius,
      AlignmentGeometry iconAlignment,
      Duration crossFadeDuration,) {
    icon ??= Icon(state.direction == TextDirection.rtl
        ? Icons.keyboard_arrow_left_rounded
        : Icons.keyboard_arrow_right_rounded);
    loadingIcon ??= SizedBox(
      width: 24.0,
      height: 24.0,
      child: CircularProgressIndicator(
          strokeWidth: 2.0, color: Theme
          .of(context)
          .iconTheme
          .color),
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
  ActionSliderState? _lastActionSliderState;

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
        _changeState(
            _state.copyWith(
                position: _slideAnimation.value * _state.releasePosition),
            null);
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
    _controller.removeListener(_onModeChange);
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
        _localController = ActionSliderController();
      } else {
        _localController = null;
      }
      _controller.removeListener(_onModeChange);
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
      if (_controller.value.jumpPosition > 0.0) {
        if (_state.state == SlidingState.released) {
          _changeState(
              _state.copyWith(releasePosition: _controller.value.jumpPosition),
              null,
              setState: false);
          _slideAnimationController.forward();
        }
        _controller._setMode(SliderMode.standard, notify: false);
      } else {
        if (_loadingAnimationController.isCompleted) {
          _changeState(
              _state.copyWith(
                  position: 0.0,
                  releasePosition: 0.0,
                  state: SlidingState.released),
              null);
        } else {
          _changeState(
              _state.copyWith(
                  position: _slideAnimationController.value,
                  releasePosition: _slideAnimationController.value,
                  state: SlidingState.released),
              null,
              setState: false);
          _slideAnimationController.reverse(from: 1.0);
        }
        _loadingAnimationController.reverse();
      }
    } else {
      _loadingAnimationController.forward();
      _slideAnimationController.stop();
      _changeState(
          _state = _state.copyWith(
              releasePosition: 0.0, state: SlidingState.compact),
          null);
    }
  }

  void _changeState(SliderState state, ActionSliderState? oldActionSliderState,
      {bool setState = true}) {
    _state = state;
    if (setState) this.setState(() {});
    if (widget.stateChangeCallback == null) return;
    oldActionSliderState ??= _lastActionSliderState;
    if (oldActionSliderState == null) return;
    final actionSliderState = ActionSliderState(
      position: _state.position,
      size: oldActionSliderState.size,
      standardSize: oldActionSliderState.standardSize,
      slidingState: _state.state,
      sliderMode: _controller.value,
      releasePosition: _state.releasePosition,
      toggleSize: oldActionSliderState.toggleSize,
      direction: oldActionSliderState.direction,
    );
    if (_lastActionSliderState != actionSliderState) {
      widget.stateChangeCallback!
          .call(_lastActionSliderState, actionSliderState, _controller);
      _lastActionSliderState = actionSliderState;
    }
  }

  @override
  Widget build(BuildContext context) {
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

            final direction = widget.direction ??
                Directionality.maybeOf(context) ??
                (throw 'No direction is set in ActionSlider and '
                    'no TextDirection is found in BuildContext');

            double localPositionToSliderPosition(double dx) {
              double factor = direction == TextDirection.rtl ? -1.0 : 1.0;
              double result =
              ((dx - widget.toggleWidth / 2) * factor / backgroundWidth);
              return result.clamp(0.0, 1.0);
            }

            final actionSliderState = ActionSliderState(
              position: _state.position,
              size: Size(width, widget.height),
              standardSize: Size(maxWidth, widget.height),
              slidingState: _state.state,
              sliderMode: _controller.value,
              releasePosition: _state.releasePosition,
              toggleSize: Size(toggleWidth, toggleHeight),
              direction: direction,
            );

            _changeState(_state, actionSliderState, setState: false);

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
                              builder: (context) =>
                                  widget.backgroundBuilder!(
                                    context,
                                    actionSliderState,
                                    widget.backgroundChild,
                                  ),
                            ),
                          ),
                        Positioned.directional(
                          textDirection: direction,
                          start: togglePosition,
                          width: toggleWidth,
                          height: toggleHeight,
                          child: GestureDetector(
                            onHorizontalDragStart: (details) {
                              if (_state.state != SlidingState.released ||
                                  !_controller.value.expanded) return;
                              _changeState(
                                  SliderState(
                                    position: localPositionToSliderPosition(
                                        details.localPosition.dx),
                                    state: SlidingState.dragged,
                                  ),
                                  actionSliderState);
                            },
                            onHorizontalDragUpdate: (details) {
                              if (_state.state == SlidingState.dragged) {
                                double newPosition =
                                localPositionToSliderPosition(
                                    details.localPosition.dx);
                                _changeState(
                                    widget.actionThresholdType ==
                                        ThresholdType.release ||
                                        newPosition < widget.actionThreshold
                                        ? SliderState(
                                      position: newPosition,
                                      state: SlidingState.dragged,
                                    )
                                        : SliderState(
                                      position: newPosition,
                                      state: SlidingState.released,
                                      releasePosition: newPosition,
                                          ),
                                    actionSliderState);
                                if (_state.state == SlidingState.released) {
                                  _slideAnimationController.reverse(from: 1.0);
                                  _onSlide();
                                }
                              }
                            },
                            onHorizontalDragEnd: (details) => setState(() {
                              if (_state.state != SlidingState.dragged) return;
                              _changeState(
                                _state.copyWith(
                                    state: SlidingState.released,
                                    releasePosition: _state.position),
                                actionSliderState,
                                setState: false,
                              );
                              _slideAnimationController.reverse(from: 1.0);
                              if (widget.actionThresholdType ==
                                      ThresholdType.release &&
                                  _state.position >= widget.actionThreshold) {
                                _onSlide();
                              }
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
    widget.action?.call(_controller);
  }
}
