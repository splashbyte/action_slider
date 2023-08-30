import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:action_slider/src/cross_fade.dart';
import 'package:action_slider/src/mode.dart';
import 'package:action_slider/src/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SliderBehavior { move, stretch }

enum ThresholdType {
  /// The action is triggered as soon as the threshold is reached.
  /// The slider does not have to be released for this.
  instant,

  /// The action is triggered when the threshold is reached
  /// and the slider is released.
  release,
}

typedef BackgroundBuilder = Widget Function(
    BuildContext, ActionSliderState, Widget?);
typedef ForegroundBuilder = Widget Function(
    BuildContext, ActionSliderState, Widget?);
typedef SliderAction = Function(ActionSliderController controller);
typedef StateChangeCallback = Function(ActionSliderState? oldState,
    ActionSliderState state, ActionSliderController controller);
typedef TapCallback = Function(ActionSliderController controller, double pos);

class ActionSliderController extends ChangeNotifier
    implements ValueListenable<ActionSliderControllerState> {
  ActionSliderControllerState _value;

  ActionSliderController(
      {double anchorPosition = 0.0,
      SliderInterval allowedInterval = const SliderInterval()})
      : _value = ActionSliderControllerState(
            SliderMode.standard, anchorPosition, allowedInterval);

  ActionSliderController.dual(
      {double anchorPosition = 0.5,
      SliderInterval allowedInterval = const SliderInterval()})
      : this(anchorPosition: anchorPosition, allowedInterval: allowedInterval);

  @override
  ActionSliderControllerState get value => _value;

  ///Sets the state to success
  void success() => _setMode(SliderMode.success);

  ///Sets the state to failure
  void failure() => _setMode(SliderMode.failure);

  ///Resets the slider to its expanded state
  void reset() => _setMode(SliderMode.standard);

  void setAnchorPosition(double pos) {
    if (_value.anchorPosition == pos) return;
    if (!_value.allowedInterval.contains(pos)) {
      throw ArgumentError(
          'The allowed interval of a ActionSlider has to contain the anchor position');
    }
    _value = _value.copyWith(anchorPosition: pos);
    notifyListeners();
  }

  void setAllowedInterval(SliderInterval interval) {
    if (_value.allowedInterval == interval) return;
    if (!interval.contains(_value.anchorPosition)) {
      throw ArgumentError(
          'The allowed interval of a ActionSlider has to contain the anchor position');
    }
    _value = _value.copyWith(allowedInterval: interval);
    notifyListeners();
  }

  void setAnchorPositionAndAllowedInterval(
      {double? anchorPosition, SliderInterval? allowedInterval}) {
    anchorPosition ??= _value.anchorPosition;
    allowedInterval ??= _value.allowedInterval;
    if (_value.anchorPosition == anchorPosition &&
        _value.allowedInterval == allowedInterval) {
      return;
    }
    if (!allowedInterval.contains(anchorPosition)) {
      throw ArgumentError(
          'The allowed interval of a ActionSlider has to contain the anchor position');
    }
    _value = _value.copyWith(
        anchorPosition: anchorPosition, allowedInterval: allowedInterval);
    notifyListeners();
  }

  ///Sets the state to loading
  void loading() => _setMode(SliderMode.loading);

  ///The Toggle jumps to [anchorPosition + dif].
  ///[dif] should be between -1.0 and 1.0.
  void jump([double dif = 0.3]) =>
      _setMode(SliderMode.jump((value.anchorPosition + dif).clamp(0.0, 1.0)));

  ///Allows to define custom [SliderMode]s.
  ///This is useful for other results like success or failure.
  ///You get this modes in the [foregroundBuilder] of [ConfirmationSlider.custom] or in the [customForegroundBuilder] of [ConfirmationSlider.standard].
  void custom(SliderMode mode) => _setMode(mode);

  void _setMode(SliderMode mode, {bool notify = true}) {
    if (value.mode == mode) return;
    _value = _value.copyWith(mode: mode);
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

  ///The [Duration] for the sliding animation when the user taps anywhere on the widget.
  final Duration slideAnimationDuration;

  ///The [Duration] for the toggle coming back after the user released it or after the sliding animation.
  final Duration reverseSlideAnimationDuration;

  ///The [Duration] for going into the loading mode.
  final Duration loadingAnimationDuration;

  ///The [Duration] for changing the position of the toggle.
  final Duration movementDuration;

  ///The [Curve] for the sliding animation when the user taps anywhere on the widget.
  final Curve slideAnimationCurve;

  ///The [Curve] for the toggle coming back after the user released it or after the sliding animation.
  final Curve reverseSlideAnimationCurve;

  ///The [Curve] for going into the loading mode.
  final Curve loadingAnimationCurve;

  ///The [Curve] for changing the position of the toggle.
  final Curve movementCurve;

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
  final SliderAction? action;

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

  final ActionSliderController Function() _defaultControllerBuilder;

  final bool needReverse;

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
    this.movementDuration = const Duration(milliseconds: 150),
    this.slideAnimationCurve = Curves.decelerate,
    this.reverseSlideAnimationCurve = Curves.bounceIn,
    this.loadingAnimationCurve = Curves.easeInOut,
    this.movementCurve = Curves.linear,
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
    this.needReverse = true,
  })  : _defaultControllerBuilder = _controllerBuilder,
        super(key: key);

  static _defaultOnTap(ActionSliderController c, double pos) =>
      c.jump(pos < c.value.anchorPosition
          ? max(-0.3, -c.value.anchorPosition)
          : min(0.3, 1 - c.value.anchorPosition));

  static ActionSliderController _controllerBuilder() =>
      ActionSliderController();

  ///Standard constructor for creating a slider.
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
    this.movementDuration = const Duration(milliseconds: 150),
    this.loadingAnimationDuration = const Duration(milliseconds: 350),
    Duration crossFadeDuration = const Duration(milliseconds: 250),
    this.slideAnimationCurve = Curves.decelerate,
    this.reverseSlideAnimationCurve = Curves.bounceIn,
    this.loadingAnimationCurve = Curves.easeInOut,
    this.movementCurve = Curves.linear,
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
    this.needReverse = true,
  })  : backgroundChild = customBackgroundBuilderChild,
        backgroundBuilder = (customBackgroundBuilder ??
            (context, state, _) =>
                _standardBackgroundBuilder(context, state, child)),
        foregroundBuilder =
            ((context, state, child) => _standardForegroundBuilder(
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
        _defaultControllerBuilder = _controllerBuilder,
        super(key: key);

  ///Standard constructor for creating a dual slider.
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
  ActionSlider.dual({
    Key? key,
    Widget? startChild,
    Widget? endChild,
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
    SliderAction? startAction,
    SliderAction? endAction,
    this.onTap = _defaultOnTap,
    this.controller,
    this.width,
    this.slideAnimationDuration = const Duration(milliseconds: 250),
    this.reverseSlideAnimationDuration = const Duration(milliseconds: 1000),
    this.movementDuration = const Duration(milliseconds: 150),
    this.loadingAnimationDuration = const Duration(milliseconds: 350),
    Duration crossFadeDuration = const Duration(milliseconds: 250),
    this.slideAnimationCurve = Curves.decelerate,
    this.reverseSlideAnimationCurve = Curves.bounceIn,
    this.loadingAnimationCurve = Curves.easeInOut,
    this.movementCurve = Curves.linear,
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
    double startActionThreshold = 0.0,
    double endActionThreshold = 1.0,
    this.actionThresholdType = ThresholdType.instant,
    StateChangeCallback? stateChangeCallback,
    this.direction = TextDirection.ltr,
    this.needReverse = true,
  })  : stateChangeCallback = _dualChangeCallback(
            startAction,
            endAction,
            stateChangeCallback,
            actionThresholdType,
            startActionThreshold,
            endActionThreshold),
        backgroundChild = customBackgroundBuilderChild,
        backgroundBuilder = (customBackgroundBuilder ??
            (context, state, _) => _standardDualBackgroundBuilder(
                context, state, startChild, endChild)),
        foregroundBuilder =
            ((context, state, child) => _standardForegroundBuilder(
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
        actionThreshold = 1.0,
        action = null,
        _defaultControllerBuilder = _dualControllerBuilder,
        super(key: key);

  static ActionSliderController _dualControllerBuilder() =>
      ActionSliderController.dual();

  static StateChangeCallback _dualChangeCallback(
      SliderAction? startAction,
      SliderAction? endAction,
      StateChangeCallback? callback,
      ThresholdType thresholdType,
      double startThreshold,
      double endThreshold) {
    return (ActionSliderState? oldState, ActionSliderState state,
        ActionSliderController controller) {
      if (oldState?.position != state.position ||
          oldState?.slidingState != state.slidingState) {
        switch (thresholdType) {
          case ThresholdType.instant:
            if (state.slidingState != SlidingState.dragged) break;
            if (state.position <= startThreshold) {
              startAction?.call(controller);
            } else if (state.position >= endThreshold) {
              endAction?.call(controller);
            }
            break;
          case ThresholdType.release:
            if (oldState?.slidingState == state.slidingState ||
                state.slidingState != SlidingState.released) break;
            if (state.position <= startThreshold) {
              startAction?.call(controller);
            } else if (state.position >= endThreshold) {
              endAction?.call(controller);
            }
            break;
        }
      }
      callback?.call(oldState, state, controller);
    };
  }

  Widget _standardOuterBackgroundBuilder(
      BuildContext context, ActionSliderState state, Widget? child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
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

  static Widget _standardDualBackgroundBuilder(BuildContext context,
      ActionSliderState state, Widget? startChild, Widget? endChild) {
    Alignment startAlignment =
        AlignmentDirectional.centerStart.resolve(state.direction);
    Alignment endAlignment =
        AlignmentDirectional.centerEnd.resolve(state.direction);
    double innerWidth = state.standardSize.width -
        state.toggleSize.width -
        state.toggleMargin.horizontal;
    final startSize = Size(
        innerWidth * state.anchorPosition + state.toggleSize.width / 2,
        state.toggleSize.height);
    final endSize = Size(
        state.standardSize.width -
            state.toggleMargin.horizontal -
            startSize.width,
        state.toggleSize.height);
    return Row(
      textDirection: state.direction,
      children: [
        SizedBox(
          width: (state.size.width -
                      state.toggleSize.width -
                      state.toggleMargin.horizontal) *
                  state.anchorPosition +
              state.toggleSize.width / 2,
          child: ClipRect(
            child: OverflowBox(
              maxWidth: startSize.width,
              maxHeight: startSize.height,
              minWidth: startSize.width,
              minHeight: startSize.height,
              child: Align(
                alignment: startAlignment,
                child: ClipRect(
                  child: Align(
                    alignment: startAlignment,
                    widthFactor: 1.0 -
                        ((1.0 - state.position / state.anchorPosition) *
                                (1.0 -
                                    0.5 *
                                        state.toggleSize.width /
                                        startSize.width))
                            .clamp(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                              end: state.toggleSize.width / 2)
                          .resolve(state.direction),
                      child: Center(child: startChild),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ClipRect(
            child: OverflowBox(
              maxWidth: endSize.width,
              maxHeight: endSize.height,
              minWidth: endSize.width,
              minHeight: endSize.height,
              child: Align(
                alignment: endAlignment,
                child: ClipRect(
                  child: Align(
                    alignment: endAlignment,
                    widthFactor: 1.0 -
                        (((state.position - state.anchorPosition) /
                                    (1.0 - state.anchorPosition)) *
                                (1.0 -
                                    0.5 *
                                        state.toggleSize.width /
                                        endSize.width))
                            .clamp(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                              start: state.toggleSize.width / 2)
                          .resolve(state.direction),
                      child: Center(child: endChild),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _standardForegroundBuilder(
    BuildContext context,
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
    Duration crossFadeDuration,
  ) {
    icon ??= Icon(state.direction == TextDirection.rtl
        ? Icons.keyboard_arrow_left_rounded
        : Icons.keyboard_arrow_right_rounded);
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
  State<ActionSlider> createState() => _ActionSliderState();
}

class _ActionSliderState extends State<ActionSlider>
    with TickerProviderStateMixin {
  late final AnimationController _slideAnimationController;
  late final AnimationController _loadingAnimationController;
  late final AnimationController _movementController;
  late final CurvedAnimation _slideAnimation;
  late final CurvedAnimation _loadingAnimation;
  late final CurvedAnimation _movementAnimation;
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
                position: _state.anchorPosition +
                    _slideAnimation.value *
                        (_state.releasePosition - _state.anchorPosition)),
            null);
      }
    });
    _slideAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _slideAnimationController.reverse();
      }
    });

    if (widget.controller == null) {
      _localController = widget._defaultControllerBuilder();
    }
    _controller.addListener(_onControllerStateChange);

    _movementController = AnimationController(
      vsync: this,
      duration: widget.movementDuration,
      value: _controller.value.anchorPosition,
    );
    _movementAnimation = CurvedAnimation(
      parent: _movementController,
      curve: widget.movementCurve,
    );
    _movementAnimation.addListener(() {
      _changeState(
          _state.copyWith(
              anchorPosition: _movementAnimation.value,
              position: _movementAnimation.value +
                  _slideAnimation.value *
                      (_state.releasePosition - _movementAnimation.value)),
          null);
    });
    _state = SliderState(
      position: _controller.value.anchorPosition,
      anchorPosition: _controller.value.anchorPosition,
      state: SlidingState.released,
    );
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _loadingAnimationController.dispose();
    _controller.removeListener(_onControllerStateChange);
    _localController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _localController?.dispose();
      oldWidget.controller?.removeListener(_onControllerStateChange);
      if (widget.controller == null) {
        _localController = ActionSliderController();
      } else {
        _localController = null;
      }
      _controller.removeListener(_onControllerStateChange);
      _controller.addListener(_onControllerStateChange);
    }
    _slideAnimationController.duration = widget.slideAnimationDuration;
    _slideAnimationController.reverseDuration =
        widget.reverseSlideAnimationDuration;
    _loadingAnimationController.duration = widget.loadingAnimationDuration;
    _slideAnimation.curve = widget.slideAnimationCurve;
    _slideAnimation.reverseCurve = widget.reverseSlideAnimationCurve;
    _loadingAnimation.curve = widget.loadingAnimationCurve;
  }

  void _onControllerStateChange() {
    if (_controller.value.anchorPosition != _state.anchorPosition) {
      _changeState(
          _state.copyWith(anchorPosition: _controller.value.anchorPosition),
          null);
      _movementController.animateTo(_state.anchorPosition);
    }
    if (_controller.value.allowedInterval != _state.allowedInterval) {
      //TODO: animate allowed interval
      _changeState(
          _state.copyWith(allowedInterval: _controller.value.allowedInterval),
          null);
    }
    if (_controller.value.mode.expanded) {
      if (_controller.value.mode.isJump) {
        if (_state.state == SlidingState.released) {
          _changeState(
              _state.copyWith(
                  releasePosition: _controller.value.mode.jumpPosition),
              null,
              setState: false);
          _slideAnimationController.forward();
        }
        _controller._setMode(SliderMode.standard, notify: false);
      } else {
        if (_loadingAnimationController.isCompleted) {
          _changeState(
              _state.copyWith(
                  position: _movementAnimation.value,
                  releasePosition: 0.0,
                  state: SlidingState.released),
              null);
        } else if (_loadingAnimationController.isAnimating) {
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
              releasePosition: _state.position, state: SlidingState.compact),
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
      sliderMode: _controller.value.mode,
      anchorPosition: _state.anchorPosition,
      releasePosition: _state.releasePosition,
      dragStartPosition: _state.dragStartPosition,
      allowedInterval: _state.allowedInterval,
      toggleSize: oldActionSliderState.toggleSize,
      direction: oldActionSliderState.direction,
      toggleMargin: widget.toggleMargin,
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
          animation: _loadingAnimation,
          builder: (context, child) {
            final width = maxWidth - (_loadingAnimation.value * standardWidth);
            final backgroundWidth =
                width - widget.toggleWidth - widget.toggleMargin.horizontal;
            double statePosToLocalPos(double statePos) =>
                (statePos * backgroundWidth).clamp(0.0, backgroundWidth);
            final position = statePosToLocalPos(_state.position);

            double togglePosition;
            double toggleWidth;

            if (widget.sliderBehavior == SliderBehavior.move) {
              togglePosition = position;
              toggleWidth = widget.toggleWidth;
            } else {
              double anchorPos = statePosToLocalPos(_state.anchorPosition);
              togglePosition = min(anchorPos, position);
              toggleWidth = ((position - anchorPos).abs()) + widget.toggleWidth;
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
              return _state.allowedInterval.clamp(result);
            }

            final actionSliderState = ActionSliderState(
              position: _state.position,
              size: Size(width, widget.height),
              standardSize: Size(maxWidth, widget.height),
              slidingState: _state.state,
              sliderMode: _controller.value.mode,
              anchorPosition: _state.anchorPosition,
              releasePosition: _state.releasePosition,
              dragStartPosition: _state.dragStartPosition,
              allowedInterval: _state.allowedInterval,
              toggleSize: Size(toggleWidth, toggleHeight),
              direction: direction,
              toggleMargin: widget.toggleMargin,
            );

            _changeState(_state, actionSliderState, setState: false);

            return GestureDetector(
              onTapUp: (details) {
                if (_state.state != SlidingState.released) return;
                widget.onTap?.call(_controller,
                    localPositionToSliderPosition(details.localPosition.dx));
              },
              child: SizedBox.fromSize(
                size: actionSliderState.size,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    (widget.outerBackgroundBuilder ??
                        widget._standardOuterBackgroundBuilder)(
                      context,
                      actionSliderState,
                      widget.outerBackgroundChild,
                    ),
                    Padding(
                      padding: widget.toggleMargin,
                      child: Stack(children: [
                        if (widget.backgroundBuilder != null)
                          Positioned.fill(
                            child: Opacity(
                              opacity: 1 - _loadingAnimation.value,
                              child: Builder(
                                builder: (context) => widget.backgroundBuilder!(
                                  context,
                                  actionSliderState,
                                  widget.backgroundChild,
                                ),
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
                                  !_controller.value.mode.expanded) return;
                              _changeState(
                                  _state.copyWith(
                                    position: localPositionToSliderPosition(
                                        position + details.localPosition.dx),
                                    state: SlidingState.dragged,
                                    dragStartPosition: _state.position,
                                  ),
                                  actionSliderState);
                            },
                            onHorizontalDragUpdate: (details) {
                              if (_state.state == SlidingState.dragged) {
                                double newPosition =
                                    localPositionToSliderPosition(
                                        statePosToLocalPos(
                                                _state.dragStartPosition) +
                                            details.localPosition.dx);
                                _changeState(
                                    widget.actionThresholdType ==
                                                ThresholdType.release ||
                                            newPosition <
                                                widget.actionThreshold ||
                                            widget.action == null
                                        ? _state.copyWith(
                                            position: newPosition,
                                            state: SlidingState.dragged,
                                          )
                                        : _state.copyWith(
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
                                  releasePosition: _state.position,
                                  dragStartPosition: 0.0,
                                ),
                                actionSliderState,
                                setState: false,
                              );
                              if (widget.needReverse) {
                                  _slideAnimationController.reverse(from: 1.0);
                              }
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
        );
      },
    );
  }

  void _onSlide() {
    widget.action?.call(_controller);
  }
}
