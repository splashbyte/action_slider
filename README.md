[![pub.dev](https://img.shields.io/pub/v/action_slider.svg?style=flat?logo=dart)](https://pub.dev/packages/action_slider)
[![github](https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd)](https://github.com/SplashByte/action_slider)
[![likes](https://img.shields.io/pub/likes/action_slider)](https://pub.dev/packages/action_slider/score)
[![popularity](https://img.shields.io/pub/popularity/action_slider)](https://pub.dev/packages/action_slider/score)
[![pub points](https://img.shields.io/pub/points/action_slider)](https://pub.dev/packages/action_slider/score)
[![license](https://img.shields.io/github/license/SplashByte/action_slider.svg)](https://github.com/SplashByte/action_slider/blob/main/LICENSE)

[![buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20pizza&emoji=🍕&slug=splashbyte&button_colour=FF8838&font_colour=ffffff&font_family=Poppins&outline_colour=000000&coffee_colour=ffffff')](https://www.buymeacoffee.com/splashbyte)

### If you like this package, please leave a like there on [pub.dev](https://pub.dev/packages/action_slider) and star on [GitHub](https://github.com/SplashByte/action_slider).

A slider to confirm actions and provide feedback on the success of these after subsequent loading.  
`LTR` and `RTL` are both supported.  
For a switch with a similar look, you can check out [animated_toggle_switch](https://pub.dev/packages/animated_toggle_switch).

## Examples
`ActionSlider.standard()` with `SliderBehavior.stretch`  
![action_slider_example_snake](https://github.com/splashbyte/action_slider/assets/43761463/d2f92414-bded-48ae-9cf5-9df030fb0be8)  
![action_slider_expanded](https://github.com/user-attachments/assets/14af4bab-71e5-4330-9efe-fd280a89a0cc)

`ActionSlider.standard()` with `TextDirection.rtl`  
![action_slider_example_rtl](https://github.com/splashbyte/action_slider/assets/43761463/5d81d3d2-ca52-4eb5-93b3-fada883a6a4f)

`ActionSlider.dual()`  
![action_slider_example_dual](https://github.com/splashbyte/action_slider/assets/43761463/4903161e-d2f4-47aa-934a-464fba33d2df)

`ActionSlider.dual()` with some customizations  
![action_slider_example_dual_custom](https://github.com/user-attachments/assets/1acdcd46-9b8b-4e6c-b012-fe7325ab4729)

`ActionSlider.standard()` with `rolling = true`  
![action_slider_example_rolling](https://github.com/splashbyte/action_slider/assets/43761463/0a5010e2-d369-46d3-bdfb-0df5832125ed)

`ActionSlider.standard()` with `SliderBehavior.stretch` and `rolling = true`  
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
