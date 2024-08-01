import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';

enum SlidingState { dragged, released, compact, fixed }

class SliderState {
  final double position,
      anchorPosition,
      releasePosition,
      startPosition,
      dragStartPosition;
  final SlidingState state;
  final SliderInterval allowedInterval;

  SliderState({
    required this.position,
    required this.state,
    this.anchorPosition = 0.0,
    this.releasePosition = 0.0,
    this.startPosition = 0.0,
    this.dragStartPosition = 0.0,
    this.allowedInterval = const SliderInterval(),
  });

  SliderState copyWith({
    double? position,
    SlidingState? state,
    double? anchorPosition,
    double? releasePosition,
    double? startPosition,
    double? dragStartPosition,
    SliderInterval? allowedInterval,
  }) =>
      SliderState(
        position: position ?? this.position,
        state: state ?? this.state,
        anchorPosition: anchorPosition ?? this.anchorPosition,
        releasePosition: releasePosition ?? this.releasePosition,
        startPosition: startPosition ?? this.startPosition,
        dragStartPosition: dragStartPosition ?? this.dragStartPosition,
        allowedInterval: allowedInterval ?? this.allowedInterval,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderState &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          anchorPosition == other.anchorPosition &&
          releasePosition == other.releasePosition &&
          state == other.state;

  @override
  int get hashCode =>
      position.hashCode ^ releasePosition.hashCode ^ state.hashCode;

  @override
  String toString() {
    return 'SliderState{position: $position, '
        'anchorPosition: $anchorPosition, '
        'releasePosition: $releasePosition, '
        'dragStartPosition: $dragStartPosition, '
        'state: $state}';
  }
}

class BaseActionSliderState {
  /// The current position of the toggle.
  final double position;

  /// The current [SlidingState] of the [ActionSlider].
  final SlidingState slidingState;

  /// The current [SliderMode] of the [ActionSlider].
  /// It can be set manually with the ActionSliderController.
  final SliderMode sliderMode;

  /// The anchor position of the toggle.
  final double anchorPosition;

  /// The position at which the toggle was released.
  /// Is only relevant if the [slidingState] is [SlidingState.released].
  /// The default value is 0.0.
  final double releasePosition;

  /// The position at which the toggle was dragged.
  /// Is only relevant if the [slidingState] is [SlidingState.dragged].
  final double dragStartPosition;

  /// The interval in which the toggle can be moved by the user.
  final SliderInterval allowedInterval;

  /// The direction of the slider.
  final TextDirection direction;

  /// The margin of the toggle.
  final EdgeInsetsGeometry toggleMargin;

  const BaseActionSliderState({
    required this.position,
    required this.slidingState,
    required this.sliderMode,
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
          slidingState == other.slidingState &&
          sliderMode == other.sliderMode &&
          releasePosition == other.releasePosition &&
          direction == other.direction;

  @override
  int get hashCode =>
      position.hashCode ^
      slidingState.hashCode ^
      sliderMode.hashCode ^
      releasePosition.hashCode ^
      direction.hashCode;
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
    required super.slidingState,
    required super.sliderMode,
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
}
