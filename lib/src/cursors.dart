// coverage:ignore-file
part of 'action_slider_widget.dart';

class SliderCursors {
  /// [MouseCursor] to show when not hovering an indicator or a tappable icon.
  final MouseCursor defaultCursor;

  /// [MouseCursor] to show when grabbing the indicators.
  final MouseCursor draggingCursor;

  /// [MouseCursor] to show when hovering the indicators.
  final MouseCursor dragCursor;

  const SliderCursors({
    this.defaultCursor = MouseCursor.defer,
    this.draggingCursor = SystemMouseCursors.grabbing,
    this.dragCursor = SystemMouseCursors.grab,
  });

  const SliderCursors.all(MouseCursor cursor)
      : defaultCursor = cursor,
        draggingCursor = cursor,
        dragCursor = cursor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderCursors &&
          runtimeType == other.runtimeType &&
          defaultCursor == other.defaultCursor &&
          draggingCursor == other.draggingCursor &&
          dragCursor == other.dragCursor;

  @override
  int get hashCode =>
      defaultCursor.hashCode ^
      draggingCursor.hashCode ^
      dragCursor.hashCode;
}
