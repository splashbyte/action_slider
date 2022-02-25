import 'package:flutter/material.dart';

class CrossFade<T> extends StatefulWidget {
  final T current;
  final Widget Function(BuildContext, T)? builder;
  final Duration duration;
  final bool Function(T, T) equals;
  final bool Function(T, T)? size;

  const CrossFade(
      {Key? key,
      this.duration = const Duration(milliseconds: 750),
      required this.current,
      this.builder,
      this.equals = _standardEquals,
      this.size})
      : super(key: key);

  static bool _standardEquals(dynamic t1, dynamic t2) => t1 == t2;

  @override
  _CrossFadeState<T> createState() => _CrossFadeState<T>();
}

class _CrossFadeState<T> extends State<CrossFade<T>>
    with SingleTickerProviderStateMixin {
  late List<T> todo;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    todo = [widget.current];
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (todo.length <= 1) return;
          todo.removeAt(0);
          if (todo.length > 1) {
            _controller.forward(from: 0.0);
          } else {
            _controller.value = 0.0;
          }
        }
      });

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _sizeAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(1.0),
          weight: 25.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.3, end: 1.0)
              .chain(CurveTween(curve: Curves.ease.flipped)),
          weight: 50.0,
        ),
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.equals(widget.current, todo.last)) {
      if (todo.length < 3) {
        todo.add(widget.current);
      } else {
        todo[todo.length - 1] = widget.current;
      }
      if (!_controller.isAnimating) _controller.forward(from: 0.0);
    }

    return Transform.scale(
      scale: todo.length > 1 && (widget.size?.call(todo[0], todo[1]) ?? false)
          ? _sizeAnimation.value
          : 1.0,
      child: Stack(
        children: [
          Opacity(
              key: _LocalKey(todo[0]),
              opacity: 1 - _opacityAnimation.value,
              child: widget.builder!(context, todo[0])),
          if (todo.length > 1)
            Opacity(
                key: _LocalKey(todo[1]),
                opacity: _opacityAnimation.value,
                child: widget.builder!(context, todo[1]))
        ],
      ),
    );
  }
}

class _LocalKey<T> extends ValueKey<T> {
  const _LocalKey(T value) : super(value);
}
