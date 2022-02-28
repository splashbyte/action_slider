import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';

enum SlidingState { dragged, released, loading }

class SliderState {
  final double position, releasePosition;
  final SlidingState state;

  SliderState(
      {required this.position,
      required this.state,
      this.releasePosition = 1.0});

  SliderState copyWith(
          {double? position, SlidingState? state, double? releasePosition}) =>
      SliderState(
        position: position ?? this.position,
        state: state ?? this.state,
        releasePosition: releasePosition ?? this.releasePosition,
      );
}

class ActionSliderState {
  /// The current position of the toggle.
  final double position;

  /// The size of the [ActionSlider].
  final Size size;

  /// The size of the [ActionSlider] which it has in expanded form.
  final Size standardSize;

  /// The current [SlidingState] of the [ActionSlider].
  final SlidingState slidingState;

  /// The current [SliderMode] of the [ActionSlider].
  /// It can be set manually with the ActionSliderController.
  final SliderMode sliderMode;

  /// The position at which the toggle was released.
  /// Is only relevant if the [slidingState] is [SlidingState.released].
  /// Otherwise it is always 1.0.
  final double releasePosition;

  /// The current size of the toggle.
  final Size toggleSize;

  ActionSliderState({
    required this.position,
    required this.size,
    required this.slidingState,
    required this.sliderMode,
    required this.releasePosition,
    required this.toggleSize,
    required this.standardSize,
  });
}
