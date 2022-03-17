import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';

enum SlidingState { dragged, released, compact }

class SliderState {
  final double position, releasePosition;
  final SlidingState state;

  SliderState(
      {required this.position,
      required this.state,
      this.releasePosition = 0.0});

  SliderState copyWith(
          {double? position, SlidingState? state, double? releasePosition}) =>
      SliderState(
        position: position ?? this.position,
        state: state ?? this.state,
        releasePosition: releasePosition ?? this.releasePosition,
      );
}

class BaseActionSliderState {
  /// The current position of the toggle.
  final double position;

  /// The current [SlidingState] of the [ActionSlider].
  final SlidingState slidingState;

  /// The current [SliderMode] of the [ActionSlider].
  /// It can be set manually with the ActionSliderController.
  final SliderMode sliderMode;

  /// The position at which the toggle was released.
  /// Is only relevant if the [slidingState] is [SlidingState.released].
  /// The default value is 0.0.
  final double releasePosition;

  BaseActionSliderState({
    required this.position,
    required this.slidingState,
    required this.sliderMode,
    required this.releasePosition,
  });
}

class ActionSliderState extends BaseActionSliderState {
  /// The size of the [ActionSlider].
  final Size size;

  /// The size of the [ActionSlider] which it has in expanded form.
  final Size standardSize;

  /// The current size of the toggle.
  final Size toggleSize;

  ActionSliderState({
    required double position,
    required SlidingState slidingState,
    required SliderMode sliderMode,
    required double releasePosition,
    required this.size,
    required this.standardSize,
    required this.toggleSize,
  }) : super(
          position: position,
          slidingState: slidingState,
          sliderMode: sliderMode,
          releasePosition: releasePosition,
        );
}
