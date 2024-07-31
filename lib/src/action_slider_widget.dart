import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:action_slider/src/cross_fade.dart';
import 'package:action_slider/src/mode.dart';
import 'package:action_slider/src/state.dart';
import 'package:flutter/cupertino.dart';
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
typedef NullableForegroundBuilder = Widget? Function(
    BuildContext, ActionSliderState, Widget?);
typedef ForegroundBuilder = Widget Function(
    BuildContext, ActionSliderState, Widget?);
typedef SliderAction = Function(ActionSliderController controller);
typedef StateChangeCallback = Function(ActionSliderState? oldState,
    ActionSliderState state, ActionSliderController controller);
typedef TapCallback = Function(ActionSliderController controller, double pos);

BorderRadiusGeometry _edgeInsetsToBorderRadius(EdgeInsetsGeometry edgeInsets) {
  return switch (edgeInsets) {
    EdgeInsets() => BorderRadius.only(
        topLeft: Radius.circular(min(edgeInsets.top, edgeInsets.left)),
        topRight: Radius.circular(min(edgeInsets.top, edgeInsets.right)),
        bottomLeft: Radius.circular(min(edgeInsets.bottom, edgeInsets.left)),
        bottomRight: Radius.circular(min(edgeInsets.bottom, edgeInsets.right)),
      ),
    EdgeInsetsDirectional() => BorderRadiusDirectional.only(
        topStart: Radius.circular(min(edgeInsets.top, edgeInsets.start)),
        topEnd: Radius.circular(min(edgeInsets.top, edgeInsets.end)),
        bottomStart: Radius.circular(min(edgeInsets.bottom, edgeInsets.start)),
        bottomEnd: Radius.circular(min(edgeInsets.bottom, edgeInsets.end)),
      ),
    _ => BorderRadius.zero,
  };
}

class _FixedValueListenable extends ValueListenable<double> {
  @override
  final double value;

  _FixedValueListenable(this.value);

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class ActionSliderController extends ChangeNotifier
    implements ValueListenable<ActionSliderControllerState> {
  ActionSliderControllerState _value;

  ActionSliderController(
      {double anchorPosition = 0.0,
      SliderInterval allowedInterval = const SliderInterval()})
      : _value = ActionSliderControllerState(
          mode: SliderMode.standard,
          anchorPosition: anchorPosition,
          allowedInterval: allowedInterval,
          direction: SliderDirection.end,
        );

  ActionSliderController.dual(
      {double anchorPosition = 0.5,
      SliderInterval allowedInterval = const SliderInterval()})
      : this(anchorPosition: anchorPosition, allowedInterval: allowedInterval);

  @override
  ActionSliderControllerState get value => _value;

  ///Sets the state to success with a compact slider.
  void success() => _setMode(SliderMode.success, SliderDirection.end);

  ///Sets the state to success with an expanded slider.
  void successExpanded({SliderDirection direction = SliderDirection.end}) =>
      _setMode(SliderMode.successExpanded, direction);

  ///Sets the state to failure with a compact slider.
  void failure() => _setMode(SliderMode.failure, SliderDirection.end);

  ///Sets the state to success with an expanded slider.
  void failureExpanded({SliderDirection direction = SliderDirection.end}) =>
      _setMode(SliderMode.failureExpanded, direction);

  ///Sets the state to loading with a compact slider.
  void loading() => _setMode(SliderMode.loading, SliderDirection.end);

  ///Sets the state to loading with an expanded slider.
  void loadingExpanded({SliderDirection direction = SliderDirection.end}) =>
      _setMode(SliderMode.loadingExpanded, direction);

  ///Resets the slider to its standard expanded state.
  void reset() => _setMode(SliderMode.standard, SliderDirection.end);

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

  ///The Toggle jumps to [anchorPosition + dif].
  ///[dif] should be between -1.0 and 1.0.
  void jump([double dif = 0.3]) => _setMode(
      SliderMode.jump((value.anchorPosition + dif).clamp(0.0, 1.0)),
      SliderDirection.end);

  ///Allows to define custom [SliderMode]s.
  ///This is useful for other results like success or failure.
  ///You get this modes in the [foregroundBuilder] of [ConfirmationSlider.custom] or in the [customForegroundBuilder] of [ConfirmationSlider.standard].
  void custom(SliderMode mode,
          {SliderDirection direction = SliderDirection.end}) =>
      _setMode(mode, direction);

  void _setMode(SliderMode mode, SliderDirection direction,
      {bool notify = true}) {
    if (value.mode == mode) return;
    _value = _value.copyWith(mode: mode, direction: direction);
    if (notify) notifyListeners();
  }
}

class ActionSlider extends StatefulWidget {
  ///The width of the sliding toggle.
  final double toggleWidth;

  ///The margin of the sliding toggle.
  final EdgeInsetsGeometry toggleMargin;

  ///The margin of the sliding toggle when the current [SliderMode] is a result
  ///like [SliderMode.success] or [SliderMode.failure].
  final EdgeInsetsGeometry? resultToggleMargin;

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
  final Duration sizeAnimationDuration;

  ///The [Duration] for changing the position of the anchor.
  final Duration anchorPositionDuration;

  ///The [Duration] for changing the [toggleMargin] and animating
  ///between [toggleMargin] and [resultToggleMargin].
  final Duration toggleMarginDuration;

  ///The [Curve] for the sliding animation when the user taps anywhere on the widget.
  final Curve slideAnimationCurve;

  ///The [Curve] for the toggle coming back after the user released it or after the sliding animation.
  final Curve reverseSlideAnimationCurve;

  ///The [Curve] for going into the loading mode.
  final Curve sizeAnimationCurve;

  ///The [Curve] for changing the position of the anchor.
  final Curve anchorPositionCurve;

  ///The [Curve] for changing the [toggleMargin] and animating
  ///between [toggleMargin] and [resultToggleMargin].
  final Curve toggleMarginCurve;

  ///The [Color] of the [Container] in the background.
  final Color? backgroundColor;

  ///[BorderRadius] of the [Container] in the background.
  final BorderRadiusGeometry backgroundBorderRadius;

  ///The [BoxShadow] of the background [Container].
  final List<BoxShadow> boxShadow;

  ///Callback for sliding completely to the right.
  ///Here you should call the loading, success and failure methods of the
  ///[controller] for controlling the further behavior/animations of the
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

  ///This [SliderBehavior] defines the behavior when moving the toggle.
  final SliderBehavior sliderBehavior;

  ///The threshold at which the action should be triggered. Should be between 0.0 and 1.0.
  final double actionThreshold;

  ///The [ThresholdType] of the [actionThreshold].
  final ThresholdType actionThresholdType;

  ///The direction of the slider.
  ///
  /// If set to [null], the [TextDirection] is fetched from the [BuildContext].
  final TextDirection? direction;

  final ActionSliderController Function() _defaultControllerBuilder;

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
    this.sizeAnimationDuration = const Duration(milliseconds: 350),
    this.width,
    this.reverseSlideAnimationDuration = const Duration(milliseconds: 250),
    this.anchorPositionDuration = const Duration(milliseconds: 150),
    this.slideAnimationCurve = Curves.decelerate,
    this.reverseSlideAnimationCurve = Curves.bounceIn,
    this.sizeAnimationCurve = Curves.easeInOut,
    this.anchorPositionCurve = Curves.linear,
    this.toggleMarginCurve = Curves.easeInOut,
    this.toggleMarginDuration = const Duration(milliseconds: 350),
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
    this.resultToggleMargin,
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
    NullableForegroundBuilder? customForegroundBuilder,
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
    this.anchorPositionDuration = const Duration(milliseconds: 150),
    this.sizeAnimationDuration = const Duration(milliseconds: 350),
    Duration crossFadeDuration = const Duration(milliseconds: 250),
    this.slideAnimationCurve = Curves.decelerate,
    this.reverseSlideAnimationCurve = Curves.bounceIn,
    this.sizeAnimationCurve = Curves.easeInOut,
    this.anchorPositionCurve = Curves.linear,
    AlignmentGeometry iconAlignment = Alignment.center,
    this.backgroundBorderRadius =
        const BorderRadius.all(Radius.circular(100.0)),
    BorderRadiusGeometry? foregroundBorderRadius,
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
    this.resultToggleMargin,
    this.toggleMarginCurve = Curves.easeInOut,
    this.toggleMarginDuration = const Duration(milliseconds: 350),
  })  : backgroundChild = customBackgroundBuilderChild,
        backgroundBuilder = (customBackgroundBuilder ??
            (context, state, _) =>
                _standardBackgroundBuilder(context, state, child)),
        foregroundBuilder = ((context, state, child) =>
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
              foregroundBorderRadius ??
                  backgroundBorderRadius
                      .subtract(_edgeInsetsToBorderRadius(state.toggleMargin)),
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
    this.anchorPositionDuration = const Duration(milliseconds: 150),
    this.sizeAnimationDuration = const Duration(milliseconds: 350),
    Duration crossFadeDuration = const Duration(milliseconds: 250),
    this.slideAnimationCurve = Curves.decelerate,
    this.reverseSlideAnimationCurve = Curves.bounceIn,
    this.sizeAnimationCurve = Curves.easeInOut,
    this.anchorPositionCurve = Curves.linear,
    AlignmentGeometry iconAlignment = Alignment.center,
    this.backgroundBorderRadius =
        const BorderRadius.all(Radius.circular(100.0)),
    BorderRadiusGeometry? foregroundBorderRadius,
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
    this.resultToggleMargin,
    this.toggleMarginCurve = Curves.easeInOut,
    this.toggleMarginDuration = const Duration(milliseconds: 350),
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
        foregroundBuilder = ((context, state, child) =>
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
              foregroundBorderRadius ??
                  backgroundBorderRadius
                      .subtract(_edgeInsetsToBorderRadius(state.toggleMargin)),
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
        state.defaultToggleSize.width -
        state.toggleMargin.horizontal;
    final startSize = Size(
        innerWidth * state.anchorPosition + state.defaultToggleSize.width / 2,
        state.defaultToggleSize.height);
    final endSize = Size(
        state.standardSize.width -
            state.toggleMargin.horizontal -
            startSize.width,
        state.defaultToggleSize.height);
    return Row(
      textDirection: state.direction,
      children: [
        SizedBox(
          width: (state.size.width -
                      state.defaultToggleSize.width -
                      state.toggleMargin.horizontal) *
                  state.anchorPosition +
              state.defaultToggleSize.width / 2,
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
                                        state.defaultToggleSize.width /
                                        startSize.width))
                            .clamp(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                              end: state.defaultToggleSize.width / 2)
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
                                        state.defaultToggleSize.width /
                                        endSize.width))
                            .clamp(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                              start: state.defaultToggleSize.width / 2)
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
    NullableForegroundBuilder? customForegroundBuilder,
    Widget? customForegroundBuilderChild,
    BorderRadiusGeometry foregroundBorderRadius,
    AlignmentGeometry iconAlignment,
    Duration crossFadeDuration,
  ) {
    final theme = Theme.of(context);
    icon ??= Icon(state.direction == TextDirection.rtl
        ? Icons.keyboard_arrow_left_rounded
        : Icons.keyboard_arrow_right_rounded);
    loadingIcon ??= switch (theme.platform) {
      TargetPlatform.iOS ||
      TargetPlatform.macOS =>
        CupertinoActivityIndicator(color: theme.iconTheme.color),
      _ => SizedBox.square(
          dimension: 24.0,
          child: CircularProgressIndicator(
              strokeWidth: 2.0, color: theme.iconTheme.color),
        ),
    };
    double radius = state.size.height / 2;

    return Container(
      decoration: BoxDecoration(
          borderRadius: foregroundBorderRadius,
          color: circleColor ?? theme.primaryColor),
      child: SliderCrossFade<SliderMode>(
        duration: crossFadeDuration * (1 / 0.3),
        current: state.sliderMode,
        builder: (context, mode) {
          final customIcon = customForegroundBuilder?.call(
            context,
            state,
            customForegroundBuilderChild,
          );
          if (customIcon != null) {
            icon = customIcon;
          } else if (mode.custom) {
            throw StateError('For custom SliderModes you have to '
                'return something in customForegroundBuilder!');
          }
          Widget child = switch (mode) {
            SliderMode.loading || SliderMode.loadingExpanded => loadingIcon!,
            SliderMode.success || SliderMode.successExpanded => successIcon,
            SliderMode.failure || SliderMode.failureExpanded => failureIcon,
            _ => rotating && !mode.result
                ? Transform.rotate(
                    angle: ((state.size.width * state.position) -
                            state.size.width * state.anchorPosition)
                         /
                        radius,
                    child: icon)
                : icon!,
          };
          return Align(alignment: iconAlignment, child: child);
        },
        size: (m1, m2) => m2.highlighted,
      ),
    );
  }

  @override
  State<ActionSlider> createState() => _ActionSliderState();
}

class _ActionSliderState extends State<ActionSlider>
    with TickerProviderStateMixin {
  late final AnimationController _slideAnimationController;
  late final AnimationController _anchorController;
  late final CurvedAnimation _slideAnimation;
  late final CurvedAnimation _anchorCurvedAnimation;
  late final Animation<double> _anchorAnimation;
  late final Tween<double> _anchorAnimationTween;
  ActionSliderController? _localController;
  ActionSliderState? _lastActionSliderState;

  ActionSliderController get _controller =>
      widget.controller ?? _localController!;
  SliderState _state = SliderState(position: 0.0, state: SlidingState.released);

  /// The start position of the current running [_slideAnimation].
  ValueListenable<double> _startPosition = _FixedValueListenable(0.0);

  @override
  void initState() {
    super.initState();
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
        _updatePosition();
      }
    });
    _slideAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          !_controller.value.mode.result) {
        _dropSlider();
      }
    });

    if (widget.controller == null) {
      _localController = widget._defaultControllerBuilder();
    }
    _controller.addListener(_onControllerStateChange);

    _anchorController = AnimationController(
      vsync: this,
      duration: widget.anchorPositionDuration,
      value: _controller.value.anchorPosition,
    );
    _anchorAnimation = Tween(
            begin: _controller.value.anchorPosition,
            end: _controller.value.anchorPosition)
        .animate(_anchorCurvedAnimation = CurvedAnimation(
      parent: _anchorController,
      curve: widget.anchorPositionCurve,
    ));
    _anchorController.addListener(_updatePosition);
    _state = SliderState(
      position: _controller.value.anchorPosition,
      anchorPosition: _controller.value.anchorPosition,
      state: SlidingState.released,
    );
  }

  void _updatePosition({SlidingState? state}) {
    _changeState(
        _state.copyWith(
          anchorPosition: _anchorAnimation.value,
          position: _startPosition.value +
              _slideAnimation.value *
                  (_state.releasePosition - _startPosition.value),
          state: state,
        ),
        null);
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
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
    _slideAnimation.curve = widget.slideAnimationCurve;
    _slideAnimation.reverseCurve = widget.reverseSlideAnimationCurve;
    _anchorCurvedAnimation.curve = widget.anchorPositionCurve;
    _anchorController.duration = widget.anchorPositionDuration;
  }

  void _onControllerStateChange() {
    final controllerValue = _controller.value;
    final direction = controllerValue.direction;
    if (controllerValue.anchorPosition != _state.anchorPosition) {
      _anchorAnimationTween.begin = _anchorAnimation.value;
      _anchorAnimationTween.end = controllerValue.anchorPosition;
      _anchorController.forward(from: 0.0);
      _updatePosition();
    }
    if (controllerValue.allowedInterval != _state.allowedInterval) {
      //TODO: animate allowed interval
      _changeState(
          _state.copyWith(allowedInterval: controllerValue.allowedInterval),
          null);
    }
    if (controllerValue.mode.expanded) {
      if (controllerValue.mode.isJump) {
        if (_state.state == SlidingState.released) {
          _animateSliderTo(controllerValue.mode.jumpPosition);
        }
        _controller._setMode(SliderMode.standard, SliderDirection.end,
            notify: false);
      } else if (controllerValue.mode.result) {
        _animateSliderTo(direction == SliderDirection.start
            ? controllerValue.allowedInterval.start
            : controllerValue.allowedInterval.end);
        _updatePosition(state: SlidingState.fixed);
      } else {
        if (_lastActionSliderState?.relativeSize != 0.0) {
          _dropSlider();
        } else {
          _slideAnimationController.value = 0.0;
          _changeState(
              _state.copyWith(
                anchorPosition: _state.anchorPosition,
                position: _state.anchorPosition,
                state: SlidingState.released,
              ),
              null);
          _anchorAnimationTween = Tween(
            begin: controllerValue.anchorPosition,
            end: controllerValue.anchorPosition,
          );
          _anchorController.stop();
        }
      }
    } else {
      _slideAnimationController.stop();
      _changeState(
          _state = _state.copyWith(
              releasePosition: _state.position, state: SlidingState.compact),
          null);
    }
  }

  void _animateSliderTo(double position) {
    _startPosition = _FixedValueListenable(_state.position);
    _changeState(_state.copyWith(releasePosition: position), null,
        setState: false);
    _slideAnimationController.forward(from: 0.0);
  }

  void _dropSlider() {
    _startPosition = _anchorAnimation;
    _changeState(
        _state.copyWith(
          releasePosition: _state.position,
          state: SlidingState.released,
        ),
        null,
        setState: false);
    _slideAnimationController.reverse(from: 1.0);
  }

  void _changeState(SliderState state, ActionSliderState? oldActionSliderState,
      {bool setState = true}) {
    _state = state;
    if (setState) this.setState(() {});
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
      toggleMargin: oldActionSliderState.toggleMargin,
      relativeSize: oldActionSliderState.relativeSize,
      defaultToggleSize: oldActionSliderState.defaultToggleSize,
    );
    if (_lastActionSliderState != actionSliderState) {
      widget.stateChangeCallback
          ?.call(_lastActionSliderState, actionSliderState, _controller);
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
        final toggleMargin = _controller.value.mode.result
            ? widget.resultToggleMargin ?? widget.toggleMargin
            : widget.toggleMargin;
        return TweenAnimationBuilder<EdgeInsetsGeometry>(
            curve: widget.toggleMarginCurve,
            duration: widget.toggleMarginDuration,
            tween:
                EdgeInsetsGeometryTween(begin: toggleMargin, end: toggleMargin),
            builder: (context, toggleMargin, child) {
              final relativeSize = _controller.value.mode.expanded ? 1.0 : 0.0;
              return TweenAnimationBuilder<double>(
                curve: widget.sizeAnimationCurve,
                duration: widget.sizeAnimationDuration,
                tween: Tween(begin: relativeSize, end: relativeSize),
                builder: (context, relativeSize, child) {
                  final width =
                      maxWidth - ((1.0 - relativeSize) * standardWidth);
                  final backgroundWidth =
                      width - widget.toggleWidth - toggleMargin.horizontal;
                  double statePosToLocalPos(double statePos) =>
                      statePos.clamp(0.0, 1.0) * backgroundWidth;
                  final position = statePosToLocalPos(_state.position);

                  double togglePosition;
                  double toggleWidth;

                  switch (widget.sliderBehavior) {
                    case SliderBehavior.move:
                      togglePosition = position;
                      toggleWidth = widget.toggleWidth;
                    case SliderBehavior.stretch:
                      double anchorPos =
                          statePosToLocalPos(_state.anchorPosition);
                      togglePosition = min(anchorPos, position);
                      toggleWidth =
                          ((position - anchorPos).abs()) + widget.toggleWidth;
                  }

                  final toggleHeight = widget.height - toggleMargin.vertical;

                  final direction = widget.direction ??
                      Directionality.maybeOf(context) ??
                      (throw 'No direction is set in ActionSlider and '
                          'no TextDirection is found in BuildContext');

                  double localPositionToSliderPosition(double dx) {
                    double factor = direction == TextDirection.rtl ? -1.0 : 1.0;
                    return ((dx - widget.toggleWidth / 2) *
                        factor /
                        backgroundWidth);
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
                    toggleMargin: toggleMargin,
                    relativeSize: relativeSize,
                    defaultToggleSize: Size(widget.toggleWidth, toggleHeight),
                  );

                  _changeState(_state, actionSliderState, setState: false);

                  return GestureDetector(
                    onTapUp: (details) {
                      if (_state.state != SlidingState.released) return;
                      widget.onTap?.call(
                          _controller,
                          localPositionToSliderPosition(
                              details.localPosition.dx));
                    },
                    child: SizedBox.fromSize(
                      size: actionSliderState.size,
                      child: Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.passthrough,
                        children: [
                          (widget.outerBackgroundBuilder ??
                              widget._standardOuterBackgroundBuilder)(
                            context,
                            actionSliderState,
                            widget.outerBackgroundChild,
                          ),
                          Padding(
                            padding: toggleMargin,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                if (widget.backgroundBuilder != null)
                                  Positioned.fill(
                                    child: Opacity(
                                      opacity: relativeSize,
                                      child: Builder(
                                        builder: (context) =>
                                            widget.backgroundBuilder!(
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
                                      if (_state.state !=
                                              SlidingState.released ||
                                          !_controller.value.mode.expanded) {
                                        return;
                                      }
                                      _changeState(
                                          _state.copyWith(
                                            position: _state.allowedInterval
                                                .clamp(
                                                    localPositionToSliderPosition(
                                                        position +
                                                            details
                                                                .localPosition
                                                                .dx)),
                                            state: SlidingState.dragged,
                                            dragStartPosition: _state.position,
                                          ),
                                          actionSliderState);
                                    },
                                    onHorizontalDragUpdate: (details) {
                                      if (_state.state ==
                                          SlidingState.dragged) {
                                        double newPosition = _state
                                            .allowedInterval
                                            .clamp(localPositionToSliderPosition(
                                                statePosToLocalPos(_state
                                                        .dragStartPosition) +
                                                    details.localPosition.dx));
                                        _changeState(
                                            widget.actionThresholdType ==
                                                        ThresholdType.release ||
                                                    newPosition <
                                                        widget
                                                            .actionThreshold ||
                                                    widget.action == null
                                                ? _state.copyWith(
                                                    position: newPosition,
                                                    state: SlidingState.dragged,
                                                  )
                                                : _state.copyWith(
                                                    position: newPosition,
                                                    state:
                                                        SlidingState.released,
                                                    releasePosition:
                                                        newPosition,
                                                  ),
                                            actionSliderState);
                                        if (_state.state ==
                                            SlidingState.released) {
                                          _slideAnimationController.reverse(
                                              from: newPosition);
                                          _onSlide();
                                        }
                                      }
                                    },
                                    onHorizontalDragEnd: (details) =>
                                        setState(() {
                                      if (_state.state !=
                                          SlidingState.dragged) {
                                        return;
                                      }
                                      _dropSlider();
                                      if (widget.actionThresholdType ==
                                              ThresholdType.release &&
                                          _state.position >=
                                              widget.actionThreshold) {
                                        _onSlide();
                                      }
                                    }),
                                    child: MouseRegion(
                                      cursor: _state.state ==
                                              SlidingState.compact
                                          ? MouseCursor.defer
                                          : (_state.state ==
                                                  SlidingState.released
                                              ? SystemMouseCursors.grab
                                              : SystemMouseCursors.grabbing),
                                      child: Builder(
                                        builder: (context) =>
                                            widget.foregroundBuilder(
                                          context,
                                          actionSliderState,
                                          widget.foregroundChild,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            });
      },
    );
  }

  void _onSlide() {
    widget.action?.call(_controller);
  }
}
