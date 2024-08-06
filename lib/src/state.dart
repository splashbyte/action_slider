part of 'action_slider_widget.dart';

enum SlidingStatus { dragged, released, compact, fixed }

class SliderState {
  final double position,
      anchorPosition,
      releasePosition,
      startPosition,
      dragStartPosition;
  final SlidingStatus slidingStatus;
  final SliderStatus status;

  SliderState({
    required this.position,
    required this.slidingStatus,
    this.anchorPosition = 0.0,
    this.releasePosition = 0.0,
    this.startPosition = 0.0,
    this.dragStartPosition = 0.0,
    required this.status,
  });

  SliderState copyWith({
    double? position,
    SlidingStatus? slidingStatus,
    double? anchorPosition,
    double? releasePosition,
    double? startPosition,
    double? dragStartPosition,
    SliderStatus? status,
  }) =>
      SliderState(
        position: position ?? this.position,
        slidingStatus: slidingStatus ?? this.slidingStatus,
        anchorPosition: anchorPosition ?? this.anchorPosition,
        releasePosition: releasePosition ?? this.releasePosition,
        startPosition: startPosition ?? this.startPosition,
        dragStartPosition: dragStartPosition ?? this.dragStartPosition,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderState &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          anchorPosition == other.anchorPosition &&
          releasePosition == other.releasePosition &&
          startPosition == other.startPosition &&
          dragStartPosition == other.dragStartPosition &&
          slidingStatus == other.slidingStatus &&
          status == other.status;

  @override
  int get hashCode =>
      position.hashCode ^
      anchorPosition.hashCode ^
      releasePosition.hashCode ^
      startPosition.hashCode ^
      dragStartPosition.hashCode ^
      slidingStatus.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'SliderState{position: $position, anchorPosition: $anchorPosition, releasePosition: $releasePosition, startPosition: $startPosition, dragStartPosition: $dragStartPosition, state: $slidingStatus, status: $status}';
  }
}

class BaseActionSliderState {
  /// The current position of the toggle.
  final double position;

  /// The current [SlidingStatus] of the [ActionSlider].
  final SlidingStatus slidingStatus;

  /// The current [SliderStatus] of the [ActionSlider].
  /// It can be set manually with the ActionSliderController.
  final SliderStatus status;

  /// The anchor position of the toggle.
  final double anchorPosition;

  /// The position at which the toggle was released.
  /// Is only relevant if the [slidingStatus] is [SlidingStatus.released].
  /// The default value is 0.0.
  final double releasePosition;

  /// The position at which the toggle was dragged.
  /// Is only relevant if the [slidingStatus] is [SlidingStatus.dragged].
  final double dragStartPosition;

  /// The interval in which the toggle can be moved by the user.
  final SliderInterval allowedInterval;

  /// The direction of the slider.
  final TextDirection direction;

  /// The margin of the toggle.
  final EdgeInsetsGeometry toggleMargin;

  const BaseActionSliderState({
    required this.position,
    required this.slidingStatus,
    required this.status,
    required this.anchorPosition,
    required this.releasePosition,
    required this.dragStartPosition,
    required this.allowedInterval,
    required this.direction,
    required this.toggleMargin,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseActionSliderState &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          slidingStatus == other.slidingStatus &&
          status == other.status &&
          anchorPosition == other.anchorPosition &&
          releasePosition == other.releasePosition &&
          dragStartPosition == other.dragStartPosition &&
          allowedInterval == other.allowedInterval &&
          direction == other.direction &&
          toggleMargin == other.toggleMargin;

  @override
  int get hashCode =>
      position.hashCode ^
      slidingStatus.hashCode ^
      status.hashCode ^
      anchorPosition.hashCode ^
      releasePosition.hashCode ^
      dragStartPosition.hashCode ^
      allowedInterval.hashCode ^
      direction.hashCode ^
      toggleMargin.hashCode;
}

class ActionSliderState extends BaseActionSliderState {
  /// The size of the [ActionSlider].
  final Size size;

  /// The size of the [ActionSlider] which it has in expanded form.
  final Size standardSize;

  /// The current size of the toggle.
  final Size toggleSize;

  /// The compact/unstretched size of the toggle.
  final Size standardToggleSize;

  /// The stretched size of the background of the slider.
  final Size stretchedInnerSize;

  /// [1.0] indicates that the slider is expanded and [0.0] indicates that the slider is compact.
  final double relativeSize;

  const ActionSliderState({
    required super.position,
    required super.slidingStatus,
    required super.status,
    required super.anchorPosition,
    required super.releasePosition,
    required super.dragStartPosition,
    required super.allowedInterval,
    required super.direction,
    required super.toggleMargin,
    required this.size,
    required this.standardSize,
    required this.toggleSize,
    required this.relativeSize,
    required this.standardToggleSize,
    required this.stretchedInnerSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ActionSliderState &&
          runtimeType == other.runtimeType &&
          size == other.size &&
          standardSize == other.standardSize &&
          toggleSize == other.toggleSize &&
          standardToggleSize == other.standardToggleSize &&
          stretchedInnerSize == other.stretchedInnerSize &&
          relativeSize == other.relativeSize;

  @override
  int get hashCode =>
      super.hashCode ^
      size.hashCode ^
      standardSize.hashCode ^
      toggleSize.hashCode ^
      standardToggleSize.hashCode ^
      stretchedInnerSize.hashCode ^
      relativeSize.hashCode;

  /// Alternative way for accessing the [ActionSliderState] in the different
  /// builders of [ActionSlider] via [BuildContext].
  static ActionSliderState of(BuildContext context) =>
      _ActionSliderStateProvider.of(context).state;
}
