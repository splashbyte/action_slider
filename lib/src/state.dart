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
