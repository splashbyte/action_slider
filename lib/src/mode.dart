class SliderMode {
  ///A unique key for this mode, which is used for the equals method.
  final dynamic key;

  ///Specifies the slider to be expanded in this mode. Otherwise it is compact.
  final bool expanded;

  //TODO: remove 'custom' because of redundancy (use getter instead)
  ///Indicates whether this mode is not natively provided by this package.
  final bool custom;

  ///Indicates whether this mode is a result like [success] and [failure].
  ///If so, by default the change is highlighted more clearly in the slider.
  final bool result;

  ///Specifies how far the toggle should jump between 0 and 1.
  ///To adjust this value, please use [SliderMode.jump].
  final double jumpPosition;

  const SliderMode({
    required this.key,
    this.expanded = false,
    this.result = false,
  })  : jumpPosition = 0.0,
        custom = true;

  const SliderMode._internal({
    required this.key,
    this.expanded = false,
    this.result = false,
    this.jumpPosition = 0.0,
  }) : custom = false;

  static const loading =
      SliderMode._internal(key: _SliderModeKey('loading'), result: false);
  static const success =
      SliderMode._internal(key: _SliderModeKey('success'), result: true);
  static const failure =
      SliderMode._internal(key: _SliderModeKey('failure'), result: true);
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
          jumpPosition: pos,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderMode &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          custom == other.custom &&
          jumpPosition == other.jumpPosition;

  @override
  int get hashCode => key.hashCode ^ custom.hashCode ^ jumpPosition.hashCode;
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
}
