[![pub.dev](https://img.shields.io/pub/v/action_slider.svg?style=flat?logo=dart)](https://pub.dev/packages/action_slider)
[![github](https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd)](https://github.com/SplashByte/action_slider)
[![likes](https://img.shields.io/pub/likes/action_slider)](https://pub.dev/packages/action_slider/score)
[![popularity](https://img.shields.io/pub/popularity/action_slider)](https://pub.dev/packages/action_slider/score)
[![pub points](https://img.shields.io/pub/points/action_slider)](https://pub.dev/packages/action_slider/score)
[![license](https://img.shields.io/github/license/SplashByte/action_slider.svg)](https://github.com/SplashByte/action_slider/blob/main/LICENSE)

[![buy me a coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/splashbyte)

### If you like this package, please leave a like there on [pub.dev](https://pub.dev/packages/action_slider) and star on [GitHub](https://github.com/SplashByte/action_slider).

A slider to confirm actions and provide feedback on the success of these after subsequent loading.  
For a switch with a similar look, you can check out [animated_toggle_switch](https://pub.dev/packages/animated_toggle_switch).

## Examples
![action_slider_example](https://user-images.githubusercontent.com/43761463/156018021-0b938616-9b56-45bd-9dc2-676c283966a9.gif)

![action_slider_rtl_example](https://user-images.githubusercontent.com/43761463/206598104-dc0de437-3280-4901-8647-96397c792423.gif)



## Easy Usage

Easy to use and highly customizable.

```dart
ActionSlider.standard(
    child: const Text('Slide to confirm'),
    action: (controller) async {
        controller.loading(); //starts loading animation
        await Future.delayed(const Duration(seconds: 3));
        controller.success(); //starts success animation
    },
    ... //many more parameters
)
```

Maximum customizability with `ActionSlider.custom`.
```dart
ActionSlider.custom(
    foregroundBuilder: (context, state, child) => ...,
    backgroundBuilder: (context, state, child) => ...,
    outerBackgroundBuilder: (context, state, child) => ...,
    action: (controller) => ...,
    ... //many more parameters
)
```
