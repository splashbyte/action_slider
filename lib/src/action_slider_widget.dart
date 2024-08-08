import 'dart:math';

import 'package:action_slider/src/cross_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'state.dart';
part 'status.dart';

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
typedef TapCallback = Function(
    ActionSliderController controller, ActionSliderState state, double pos);

BorderRadiusGeometry _subtractPaddingFromBorderRadius(
    BorderRadiusGeometry borderRadius, EdgeInsetsGeometry edgeInsets) {
  final subtractedBorderRadius = switch (edgeInsets) {
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
  return borderRadius.subtract(subtractedBorderRadius);
}

/// Indicates the position of the [child] when using the [child] parameter of
/// [ActionSlider.standard].
enum SliderChildPosition {
  /// No explicit positioning of the child by the package.
  ///
  /// This gives you full control.
  none,

  /// The [child] is positioned in the center of the slider.
  ///
  /// If you want to prevent overlapping with the toggle, you should use
  /// [centerWithPadding], [centerFreeArea], [centerFreeAreaWithPadding],
  /// [balanced] or [balancedWithPadding].
  center,

  /// The [child] is positioned in the center of the slider with an additional
  /// padding for preventing overlapping with the toggle.
  ///
  /// If you want a smaller padding, you should use
  /// [center], [centerFreeArea], [centerFreeAreaWithPadding], [balanced] or
  /// [balancedWithPadding].
  centerWithPadding,

  /// The child is positioned in the center of the free area of the slider.
  centerFreeArea,

  /// The child is positioned in the center of the free area of the slider with
  /// an additional padding for preventing getting clipped by the edge of the
  /// slider.
  centerFreeAreaWithPadding,

  /// A small [child] is positioned more in the center of the slider than a
  /// large [child] but it never overlaps with the toggle.
  balanced,

  /// [balanced] but with an extra padding for preventing getting clipped by the
  /// edge of the slider.
  balancedWithPadding,
}

/// The animation that is applied to the children when the toggle moves in
/// [ActionSlider.standard] and [ActionSlider.dual].
enum SliderChildAnimation {
  /// No animation
  none,

  /// The child gets clipped so it disappears behind the toggle.
  clip,

  /// The child fades away while moving the toggle to the end.
  fade,

  /// Combination of [clip] and [fade].
  clipAndFade,
}

/// The animation that is applied to the icon when the toggle moves in
/// [ActionSlider.standard] and [ActionSlider.dual].
enum SliderIconAnimation {
  /// No animation
  none,

  /// The icon rolls when dragging the slider.
  roll,

  /// The icon turns by 180° while dragging the slider.
  turn,
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return switch (theme.platform) {
      TargetPlatform.iOS ||
      TargetPlatform.macOS =>
        CupertinoActivityIndicator(color: theme.iconTheme.color),
      _ => SizedBox.square(
          dimension: 24.0,
          child: CircularProgressIndicator(
              strokeWidth: 2.0, color: theme.iconTheme.color),
        ),
    };
  }
}

class _DefaultToggleIcon extends StatelessWidget {
  const _DefaultToggleIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(switch (ActionSliderState.of(context).direction) {
      TextDirection.rtl => Icons.keyboard_arrow_left_rounded,
      TextDirection.ltr => Icons.keyboard_arrow_right_rounded,
    });
  }
}

class _FixedValueListenable extends ValueListenable<double> {
  @override
  final double value;

  const _FixedValueListenable(this.value);

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class ActionSliderController extends ChangeNotifier
    implements ValueListenable<ActionSliderControllerState> {
  ActionSliderControllerState _value;

  ActionSliderController({SliderStatus status = const SliderStatus.standard()})
      : _value = ActionSliderControllerState._(status: status);

  @override
  ActionSliderControllerState get value => _value;

  /// Sets the status to success.
  ///
  /// {@macro action_slider.status.expanded}
  ///
  /// {@macro action_slider.status.highlighted}
  ///
  /// {@macro action_slider.status.side}
  void success({
    bool expanded = false,
    SliderSide side = SliderSide.end,
    bool highlighted = true,
  }) =>
      _setStatus(SliderStatus.success(
          expanded: expanded, side: side, highlighted: highlighted));

  /// Sets the status to failure.
  ///
  /// {@macro action_slider.status.expanded}
  ///
  /// {@macro action_slider.status.highlighted}
  ///
  /// {@macro action_slider.status.side}
  void failure({
    bool expanded = false,
    SliderSide side = SliderSide.end,
    bool highlighted = true,
  }) =>
      _setStatus(SliderStatus.failure(
          expanded: expanded, side: side, highlighted: highlighted));

  /// Sets the status to loading.
  ///
  /// {@macro action_slider.status.expanded}
  ///
  /// {@macro action_slider.status.highlighted}
  ///
  /// {@macro action_slider.status.side}
  void loading({
    bool expanded = false,
    SliderSide side = SliderSide.end,
    bool highlighted = false,
  }) =>
      _setStatus(SliderStatus.loading(
          expanded: expanded, side: side, highlighted: highlighted));

  /// Resets the slider to its standard expanded status.
  ///
  /// {@macro action_slider.status.highlighted}
  void reset({bool highlighted = false}) =>
      _setStatus(SliderStatus.standard(highlighted: highlighted));

  ///The Toggle jumps to [anchorPosition] + [height].
  ///
  ///[height] should be between [-1.0] and [1.0].
  void jump([double height = 0.3]) {
    _value = _value._copyWith(jump: _SliderJump(height: height));
    notifyListeners();
  }

  ///Allows to set a custom [SliderStatus].
  ///This is useful for other results like success or failure.
  ///
  ///You get this status in the [foregroundBuilder] of [ActionSlider.custom] or
  ///in the [customIconBuilder] of [ActionSlider.standard] and
  ///[ActionSlider.dual].
  void custom(SliderStatus status) => _setStatus(status);

  void _setStatus(SliderStatus status, {bool notify = true}) {
    if (value.status == status) return;
    _value = _value._copyWith(status: status);
    if (notify) notifyListeners();
  }
}

class ActionSlider extends StatefulWidget {
  ///The width of the sliding toggle.
  ///
  /// The default value is [height] - [toggleMargin.vertical]
  final double? toggleWidth;

  ///The margin of the sliding toggle.
  final EdgeInsetsGeometry toggleMargin;

  ///The margin of the sliding toggle when the current [SliderStatus] is a result
  ///like [SliderStatus.success] or [SliderStatus.failure].
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

  ///The [Duration] for going into the loading status.
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

  ///The [Curve] for going into the loading status.
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

  ///Callback for tapping on the [ActionSlider].
  ///Defaults to a jump in the direction of the tap position.
  ///
  ///This is only called if the toggle is currently not dragged.
  ///If you want onTap to be called in any case, you should wrap the slider
  ///in a [GestureDetector].
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

  /// The default position of the toggle between [0.0] and [1.0].
  final double anchorPosition;

  /// The interval in which the toggle of the slider can be moved by the user.
  final SliderInterval allowedInterval;

  /// Sets the [SliderStatus] of this slider.
  ///
  /// When this value is set, the status changes of the controller are ignored.
  final SliderStatus? status;

  /// Constructor with maximum customizability.
  const ActionSlider.custom({
    super.key,
    this.status,
    this.outerBackgroundBuilder,
    this.backgroundBuilder,
    required this.foregroundBuilder,
    this.toggleWidth,
    this.toggleMargin = const EdgeInsets.all(5.0),
    this.height = 65.0,
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
    this.slideAnimationDuration = const Duration(milliseconds: 250),
    this.reverseSlideAnimationDuration = const Duration(milliseconds: 1000),
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
    this.anchorPosition = 0.0,
    this.allowedInterval = const SliderInterval(),
  }) : _defaultControllerBuilder = _controllerBuilder;

  static _defaultOnTap(
          ActionSliderController c, ActionSliderState state, double pos) =>
      c.jump(pos < state.anchorPosition ? -0.3 : 0.3);

  static ActionSliderController _controllerBuilder() =>
      ActionSliderController();

  ///Standard constructor for creating a slider.
  ///
  /// {@template action_slider.constructor.standard.builders}
  ///[customIconBuilder] is useful if you use your own [SliderStatus]s and need icons additional to [successIcon], [failureIcon], [loadingIcon] and [icon].
  ///You can also use [customIconBuilderChild] with the [customIconBuilder] for efficiency reasons.
  ///
  ///If [customBackgroundBuilder] is not null, the value of [child] is ignored.
  ///You can also use [customBackgroundBuilderChild] with the [customBackgroundBuilder] for efficiency reasons.
  ///
  ///If [customOuterBackgroundBuilder] is not null, the values of [backgroundColor], [backgroundBorderRadius] and [boxShadow] are ignored.
  ///You can also use [customOuterBackgroundBuilderChild] with the [customOuterBackgroundBuilder] for efficiency reasons.
  ///
  /// {@endtemplate}
  /// {@template action_slider.constructor.standard.icons}
  /// [icon] is the icon which is shown when [status] is a [SliderStatusStandard].
  ///
  /// [loadingIcon] is the icon which is shown when [status] is a [SliderStatusLoading].
  ///
  /// [successIcon] is the icon which is shown when [status] is a [SliderStatusSuccess].
  ///
  /// [failureIcon] is the icon which is shown when [status] is a [SliderStatusFailure].
  ///
  /// For overriding the icons or supporting a custom [SliderStatus], you can implement a [customIconBuilder].
  /// You can also use [customIconBuilderChild] for improving performance of [customIconBuilder] if possible.
  /// {@endtemplate}
  ActionSlider.standard({
    super.key,
    this.status,
    Widget? child,
    Widget loadingIcon = const _LoadingIndicator(),
    Widget successIcon = const Icon(Icons.check_rounded),
    Widget failureIcon = const Icon(Icons.close_rounded),
    Widget icon = const _DefaultToggleIcon(),
    NullableForegroundBuilder? customIconBuilder,
    Widget? customIconBuilderChild,
    BackgroundBuilder? customBackgroundBuilder,
    Widget? customBackgroundBuilderChild,
    BackgroundBuilder? customOuterBackgroundBuilder,
    Widget? customOuterBackgroundBuilderChild,
    Color? toggleColor,
    this.backgroundColor,
    this.height = 65.0,
    double borderWidth = 5.0,
    double? resultBorderWidth,
    SliderIconAnimation iconAnimation = SliderIconAnimation.none,
    SliderChildAnimation childAnimation = SliderChildAnimation.clip,
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
    this.toggleMarginCurve = Curves.easeInOut,
    this.toggleMarginDuration = const Duration(milliseconds: 350),
    this.anchorPosition = 0.0,
    this.allowedInterval = const SliderInterval(),
    SliderChildPosition childPosition = SliderChildPosition.balanced,
    this.toggleWidth,
  })  : backgroundChild = customBackgroundBuilderChild,
        backgroundBuilder = (customBackgroundBuilder ??
            (context, state, _) => _standardBackgroundBuilder(
                context, state, child, childPosition, childAnimation)),
        foregroundBuilder =
            ((context, state, child) => _standardForegroundBuilder(
                  context,
                  state,
                  iconAnimation,
                  icon,
                  loadingIcon,
                  successIcon,
                  failureIcon,
                  toggleColor,
                  customIconBuilder,
                  customIconBuilderChild,
                  foregroundBorderRadius ??
                      _subtractPaddingFromBorderRadius(
                          backgroundBorderRadius, state.toggleMargin),
                  iconAlignment,
                  crossFadeDuration,
                )),
        outerBackgroundBuilder = customOuterBackgroundBuilder,
        outerBackgroundChild = customOuterBackgroundBuilderChild,
        toggleMargin = EdgeInsets.all(borderWidth),
        resultToggleMargin = resultBorderWidth == null
            ? null
            : EdgeInsets.all(resultBorderWidth),
        foregroundChild = null,
        _defaultControllerBuilder = _controllerBuilder;

  ///Standard constructor for creating a dual slider.
  ///
  /// {@macro action_slider.constructor.standard.builders}
  ///
  /// {@macro action_slider.constructor.standard.icons}
  ActionSlider.dual({
    super.key,
    this.status,
    Widget? startChild,
    Widget? endChild,
    Widget loadingIcon = const _LoadingIndicator(),
    Widget successIcon = const Icon(Icons.check_rounded),
    Widget failureIcon = const Icon(Icons.close_rounded),
    Widget icon = const _DefaultToggleIcon(),
    ForegroundBuilder? customIconBuilder,
    Widget? customIconBuilderChild,
    BackgroundBuilder? customBackgroundBuilder,
    Widget? customBackgroundBuilderChild,
    BackgroundBuilder? customOuterBackgroundBuilder,
    Widget? customOuterBackgroundBuilderChild,
    Color? toggleColor,
    this.backgroundColor,
    this.height = 65.0,
    double borderWidth = 5.0,
    double? resultBorderWidth,
    SliderIconAnimation iconAnimation = SliderIconAnimation.none,
    bool childClip = true,
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
    this.toggleMarginCurve = Curves.easeInOut,
    this.toggleMarginDuration = const Duration(milliseconds: 350),
    this.anchorPosition = 0.5,
    this.allowedInterval = const SliderInterval(),
    this.toggleWidth,
    SliderChildAnimation childAnimation = SliderChildAnimation.clip,
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
                  context,
                  state,
                  startChild,
                  endChild,
                  childAnimation,
                )),
        foregroundBuilder =
            ((context, state, child) => _standardForegroundBuilder(
                  context,
                  state,
                  iconAnimation,
                  icon,
                  loadingIcon,
                  successIcon,
                  failureIcon,
                  toggleColor,
                  customIconBuilder,
                  customIconBuilderChild,
                  foregroundBorderRadius ??
                      _subtractPaddingFromBorderRadius(
                          backgroundBorderRadius, state.toggleMargin),
                  iconAlignment,
                  crossFadeDuration,
                )),
        outerBackgroundBuilder = customOuterBackgroundBuilder,
        outerBackgroundChild = customOuterBackgroundBuilderChild,
        toggleMargin = EdgeInsets.all(borderWidth),
        resultToggleMargin = resultBorderWidth == null
            ? null
            : EdgeInsets.all(resultBorderWidth),
        foregroundChild = null,
        actionThreshold = 1.0,
        action = null,
        _defaultControllerBuilder = _controllerBuilder;

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
          oldState?.slidingStatus != state.slidingStatus) {
        switch (thresholdType) {
          case ThresholdType.instant:
            if (state.slidingStatus != SlidingStatus.dragged) break;
            if (state.position <= startThreshold) {
              startAction?.call(controller);
            } else if (state.position >= endThreshold) {
              endAction?.call(controller);
            }
            break;
          case ThresholdType.release:
            if (oldState?.slidingStatus == state.slidingStatus ||
                state.slidingStatus != SlidingStatus.released) break;
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
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: backgroundBorderRadius,
        boxShadow: boxShadow,
      ),
    );
  }

  static Widget _standardBackgroundBuilder(
      BuildContext context,
      ActionSliderState state,
      Widget? child,
      SliderChildPosition childPosition,
      SliderChildAnimation childAnimation) {
    Alignment clipAlignment = state.direction == TextDirection.rtl
        ? Alignment.centerLeft
        : Alignment.centerRight;

    final innerSize = state.stretchedInnerSize;
    final toggleSize = state.standardToggleSize;

    final Clip clipBehavior = switch (childAnimation) {
      SliderChildAnimation.clip ||
      SliderChildAnimation.clipAndFade =>
        Clip.hardEdge,
      _ => Clip.none,
    };

    final bool fading = switch (childAnimation) {
      SliderChildAnimation.fade || SliderChildAnimation.clipAndFade => true,
      _ => false,
    };

    return Opacity(
      opacity: fading ? 1.0 - state.position : 1.0,
      child: ClipRect(
        clipBehavior: clipBehavior,
        child: OverflowBox(
          maxWidth: innerSize.width,
          maxHeight: innerSize.height,
          minWidth: innerSize.width,
          minHeight: innerSize.height,
          child: Align(
            alignment: clipAlignment,
            child: ClipRect(
              clipBehavior: clipBehavior,
              child: Align(
                alignment: clipAlignment,
                widthFactor: (toggleSize.width / (2 * innerSize.width)) +
                    (1 - state.position) *
                        ((innerSize.width - toggleSize.width) /
                            innerSize.width),
                child: switch (childPosition) {
                  SliderChildPosition.none => child,
                  SliderChildPosition.center => Center(child: child),
                  SliderChildPosition.centerWithPadding => Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: toggleSize.width),
                      child: Center(child: child),
                    ),
                  SliderChildPosition.centerFreeArea => Padding(
                      padding:
                          EdgeInsetsDirectional.only(start: toggleSize.width)
                              .resolve(state.direction),
                      child: Center(child: child),
                    ),
                  SliderChildPosition.centerFreeAreaWithPadding => Padding(
                      padding: EdgeInsetsDirectional.only(
                              start: toggleSize.width,
                              end: toggleSize.width / 2)
                          .resolve(state.direction),
                      child: Center(child: child),
                    ),
                  SliderChildPosition.balanced => Center(
                      child: FractionalTranslation(
                        translation: Offset(
                            (state.direction == TextDirection.rtl
                                    ? -1.0
                                    : 1.0) *
                                (toggleSize.width / 2) /
                                (innerSize.width - toggleSize.width),
                            0.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: innerSize.width - toggleSize.width),
                          child: child,
                        ),
                      ),
                    ),
                  SliderChildPosition.balancedWithPadding => Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: toggleSize.width / 2),
                      child: Center(
                        child: FractionalTranslation(
                          translation: Offset(
                              (state.direction == TextDirection.rtl
                                      ? -1.0
                                      : 1.0) *
                                  (toggleSize.width / 4) /
                                  (innerSize.width - toggleSize.width * 1.5),
                              0.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    innerSize.width - toggleSize.width * 1.5),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _standardDualBackgroundBuilder(
      BuildContext context,
      ActionSliderState state,
      Widget? startChild,
      Widget? endChild,
      SliderChildAnimation childAnimation) {
    Alignment startAlignment =
        AlignmentDirectional.centerStart.resolve(state.direction);
    Alignment endAlignment =
        AlignmentDirectional.centerEnd.resolve(state.direction);
    double innerWidth = state.standardSize.width -
        state.standardToggleSize.width -
        state.toggleMargin.horizontal;
    final startSize = Size(
        innerWidth * state.anchorPosition + state.standardToggleSize.width / 2,
        state.standardToggleSize.height);
    final endSize = Size(
        state.standardSize.width -
            state.toggleMargin.horizontal -
            startSize.width,
        state.standardToggleSize.height);
    final Clip clipBehavior = switch (childAnimation) {
      SliderChildAnimation.clip ||
      SliderChildAnimation.clipAndFade =>
        Clip.hardEdge,
      _ => Clip.none,
    };

    final bool fading = switch (childAnimation) {
      SliderChildAnimation.fade || SliderChildAnimation.clipAndFade => true,
      _ => false,
    };
    return Row(
      textDirection: state.direction,
      children: [
        Opacity(
          opacity: fading
              ? (state.position / state.anchorPosition).clamp(0.0, 1.0)
              : 1.0,
          child: SizedBox(
            width: (state.size.width -
                        state.standardToggleSize.width -
                        state.toggleMargin.horizontal) *
                    state.anchorPosition +
                state.standardToggleSize.width / 2,
            child: ClipRect(
              clipBehavior: clipBehavior,
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
                                          state.standardToggleSize.width /
                                          startSize.width))
                              .clamp(0.0, 1.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                                end: state.standardToggleSize.width / 2)
                            .resolve(state.direction),
                        child: Center(child: startChild),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Opacity(
            opacity: fading
                ? (1.0 -
                        (state.position - state.anchorPosition) /
                            (1.0 - state.anchorPosition))
                    .clamp(0.0, 1.0)
                : 1.0,
            child: ClipRect(
              clipBehavior: clipBehavior,
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
                                          state.standardToggleSize.width /
                                          endSize.width))
                              .clamp(0.0, 1.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                                start: state.standardToggleSize.width / 2)
                            .resolve(state.direction),
                        child: Center(child: endChild),
                      ),
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
    SliderIconAnimation iconAnimation,
    Widget icon,
    Widget loadingIcon,
    Widget successIcon,
    Widget failureIcon,
    Color? toggleColor,
    NullableForegroundBuilder? customIconBuilder,
    Widget? customIconBuilderChild,
    BorderRadiusGeometry foregroundBorderRadius,
    AlignmentGeometry iconAlignment,
    Duration crossFadeDuration,
  ) {
    final theme = Theme.of(context);
    double radius = state.size.height / 2;

    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: foregroundBorderRadius,
          color: toggleColor ?? theme.primaryColor),
      child: SliderCrossFade<SliderStatus>(
        duration: crossFadeDuration * (1 / 0.3),
        current: state.status,
        builder: (context, status) {
          final customIcon = customIconBuilder?.call(
            context,
            state,
            customIconBuilderChild,
          );
          icon = customIcon ?? icon;
          Widget child = switch (status) {
            SliderStatusLoading() => customIcon ?? loadingIcon,
            SliderStatusFailure() => customIcon ?? failureIcon,
            SliderStatusSuccess() => customIcon ?? successIcon,
            SliderStatusStandard() => switch (iconAnimation) {
                SliderIconAnimation.roll => Transform.rotate(
                    angle: ((state.size.width * state.position) -
                            state.size.width * state.anchorPosition) /
                        radius,
                    child: icon,
                  ),
                SliderIconAnimation.turn => Transform.rotate(
                    angle: state.position * -pi,
                    child: icon,
                  ),
                SliderIconAnimation.none => icon,
              },
            _ => customIcon ??
                (throw StateError('For using a custom SliderStatus you have to '
                    'return something in customIconBuilder!')),
          };
          return Align(alignment: iconAlignment, child: child);
        },
        size: (s1, s2) => s2.highlighted,
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
  late SliderState _state;

  /// The start position of the current running [_slideAnimation].
  late ValueListenable<double> _startPosition;

  late _SliderJump _lastJump;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _localController = widget._defaultControllerBuilder();
    }
    _controller.addListener(_onControllerStateChange);
    final initialStatus = widget.status ?? _controller.value.status;
    _state = SliderState(
      status: initialStatus,
      position: switch (initialStatus) {
        SliderStatusStandard() => widget.anchorPosition,
        SliderStatusResult() => initialStatus.side._position,
      },
      anchorPosition: widget.anchorPosition,
      slidingStatus: SlidingStatus.released,
    );
    _lastJump = _controller.value._jump;

    _slideAnimationController = AnimationController(
        vsync: this,
        duration: widget.slideAnimationDuration,
        reverseDuration: widget.reverseSlideAnimationDuration);
    _slideAnimation = CurvedAnimation(
        parent: _slideAnimationController,
        curve: widget.slideAnimationCurve,
        reverseCurve: widget.reverseSlideAnimationCurve);
    _slideAnimation.addListener(() {
      _changeState(_updatePosition(), null,
          setState: _state.slidingStatus != SlidingStatus.dragged);
    });
    _slideAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          _controller.value.status is SliderStatusStandard) {
        _dropSlider();
      }
    });

    _anchorController = AnimationController(
      vsync: this,
      duration: widget.anchorPositionDuration,
      value: widget.anchorPosition,
    );
    _startPosition = _anchorAnimation = (_anchorAnimationTween =
            Tween(begin: widget.anchorPosition, end: widget.anchorPosition))
        .animate(_anchorCurvedAnimation = CurvedAnimation(
      parent: _anchorController,
      curve: widget.anchorPositionCurve,
    ));
    _anchorController.addListener(() => _changeState(_updatePosition(), null));
  }

  SliderState _updatePosition({SlidingStatus? state}) {
    return _state.copyWith(
      anchorPosition: _anchorAnimation.value,
      position: _state.slidingStatus == SlidingStatus.dragged
          ? null
          : _startPosition.value +
              _slideAnimation.value *
                  (_state.releasePosition - _startPosition.value),
      slidingStatus: state,
    );
  }

  @override
  void dispose() {
    _anchorController.dispose();
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
      _controller.addListener(_onControllerStateChange);
      _lastJump = _controller.value._jump;
      _onControllerStateChange();
    }
    _slideAnimationController.duration = widget.slideAnimationDuration;
    _slideAnimationController.reverseDuration =
        widget.reverseSlideAnimationDuration;
    _slideAnimation.curve = widget.slideAnimationCurve;
    _slideAnimation.reverseCurve = widget.reverseSlideAnimationCurve;
    _anchorCurvedAnimation.curve = widget.anchorPositionCurve;
    _anchorController.duration = widget.anchorPositionDuration;

    if (oldWidget.anchorPosition != widget.anchorPosition) {
      _anchorAnimationTween.begin = _anchorAnimation.value;
      _anchorAnimationTween.end = widget.anchorPosition;
      _anchorController.forward(from: 0.0);
      _changeState(_updatePosition(), null, setState: false);
    }

    if (widget.status != null) {
      _updateStatus(widget.status!);
    } else {
      _updateStatus(_controller.value.status);
    }
  }

  void _onControllerStateChange() {
    final controllerValue = _controller.value;
    if (controllerValue._jump != _lastJump) {
      if (_state.slidingStatus == SlidingStatus.released) {
        _lastJump = controllerValue._jump;
        _animateSliderTo(
            _state.anchorPosition + controllerValue._jump.height, _state);
      }
    }
    if (widget.status == null) _updateStatus(_controller.value.status);
  }

  void _updateStatus(SliderStatus status) {
    if (_state.status != status) {
      if (status.expanded) {
        if (status is SliderStatusResult) {
          _animateSliderTo(
              status.side._position,
              _updatePosition(state: SlidingStatus.fixed)
                  .copyWith(status: status));
        } else {
          if (_lastActionSliderState?.relativeSize != 0.0) {
            _dropSlider(status: status);
          } else {
            _slideAnimationController.value = 0.0;
            _changeState(
                _state.copyWith(
                  anchorPosition: _state.anchorPosition,
                  position: _state.anchorPosition,
                  slidingStatus: SlidingStatus.released,
                  status: status,
                ),
                null);
            _anchorAnimationTween.begin = widget.anchorPosition;
            _anchorAnimationTween.end = widget.anchorPosition;
            _anchorController.stop();
          }
        }
      } else {
        _slideAnimationController.stop();
        _changeState(
            _state = _state.copyWith(
              releasePosition: _state.position,
              slidingStatus: SlidingStatus.compact,
              status: status,
            ),
            null);
      }
    }
  }

  void _animateSliderTo(double position, SliderState state,
      {SlidingStatus? slidingState}) {
    position = position.clamp(0.0, 1.0);
    _startPosition = _FixedValueListenable(state.position);
    if (_slideAnimationController.status == AnimationStatus.forward &&
        state.releasePosition == position) {
      _changeState(state.copyWith(slidingStatus: slidingState), null,
          setState: false);
      return;
    }
    _changeState(
        state.copyWith(releasePosition: position, slidingStatus: slidingState),
        null,
        setState: false);
    if (position == state.position &&
        state.slidingStatus == SlidingStatus.fixed) {
      _slideAnimationController.value = 1.0;
      return;
    }
    _slideAnimationController.forward(from: 0.0);
  }

  void _dropSlider({SliderStatus? status}) {
    _startPosition = _anchorAnimation;
    _changeState(
        _state.copyWith(
          releasePosition: _state.position,
          slidingStatus: SlidingStatus.released,
          status: status,
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
      slidingStatus: _state.slidingStatus,
      status: _state.status,
      anchorPosition: _state.anchorPosition,
      releasePosition: _state.releasePosition,
      dragStartPosition: _state.dragStartPosition,
      allowedInterval: widget.allowedInterval,
      toggleSize: oldActionSliderState.toggleSize,
      direction: oldActionSliderState.direction,
      toggleMargin: oldActionSliderState.toggleMargin,
      relativeSize: oldActionSliderState.relativeSize,
      standardToggleSize: oldActionSliderState.standardToggleSize,
      stretchedInnerSize: oldActionSliderState.stretchedInnerSize,
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

    if (!widget.allowedInterval.contains(widget.anchorPosition)) {
      throw ArgumentError(
          'The allowed interval of a ActionSlider has to contain the anchor position');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            min(widget.width ?? double.infinity, constraints.maxWidth);
        if (maxWidth == double.infinity) {
          throw StateError('The constraints of the ActionSlider '
              'are unbound and no width is set');
        }
        final toggleMargin = _controller.value.status is SliderStatusResult
            ? widget.resultToggleMargin ?? widget.toggleMargin
            : widget.toggleMargin;
        return TweenAnimationBuilder<EdgeInsetsGeometry>(
            curve: widget.toggleMarginCurve,
            duration: widget.toggleMarginDuration,
            tween:
                EdgeInsetsGeometryTween(begin: toggleMargin, end: toggleMargin),
            builder: (context, toggleMargin, child) {
              final standardCompactToggleWidth = widget.toggleWidth ??
                  widget.height - widget.toggleMargin.vertical;
              final compactToggleWidth =
                  widget.toggleWidth ?? widget.height - toggleMargin.vertical;
              final standardWidth = maxWidth -
                  compactToggleWidth -
                  widget.toggleMargin.horizontal;
              final relativeSize =
                  _controller.value.status.expanded ? 1.0 : 0.0;
              return TweenAnimationBuilder<double>(
                curve: widget.sizeAnimationCurve,
                duration: widget.sizeAnimationDuration,
                tween: Tween(begin: relativeSize, end: relativeSize),
                builder: (context, relativeSize, child) {
                  final width =
                      maxWidth - ((1.0 - relativeSize) * standardWidth);
                  final backgroundWidth =
                      width - compactToggleWidth - toggleMargin.horizontal;
                  double statePosToLocalPos(double statePos) =>
                      statePos.clamp(0.0, 1.0) * backgroundWidth;
                  final position = statePosToLocalPos(_state.position);

                  double togglePosition;
                  double toggleWidth;

                  switch (widget.sliderBehavior) {
                    case SliderBehavior.move:
                      togglePosition = position;
                      toggleWidth = compactToggleWidth;
                    case SliderBehavior.stretch:
                      double anchorPos =
                          statePosToLocalPos(_state.anchorPosition);
                      togglePosition = min(anchorPos, position);
                      toggleWidth =
                          ((position - anchorPos).abs()) + compactToggleWidth;
                  }

                  final toggleHeight = widget.height - toggleMargin.vertical;

                  final direction =
                      widget.direction ?? Directionality.of(context);

                  final resolvedToggleMargin =
                      toggleMargin.resolve(Directionality.of(context));

                  double localPositionToSliderPosition(double dx) {
                    final result = (((direction == TextDirection.rtl ? -1 : 1) *
                                (dx - standardCompactToggleWidth / 2)) /
                            backgroundWidth)
                        .clamp(0.0, 1.0);
                    return result;
                  }

                  final actionSliderState = ActionSliderState(
                    position: _state.position,
                    size: Size(width, widget.height),
                    standardSize: Size(maxWidth, widget.height),
                    slidingStatus: _state.slidingStatus,
                    status: _state.status,
                    anchorPosition: _state.anchorPosition,
                    releasePosition: _state.releasePosition,
                    dragStartPosition: _state.dragStartPosition,
                    allowedInterval: widget.allowedInterval,
                    toggleSize: Size(toggleWidth, toggleHeight),
                    direction: direction,
                    toggleMargin: toggleMargin,
                    relativeSize: relativeSize,
                    standardToggleSize:
                        Size(standardCompactToggleWidth, toggleHeight),
                    stretchedInnerSize: Size(
                        maxWidth - widget.toggleMargin.horizontal,
                        toggleHeight),
                  );

                  _changeState(_state, actionSliderState, setState: false);

                  return _ActionSliderStateProvider(
                    state: actionSliderState,
                    child: GestureDetector(
                      onTapUp: (details) {
                        if (_state.slidingStatus != SlidingStatus.released) {
                          return;
                        }
                        widget.onTap?.call(
                            _controller,
                            actionSliderState,
                            localPositionToSliderPosition(
                                details.localPosition.dx +
                                    resolvedToggleMargin.right));
                      },
                      child: SizedBox.fromSize(
                        size: actionSliderState.size,
                        child: Stack(
                          clipBehavior: Clip.none,
                          fit: StackFit.passthrough,
                          children: [
                            Builder(
                                builder: (context) =>
                                    (widget.outerBackgroundBuilder ??
                                        widget._standardOuterBackgroundBuilder)(
                                      context,
                                      actionSliderState,
                                      widget.outerBackgroundChild,
                                    )),
                            Padding(
                              padding: widget.toggleMargin,
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
                                ],
                              ),
                            ),
                            Padding(
                              padding: toggleMargin,
                              child: Stack(
                                children: [
                                  Positioned.directional(
                                    textDirection: direction,
                                    start: togglePosition,
                                    width: toggleWidth,
                                    height: toggleHeight,
                                    child: GestureDetector(
                                      onHorizontalDragStart: (details) {
                                        if (_state.slidingStatus !=
                                                SlidingStatus.released ||
                                            !_controller
                                                .value.status.expanded) {
                                          return;
                                        }
                                        final newPosition =
                                            widget.allowedInterval.clamp(
                                                localPositionToSliderPosition(
                                                    position +
                                                        details
                                                            .localPosition.dx));
                                        _changeState(
                                            _state.copyWith(
                                              position: newPosition,
                                              slidingStatus:
                                                  SlidingStatus.dragged,
                                              dragStartPosition:
                                                  _state.position,
                                            ),
                                            actionSliderState);
                                      },
                                      onHorizontalDragUpdate: (details) {
                                        if (_state.slidingStatus ==
                                            SlidingStatus.dragged) {
                                          double newPosition = widget
                                              .allowedInterval
                                              .clamp(localPositionToSliderPosition(
                                                  statePosToLocalPos(_state
                                                          .dragStartPosition) +
                                                      details
                                                          .localPosition.dx));
                                          _startPosition =
                                              _FixedValueListenable(
                                                  newPosition);
                                          _changeState(
                                              widget.actionThresholdType ==
                                                          ThresholdType
                                                              .release ||
                                                      newPosition <
                                                          widget
                                                              .actionThreshold ||
                                                      widget.action == null
                                                  ? _state.copyWith(
                                                      position: newPosition,
                                                      slidingStatus:
                                                          SlidingStatus.dragged,
                                                    )
                                                  : _state.copyWith(
                                                      position: newPosition,
                                                      slidingStatus:
                                                          SlidingStatus
                                                              .released,
                                                      releasePosition:
                                                          newPosition,
                                                    ),
                                              actionSliderState);
                                          if (_state.slidingStatus ==
                                              SlidingStatus.released) {
                                            _dropSlider();
                                            _onSlide();
                                          }
                                        }
                                      },
                                      onHorizontalDragEnd: (details) {
                                        if (_state.slidingStatus !=
                                            SlidingStatus.dragged) {
                                          return;
                                        }
                                        _dropSlider();
                                        if (widget.actionThresholdType ==
                                                ThresholdType.release &&
                                            _state.position >=
                                                widget.actionThreshold) {
                                          _onSlide();
                                        }
                                      },
                                      child: MouseRegion(
                                        cursor: _state.slidingStatus ==
                                                SlidingStatus.compact
                                            ? MouseCursor.defer
                                            : (_state.slidingStatus ==
                                                    SlidingStatus.released
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

class _ActionSliderStateProvider extends InheritedWidget {
  final ActionSliderState state;

  const _ActionSliderStateProvider({
    required super.child,
    required this.state,
  });

  static _ActionSliderStateProvider of(BuildContext context) {
    final _ActionSliderStateProvider? result = context
        .dependOnInheritedWidgetOfExactType<_ActionSliderStateProvider>();
    assert(result != null, 'No ActionSliderStateProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_ActionSliderStateProvider oldWidget) {
    return oldWidget.state != state;
  }
}
