<a href="https://pub.dev/packages/action_slider"><img src="https://img.shields.io/pub/v/action_slider.svg?style=flat?logo=dart" alt="pub.dev"></a>
<a href="https://github.com/SplashByte/action_slider"><img src="https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd" alt="github"></a>
[![likes](https://badges.bar/action_slider/likes)](https://pub.dev/packages/action_slider/score)
[![popularity](https://badges.bar/action_slider/popularity)](https://pub.dev/packages/action_slider/score)
[![pub points](https://badges.bar/action_slider/pub%20points)](https://pub.dev/packages/action_slider/score)
<a href="https://github.com/SplashByte/action_slider/blob/main/LICENSE"><img src="https://img.shields.io/github/license/SplashByte/action_slider.svg" alt="license"></a>

[![buy me a coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/splashbyte)

### If you like this package, please leave a like there on [pub.dev](https://pub.dev/packages/action_slider) and star on [GitHub](https://github.com/SplashByte/action_slider).

A slider to confirm actions and provide feedback on the success of these after subsequent loading.

## Examples

![action_slider](https://user-images.githubusercontent.com/43761463/147601537-a09d9772-abfa-4409-88c7-1f1e0f04c27a.gif)
![action_slider_rolling](https://user-images.githubusercontent.com/43761463/147601547-ae8200b0-668c-4d1d-a7e5-80691e156a62.gif)
![action_slider_custom](https://user-images.githubusercontent.com/43761463/147602062-87f55f38-9cbf-4a89-ae4d-48ca81317dca.gif)

## Easy Usage

Easy to use and highly customizable.

```dart
ActionSlider.standard(
    child: const Text('Slide to confirm'),
    onSlide: (controller) async {
        controller.loading(); //starts loading animation
        await Future.delayed(const Duration(seconds: 3));
        controller.success(); //starts success animation
    },
)
```
