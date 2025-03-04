[![pub.dev](https://img.shields.io/pub/v/action_slider.svg?style=flat?logo=dart)](https://pub.dev/packages/action_slider)
[![github](https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd)](https://github.com/SplashByte/action_slider)
[![likes](https://img.shields.io/pub/likes/action_slider)](https://pub.dev/packages/action_slider/score)
[![downloads](https://img.shields.io/pub/dm/action_slider)](https://pub.dev/packages/action_slider/score)
[![pub points](https://img.shields.io/pub/points/action_slider)](https://pub.dev/packages/action_slider/score)
[![license](https://img.shields.io/github/license/SplashByte/action_slider.svg)](https://github.com/SplashByte/action_slider/blob/main/LICENSE)
[![buy me a coffee](https://img.shields.io/badge/-buy_me_a%C2%A0coffee-gray?logo=buy-me-a-coffee)](https://www.buymeacoffee.com/splashbyte)

### If you like this package, please leave a like there on [pub.dev](https://pub.dev/packages/action_slider) and star on [GitHub](https://github.com/SplashByte/action_slider).

A fully customizable slider to confirm actions and provide feedback on the success. It supports different states like loading, success and failure.

`LTR` and `RTL` are both supported.  
For a switch with a similar look, you can check out [animated_toggle_switch](https://pub.dev/packages/animated_toggle_switch).

## Examples
`ActionSlider.standard()` with `SliderBehavior.stretch`  
![action_slider_example_snake](https://github.com/splashbyte/action_slider/assets/43761463/d2f92414-bded-48ae-9cf5-9df030fb0be8)  
![action_slider_example_expanded](https://github.com/user-attachments/assets/c14f6bee-f2b9-4dfd-806c-fe2fa089a0ea)

`ActionSlider.dual()`  
![action_slider_example_dual](https://github.com/splashbyte/action_slider/assets/43761463/4903161e-d2f4-47aa-934a-464fba33d2df)  
![action_slider_example_dual_customized](https://github.com/user-attachments/assets/b4561a3b-daf9-4f60-a30b-c3f83f5f0f8e)

`ActionSlider.standard()` with `TextDirection.rtl`  
![action_slider_example_rtl](https://github.com/splashbyte/action_slider/assets/43761463/5d81d3d2-ca52-4eb5-93b3-fada883a6a4f)

`ActionSlider.standard()` with `SliderIconAnimation.roll`  
![action_slider_example_rolling](https://github.com/splashbyte/action_slider/assets/43761463/0a5010e2-d369-46d3-bdfb-0df5832125ed)

`ActionSlider.standard()` with `SliderBehavior.stretch` and `SliderIconAnimation.roll`  
![action_slider_example_rolling_snake](https://github.com/splashbyte/action_slider/assets/43761463/e4f27603-83db-412a-8777-c737a9c55b14)

You can build your own sliders with `ActionSlider.custom()`  
![action_slider_example_custom](https://github.com/splashbyte/action_slider/assets/43761463/3b751087-f721-40f2-9055-4aa8af61e0d8)


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

Two directions with `ActionSlider.dual`
```dart
ActionSlider.dual(
    child: const Text('Slide to confirm'),
    startAction: (controller) async {
        controller.success(expanded: true, side: SliderSide.start); //starts success animation with an expanded slider
    },
    endAction: (controller) async {
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
