class ActionSliderControllerState {
  final SliderMode mode;
  final SliderDirection direction;

  ActionSliderControllerState({
    required this.mode,
    required this.direction,
  });

  ActionSliderControllerState copyWith({
    SliderMode? mode,
    SliderDirection? direction,
  }) =>
      ActionSliderControllerState(
        mode: mode ?? this.mode,
        direction: direction ?? this.direction,
      );
}

class SliderInterval {
  /// The minimum allowed value.
  final double start;

  /// The maximum allowed value.
  final double end;

  double clamp(double d) => d.clamp(start, end);

  bool contains(double d) => d >= start && d <= end;

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

class SliderMode {
  /// A unique key for this mode, which is used for the [==] method.
  final Object? key;

  /// Specifies the slider to be expanded in this mode. Otherwise it is compact.
  final bool expanded;

  /// Indicates whether this mode is not natively provided by this package.
  bool get custom => key is! _SliderModeKey;

  /// Indicates whether this mode is a result like [success], [failure] and [loading].
  /// In this case the slider indicator is fixed at the end and not draggable.
  final bool result;

  /// Indicates whether this mode gets highlighted more clearly in the slider.
  final bool highlighted;

  ///Specifies how far the toggle should jump between [-1] and [1].
  ///To adjust this value, please use [SliderMode.jump].
  final double jumpHeight;

  const SliderMode({
    required this.key,
    this.expanded = false,
    this.result = false,
    this.highlighted = false,
  }) : jumpHeight = 0.0;

  const SliderMode._internal({
    required this.key,
    this.expanded = false,
    this.result = false,
    this.highlighted = false,
    this.jumpHeight = 0.0,
  });

  static const loading = SliderMode._internal(
    key: _SliderModeKey('loading'),
    result: true,
    highlighted: false,
  );
  static const loadingExpanded = SliderMode._internal(
      key: _SliderModeKey('loadingExpanded'),
      result: true,
      expanded: true,
      highlighted: false);
  static const success = SliderMode._internal(
    key: _SliderModeKey('success'),
    result: true,
    highlighted: true,
  );
  static const successExpanded = SliderMode._internal(
      key: _SliderModeKey('successExpanded'),
      result: true,
      expanded: true,
      highlighted: true);
  static const failure = SliderMode._internal(
    key: _SliderModeKey('failure'),
    result: true,
    highlighted: true,
  );
  static const failureExpanded = SliderMode._internal(
    key: _SliderModeKey('failureExpanded'),
    result: true,
    expanded: true,
    highlighted: true,
  );
  static const standard = SliderMode._internal(
    key: _SliderModeKey('standard'),
    expanded: true,
    result: false,
  );

  ///Indicates whether this mode is a [SliderMode.jump].
  bool get isJump => key == const _SliderModeKey('jump');

  const SliderMode.jump(double pos)
      : this._internal(
          key: const _SliderModeKey('jump'),
          expanded: true,
          jumpHeight: pos,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderMode &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          custom == other.custom &&
          jumpHeight == other.jumpHeight;

  @override
  int get hashCode => key.hashCode ^ custom.hashCode ^ jumpHeight.hashCode;
}

class _SliderModeKey {
  final String key;

  const _SliderModeKey(this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SliderModeKey &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return '_SliderModeKey{key: $key}';
  }
}

enum SliderDirection { start, end }
