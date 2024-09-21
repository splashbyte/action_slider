import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:cross_fade/cross_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Action Slider Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ExamplePage(title: 'Action Slider Example'),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key, required this.title});

  final String title;

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _controller = ActionSliderController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white),
              child: ActionSlider.dual(
                anchorPosition: 0.7,
                style: SliderStyle(
                  borderRadius: BorderRadius.circular(10.0),
                  backgroundColor: Colors.black,
                ),
                width: 300.0,
                startChild: const Text('Start'),
                endChild: const Text('End'),
                icon: const RotatedBox(
                    quarterTurns: 1,
                    child: Icon(Icons.unfold_more_rounded, size: 28.0)),
                startAction: (controller) async {
                  controller.loading(); //starts loading animation
                  await Future.delayed(const Duration(seconds: 3));
                  controller.success(); //starts success animation
                  await Future.delayed(const Duration(seconds: 1));
                  controller.reset(); //resets the slider
                },
                endAction: (controller) async {
                  controller.loading(expanded: true); //starts loading animation
                  await Future.delayed(const Duration(seconds: 3));
                  controller.success(expanded: true); //starts success animation
                  await Future.delayed(const Duration(seconds: 1));
                  controller.reset(); //resets the slider
                },
              ),
            ),
            const SizedBox(height: 24.0),
            ActionSlider.standard(
              resultBorderWidth: 0.0,
              sliderBehavior: SliderBehavior.stretch,
              width: 300.0,
              style: const SliderStyle(
                backgroundColor: Colors.white,
                toggleColor: Colors.lightGreenAccent,
              ),
              action: (controller) async {
                controller.loading(expanded: true); //starts loading animation
                await Future.delayed(const Duration(seconds: 3));
                controller.success(expanded: true); //starts success animation
                await Future.delayed(const Duration(seconds: 1));
                controller.reset();
              },
              child: const Text('Slide to confirm'),
            ),
            const SizedBox(height: 24.0),
            ActionSlider.standard(
              width: 300.0,
              action: (controller) async {
                controller.loading(); //starts loading animation
                await Future.delayed(const Duration(seconds: 3));
                controller.success(); //starts success animation
                await Future.delayed(const Duration(seconds: 1));
                controller.reset(); //resets the slider
              },
              direction: TextDirection.rtl,
              child: const Text('Slide to confirm'),
            ),
            const SizedBox(height: 24.0),
            ActionSlider.standard(
              iconAnimation: SliderIconAnimation.roll,
              width: 300.0,
              style: const SliderStyle(
                backgroundColor: Colors.black,
                toggleColor: Colors.purpleAccent,
              ),
              reverseSlideAnimationCurve: Curves.easeInOut,
              reverseSlideAnimationDuration: const Duration(milliseconds: 500),
              icon: const Icon(Icons.add),
              action: (controller) async {
                controller.loading(); //starts loading animation
                await Future.delayed(const Duration(seconds: 3));
                controller.success(); //starts success animation
                await Future.delayed(const Duration(seconds: 1));
                controller.reset(); //resets the slider
              },
              child: const Text('Rolling slider',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24.0),
            ActionSlider.standard(
              sliderBehavior: SliderBehavior.stretch,
              iconAnimation: SliderIconAnimation.roll,
              width: 300.0,
              style: const SliderStyle(
                backgroundColor: Colors.white,
                toggleColor: Colors.amber,
              ),
              iconAlignment: Alignment.centerRight,
              loadingIcon: SizedBox(
                  width: 55,
                  child: Center(
                      child: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0, color: theme.iconTheme.color),
                  ))),
              successIcon: const SizedBox(
                  width: 55, child: Center(child: Icon(Icons.check_rounded))),
              icon: const SizedBox(
                  width: 55, child: Center(child: Icon(Icons.refresh_rounded))),
              action: (controller) async {
                controller.loading(); //starts loading animation
                await Future.delayed(const Duration(seconds: 3));
                controller.success(); //starts success animation
                await Future.delayed(const Duration(seconds: 1));
                controller.reset(); //resets the slider
              },
              child: const Text('Swipe right'),
            ),
            const SizedBox(height: 24.0),
            ActionSlider.custom(
              width: 300.0,
              controller: _controller,
              height: 60.0,
              toggleWidth: 60.0,
              toggleMargin: EdgeInsets.zero,
              foregroundChild: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Icon(Icons.check_rounded, color: Colors.white)),
              foregroundBuilder: (context, state, child) => child!,
              outerBackgroundBuilder: (context, state, child) => Card(
                margin: EdgeInsets.zero,
                color: Color.lerp(Colors.red, Colors.green, state.position),
                child: Center(
                    child: Text(state.position.toStringAsFixed(2),
                        style: theme.textTheme.titleMedium)),
              ),
              action: (controller) async {
                controller.loading(); //starts loading animation
                await Future.delayed(const Duration(seconds: 3));
                controller.success(); //starts success animation
                await Future.delayed(const Duration(seconds: 1));
                controller.reset(); //resets the slider
              },
            ),
            const SizedBox(height: 24.0),
            ActionSlider.custom(
              toggleMargin: EdgeInsets.zero,
              width: 300.0,
              controller: _controller,
              toggleWidth: 60.0,
              height: 60.0,
              foregroundChild: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white)),
              foregroundBuilder: (context, state, child) => child!,
              backgroundChild: Center(
                child: Text('Highly Customizable :)',
                    style: theme.textTheme.titleMedium),
              ),
              backgroundBuilder: (context, state, child) => ClipRect(
                  child: OverflowBox(
                      maxWidth: state.standardSize.width,
                      maxHeight: state.toggleSize.height,
                      minWidth: state.standardSize.width,
                      minHeight: state.toggleSize.height,
                      child: child!)),
              action: (controller) async {
                controller.loading(); //starts loading animation
                await Future.delayed(const Duration(seconds: 3));
                controller.success(); //starts success animation
                await Future.delayed(const Duration(seconds: 1));
                controller.reset(); //resets the slider
              },
              outerBackgroundBuilder: (context, state, _) => DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.green)),
            ),
            const SizedBox(height: 24.0),
            ActionSlider.custom(
              width: 300.0,
              controller: _controller,
              sizeAnimationDuration: const Duration(milliseconds: 700),
              sizeAnimationCurve:
                  const Interval(0.6, 1.0, curve: Curves.easeInOut),
              foregroundBuilder: (context, state, _) {
                final status = state.status;
                return Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Opacity(
                      opacity: 1.0 - state.relativeSize,
                      child: AnimatedCheckIcon(
                        icon: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 32.0),
                        visible: status is SliderStatusSuccess,
                        animationCurve: const Interval(0.8, 1.0),
                        animationDuration: const Duration(milliseconds: 1000),
                      ),
                    ),
                    Opacity(
                      opacity: 1.0 - state.relativeSize,
                      child: CrossFade(
                          value: status,
                          builder: (context, status) =>
                              status is SliderStatusLoading
                                  ? const Center(
                                      child: CupertinoActivityIndicator(
                                          color: Colors.white))
                                  : const SizedBox()),
                    ),
                    Opacity(
                      opacity: state.relativeSize,
                      child: ScaleAppearingWidget(
                        animationDuration: const Duration(milliseconds: 1000),
                        animationCurve:
                            const Interval(0.7, 1.0, curve: Curves.easeOutBack),
                        visible: status.expanded,
                        child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                            ),
                            child: Transform.rotate(
                                angle: -state.position * pi,
                                child: const Icon(Icons.arrow_forward,
                                    color: Colors.pinkAccent))),
                      ),
                    ),
                  ],
                );
              },
              backgroundBuilder: (context, state, _) => Center(
                child: Text('Highly Customizable :)',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white.withOpacity(1.0 - state.position))),
              ),
              action: (controller) async {
                controller.success(); //starts success animation
                await Future.delayed(const Duration(seconds: 3));
                controller.reset(); //resets the slider
              },
              outerBackgroundBuilder: (context, state, _) => DecoratedBox(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                color: Colors.pinkAccent,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
