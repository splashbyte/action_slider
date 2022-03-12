class SliderMode {
  final dynamic key;
  final bool expanded;
  final bool custom;
  final double jumpPosition;

  const SliderMode({required this.key, this.expanded = false})
      : jumpPosition = 0.0,
        custom = true;

  const SliderMode._internal({
    required this.key,
    this.expanded = false,
    this.jumpPosition = 0.0,
  }) : custom = false;

  static const loading = SliderMode._internal(key: _SliderModeKey('loading'));
  static const success = SliderMode._internal(key: _SliderModeKey('success'));
  static const failure = SliderMode._internal(key: _SliderModeKey('failure'));
  static const standard = SliderMode._internal(
    key: _SliderModeKey('standard'),
    expanded: true,
  );

  bool get isJump => key == 'jump' && !custom;

  const SliderMode.jump(double pos)
      : this._internal(
          key: 'jump',
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
