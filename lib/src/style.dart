part of 'action_slider_widget.dart';

class SliderStyle extends ThemeExtension<SliderStyle> {
  /// The [Color] of the [Container] in the background.
  final Color? backgroundColor;

  /// The [BorderRadiusGeometry] of the [Container] in the background.
  final BorderRadiusGeometry? borderRadius;

  /// The [Gradient] of the [Container] in the background.
  ///
  /// Overwrites [backgroundColor] if not [null].
  final Gradient? backgroundGradient;

  /// The [Color] of the toggle.
  final Color? toggleColor;

  /// The [BorderRadiusGeometry] of the toggle.
  final BorderRadiusGeometry? toggleBorderRadius;

  /// The [Gradient] of the [Container] in the background.
  ///
  /// Overwrites [toggleColor] if not [null].
  final Gradient? toggleGradient;

  /// The shadow of the toggle.
  ///
  /// Overwrites [toggleElevation] if not [null].
  final List<BoxShadow>? toggleBoxShadow;

  /// The shadow of the [Container] in the background.
  ///
  /// Overwrites [elevation] if not [null].
  final List<BoxShadow>? boxShadow;

  static SliderStyle? maybeOf(BuildContext context) =>
      Theme.of(context).extension<SliderStyle>();

  static SliderStyle of(BuildContext context) => maybeOf(context)!;

  const SliderStyle({
    this.backgroundColor,
    this.borderRadius,
    this.backgroundGradient,
    this.toggleColor,
    this.toggleBorderRadius,
    this.toggleGradient,
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black26,
        spreadRadius: 1,
        blurRadius: 2,
        offset: Offset(0, 2),
      ),
    ],
    this.toggleBoxShadow,
  });

  const SliderStyle._({
    required this.backgroundColor,
    required this.borderRadius,
    required this.backgroundGradient,
    required this.toggleColor,
    required this.toggleBorderRadius,
    required this.toggleGradient,
    required this.boxShadow,
    required this.toggleBoxShadow,
  });

  SliderStyle merge(SliderStyle other) => SliderStyle._(
        backgroundColor: other.backgroundColor ?? backgroundColor,
        borderRadius: other.borderRadius ?? borderRadius,
        backgroundGradient: other.backgroundGradient ?? backgroundGradient,
        toggleColor: other.toggleColor ?? toggleColor,
        toggleBorderRadius: other.toggleBorderRadius ?? toggleBorderRadius,
        toggleGradient: other.toggleGradient ?? toggleGradient,
        boxShadow: other.boxShadow ?? boxShadow,
        toggleBoxShadow: other.toggleBoxShadow ?? toggleBoxShadow,
      );

  @override
  ThemeExtension<SliderStyle> copyWith({
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    Gradient? backgroundGradient,
    Color? toggleColor,
    BorderRadiusGeometry? toggleBorderRadius,
    Gradient? toggleGradient,
    List<BoxShadow>? toggleBoxShadow,
    List<BoxShadow>? boxShadow,
  }) =>
      SliderStyle._(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        borderRadius: borderRadius ?? this.borderRadius,
        backgroundGradient: backgroundGradient ?? this.backgroundGradient,
        toggleColor: toggleColor ?? this.toggleColor,
        toggleBorderRadius: toggleBorderRadius ?? this.toggleBorderRadius,
        toggleGradient: toggleGradient ?? this.toggleGradient,
        boxShadow: boxShadow ?? this.boxShadow,
        toggleBoxShadow: toggleBoxShadow ?? this.toggleBoxShadow,
      );

  @override
  ThemeExtension<SliderStyle> lerp(SliderStyle other, double t) =>
      SliderStyle._(
        backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
        borderRadius:
            BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
        backgroundGradient:
            Gradient.lerp(backgroundGradient, other.backgroundGradient, t),
        toggleColor: Color.lerp(toggleColor, other.toggleColor, t),
        toggleBorderRadius: BorderRadiusGeometry.lerp(
            toggleBorderRadius, other.toggleBorderRadius, t),
        toggleGradient: Gradient.lerp(toggleGradient, other.toggleGradient, t),
        boxShadow: BoxShadow.lerpList(boxShadow, other.boxShadow, t),
        toggleBoxShadow:
            BoxShadow.lerpList(toggleBoxShadow, other.toggleBoxShadow, t),
      );
}
