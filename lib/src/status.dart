part of 'action_slider_widget.dart';

final class _SliderJump {
  /// Specifies how far the toggle should jump between [-1.0] and [1.0].
  final double height;

  _SliderJump({required this.height});
}

final class ActionSliderControllerState {
  final SliderStatus status;
  final _SliderJump _jump;

  ActionSliderControllerState._({
    required this.status,
    _SliderJump? jump,
  }) : _jump = jump ?? _SliderJump(height: 0.0);

  ActionSliderControllerState _copyWith({
    SliderStatus? status,
    _SliderJump? jump,
  }) =>
      ActionSliderControllerState._(
        status: status ?? this.status,
        jump: jump ?? _jump,
      );
}

class SliderInterval {
  /// The minimum allowed value.
  final double start;

  /// The maximum allowed value.
  final double end;

  /// Returns [value] clamped to be in this [SliderInterval].
  double clamp(double value) => value.clamp(start, end);

  /// Indicates whether [value] is contained in this [SliderInterval].
  bool contains(double value) => value >= start && value <= end;

  /// Creates a new [SliderInterval].
  const SliderInterval({this.start = 0.0, this.end = 1.0});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderInterval &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

@Deprecated('Use SliderStatus instead')
typedef SliderMode = SliderStatus;

/// Standard status in which the user can drag and move the toggle.
class StandardSliderStatus extends SliderStatus {
  const StandardSliderStatus({super.highlighted = false});

  @override
  bool get expanded => true;

  @override
  bool get toggleVisible => true;
}

/// Status like [success], [failure] and [loading].
/// In this case the slider indicator is fixed at [side] and not draggable.
class ResultSliderStatus extends SliderStatus {
  @override
  final bool expanded;

  @override
  final bool toggleVisible;

  /// Indicates on which [SliderSide] the toggle should be located.
  ///
  /// This parameter is ignored when [expanded] is [false].
  final SliderSide side;

  const ResultSliderStatus({
    super.highlighted = true,
    this.expanded = false,
    this.side = SliderSide.end,
    this.toggleVisible = true,
  });
}

/// [SliderStatus] for success.
class SuccessSliderStatus extends ResultSliderStatus {
  const SuccessSliderStatus({
    super.highlighted,
    super.expanded,
    super.side,
  });
}

/// [SliderStatus] for failure.
class FailureSliderStatus extends ResultSliderStatus {
  const FailureSliderStatus({
    super.highlighted,
    super.expanded,
    super.side,
  });
}

/// [SliderStatus] for loading.
class LoadingSliderStatus extends ResultSliderStatus {
  const LoadingSliderStatus({
    super.highlighted = false,
    super.expanded,
    super.side,
  });
}

/// A status of an [ActionSlider].
///
/// You can create a predefined [SliderStatus] via [SliderStatus.loading],
/// [SliderStatus.success], [SliderStatus.failure] and [SliderStatus.standard].
///
/// If you want to implement your own [SliderStatus], you can instantiate
/// [StandardSliderStatus] or [ResultSliderStatus].
///
/// Alternatively you can also create your own subclasses of them.
sealed class SliderStatus {
  /// Indicates whether the slider is expanded in this status. Otherwise it is compact.
  bool get expanded;

  // TODO
  /// Indicates whether the toggle is visible in this status.
  bool get toggleVisible;

  /// Indicates whether this status gets highlighted more clearly in the slider.
  final bool highlighted;

  const SliderStatus({this.highlighted = false});

  /// [SliderStatus] for loading.
  const factory SliderStatus.loading(
      {bool expanded, bool highlighted, SliderSide side}) = LoadingSliderStatus;

  /// [SliderStatus] for success.
  const factory SliderStatus.success(
      {bool expanded, bool highlighted, SliderSide side}) = SuccessSliderStatus;

  /// [SliderStatus] for failure.
  const factory SliderStatus.failure(
      {bool expanded, bool highlighted, SliderSide side}) = FailureSliderStatus;

  /// Standard status in which the user can drag and move the toggle.
  const factory SliderStatus.standard({bool highlighted}) =
      StandardSliderStatus;
}

enum SliderSide {
  /// The start of the [ActionSlider].
  start(0.0),

  /// The end of the [ActionSlider].
  end(1.0);

  final double _position;

  const SliderSide(this._position);
}
