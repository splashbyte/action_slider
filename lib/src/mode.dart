class SliderMode {
  final dynamic key;
  final bool expanded;

  const SliderMode({required this.key, this.expanded = false});

  static const loading = SliderMode(key: _SliderModeKey('loading'));
  static const success = SliderMode(key: _SliderModeKey('success'));
  static const failure = SliderMode(key: _SliderModeKey('failure'));
  static const standard = SliderMode(
    key: _SliderModeKey('standard'),
    expanded: true,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderMode &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
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
