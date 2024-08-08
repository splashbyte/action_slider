import 'package:flutter/material.dart';

class AnimatedCheckIcon extends StatelessWidget {
  final bool initialVisible;
  final bool visible;
  final Duration animationDuration;
  final Curve animationCurve;
  final Widget icon;

  const AnimatedCheckIcon({
    super.key,
    this.icon = const Icon(Icons.check),
    this.initialVisible = false,
    this.visible = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.slowMiddle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: initialVisible ? 1.0 : 0.0, end: visible ? 1.0 : 0.0),
      duration: animationDuration,
      curve: animationCurve,
      builder: (context, value, _) {
        return Center(
          child: ClipRect(
            clipper: _MyCustomClipper(relativeSize: value),
            child: icon,
          ),
        );
      },
    );
  }
}

class _MyCustomClipper extends CustomClipper<Rect> {
  final double relativeSize;

  _MyCustomClipper({required this.relativeSize});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0.0, 0.0, size.width * relativeSize, size.height);
  }

  @override
  bool shouldReclip(_MyCustomClipper oldClipper) {
    return oldClipper.relativeSize != relativeSize;
  }
}

class ScaleAppearingWidget extends StatefulWidget {
  final Widget child;
  final bool initialVisible;
  final bool visible;
  final Curve animationCurve;
  final Duration animationDuration;

  const ScaleAppearingWidget({
    super.key,
    required this.child,
    this.visible = true,
    this.initialVisible = false,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutBack,
  });

  @override
  State<ScaleAppearingWidget> createState() => _ScaleAppearingWidgetState();
}

class _ScaleAppearingWidgetState extends State<ScaleAppearingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = widget.initialVisible;
    _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        value: _visible ? 1.0 : 0.0);
    _animation =
        CurvedAnimation(parent: _controller, curve: widget.animationCurve);
    _updateVisible();
  }

  void _updateVisible() {
    if (_visible != widget.visible) {
      _visible = widget.visible;
      if (_visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void didUpdateWidget(covariant ScaleAppearingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateVisible();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Transform.scale(
            scale: _animation.value,
            child: widget.child,
          );
        });
  }
}
