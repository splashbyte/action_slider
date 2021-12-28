<a href="https://pub.dev/packages/loading_slider"><img src="https://img.shields.io/pub/v/loading_slider.svg?style=flat?logo=dart" alt="pub.dev"></a>
<a href="https://github.com/SplashByte/loading_slider"><img src="https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd" alt="github"></a>
[![likes](https://badges.bar/loading_slider/likes)](https://pub.dev/packages/loading_slider/score)
[![popularity](https://badges.bar/loading_slider/popularity)](https://pub.dev/packages/loading_slider/score)
[![pub points](https://badges.bar/loading_slider/pub%20points)](https://pub.dev/packages/loading_slider/score)
<a href="https://github.com/SplashByte/loading_slider/blob/main/LICENSE"><img src="https://img.shields.io/github/license/SplashByte/loading_slider.svg" alt="license"></a>

[![buy me a coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/splashbyte)

### If you like this package, please leave a like there on [pub.dev](https://pub.dev/packages/loading_slider) and star on [GitHub](https://github.com/SplashByte/loading_slider).

A slider to confirm actions and provide feedback on the success of these after subsequent loading.

### Example Usage

## Easy Usage

Easy to use and highly customizable.

```dart
ConfirmationSlider.standard(
    width: 300.0,
    child: const Text('Slide to confirm'),
    successIcon: const Icon(Icons.check_rounded, color: Colors.white),
    onSlide: (loading, success, failure) async {
        loading(); //or controller.loading()
        await Future.delayed(const Duration(seconds: 3));
        success(); //or controller.success()
    },
),
```
