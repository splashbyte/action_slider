class SliderMode {
  final dynamic key;
  final bool expanded;
  final bool custom;

  const SliderMode({required this.key, this.expanded = false}) : custom = true;

  const SliderMode._internal({required this.key, this.expanded = false})
      : custom = false;

  static const loading = SliderMode._internal(key: _SliderModeKey('loading'));
  static const success = SliderMode._internal(key: _SliderModeKey('success'));
  static const failure = SliderMode._internal(key: _SliderModeKey('failure'));
  static const standard = SliderMode._internal(
    key: _SliderModeKey('standard'),
    expanded: true,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderMode &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          custom == other.custom;

  @override
  int get hashCode => key.hashCode ^ custom.hashCode;
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
