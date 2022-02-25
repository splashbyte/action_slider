import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confirmation Slider Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Confirmation Slider Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = ActionSliderController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ActionSlider.standard(
              width: 300.0,
              child: const Text('Slide to confirm'),
              onSlide: (controller) async {
                controller.loading(); //starts loading animation
                await Future.delayed(const Duration(seconds: 3));
                controller.success(); //starts success animation
                await Future.delayed(const Duration(seconds: 1));
                controller.reset(); //resets the slider
              },
            ),
            const SizedBox(height: 24.0),
            ActionSlider.custom(
              width: 300.0,
              controller: _controller,
              height: 60.0,
              backgroundColor: Colors.green,
              foregroundChild: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Icon(Icons.check_rounded, color: Colors.white)),
              foregroundBuilder: (context, pos, width, height, child, mode) =>
                  child!,
              backgroundChild: Center(
                child: Text('Highly Customizable :)',
                    style: theme.textTheme.subtitle1),
              ),
              backgroundBuilder: (context, pos, width, height, child) => child!,
              backgroundBorderRadius: BorderRadius.circular(5.0),
              onSlide: (controller) async {
                controller.loading(); //or controller.loading()
                await Future.delayed(const Duration(seconds: 3));
                controller.success(); //or controller.success()
                await Future.delayed(const Duration(seconds: 1));
                controller.reset(); //for resetting the slider
              },
            )
          ],
        ),
      ),
    );
  }
}
