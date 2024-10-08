## 0.8.0-beta.4

- adds `cursors` to all constructors

## 0.8.0-beta.3 [2024-09-21]

- adds `childPosition` to `ActionSlider.standard`
- adds `childAnimation` parameter to `ActionSlider.standard` and `ActionSlider.dual`
- migrates from `SliderMode` to `SliderStatus`
- adds `status` to all constructors
- adds `expanded`, `highlighted` and `side` parameters to `SliderMode.loading`, `SliderMode.success`
  and `SliderMode.failure`
- BREAKING: renames `customForegroundBuilder` to `customIconBuilder`
- BREAKING: changes default background color from `ThemeData.cardColor` to `ThemeData.colorScheme.surface`
- BREAKING: removes `rolling` in favor of the new `iconAnimation` parameter
- BREAKING: renames `SlidingState` to `SlidingStatus`
- BREAKING: moves parameters in `ActionSlider.standard` and `ActionSlider.dual` to `style`:
    - `backgroundColor`
    - `backgroundBorderRadius` (renamed to `borderRadius`)
    - `toggleColor`
    - `boxShadow`
- adds option to add `SliderStyle` to `extensions` of `ThemeData`

## 0.8.0-beta.2 [2024-07-31]

- fixes `rolling` with `ActionSlider.dual` and when using a custom `SliderMode`
- BREAKING: removes `ActionSliderController.dual`
- BREAKING: moves `anchorPosition` and `allowedInterval` from `ActionSliderControllerState` to `ActionSlider`

## 0.8.0-beta.1 [2024-07-31]

- fixes `SliderBehavior.stretch` with `ActionSlider.dual`
- BREAKING: default loading icon is now adaptive for iOS and macOS

## 0.8.0-beta.0 [2024-07-30]

- BREAKING: increases minimum SDK to 3.0.0
- BREAKING: renames `movementCurve` to `anchorPositionCurve`
- BREAKING: renames `movementDuration` to `anchorPositionDuration`
- BREAKING: renames `SliderDirection.begin` to `SliderDirection.start`
- adds `resultToggleMargin`, `toggleMarginCurve` and `toggleMarginDuration`
- adds `SliderMode.loadingExpanded`, `SliderMode.successExpanded` and `SliderMode.failureExpanded`

## 0.7.0 [2023-07-30]

- BREAKING: increases minimum SDK to 2.17
- BREAKING: changes default background color from `ThemeData.backgroundColor` to `ThemeData.cardColor`
- BREAKING: changes state type of `ActionSliderController` from `SliderMode` to `ActionSliderControllerState`
- adds `anchorPosition` and `allowedInterval` to `ActionSliderController`
- adds `anchorPosition` and `allowedInterval` to `SliderState`
- adds `ActionSliderController.dual`
- closes [#6](https://github.com/splashbyte/action_slider/issues/6)

## 0.6.1 [2022-12-09]

- adds support for `RTL`
- adds `direction` to constructors

## 0.6.0 [2022-07-05]

- minor fixes
- fixes #1
- BREAKING: renames `onSlide` to `action` in `ActionSlider.standard`

## 0.5.0 [2022-03-17]

- adds `stateChangeCallback`, `actionThreshold` and `actionThresholdType`
- BREAKING: renames `onSlide` to `action`
- BREAKING: renames `SlideCallback` to `Action`

## 0.4.0 [2022-03-17]

- major customizability improvements
- adds `outerBackgroundBuilder` and `outerBackgroundChild` to constructor `ActionSlider.custom`
- adds `crossFadeDuration`, `customBackgroundBuilder`, `customBackgroundBuilderChild`
  , `customOuterBackgroundBuilder` and `customOuterBackgroundBuilderChild` to
  constructor `ActionSlider.standard`
- BREAKING: renames `SlidingState.loading` to `SlidingState.compact`
- BREAKING: renames `CrossFade` to `SliderCrossFade`
- BREAKING change for constructor `ActionSlider.standard`:
    - removes `circleRadius` and adds `borderWidth` instead
- BREAKING change for constructor `ActionSlider.custom`:
    - removes `toggleHeight` and adds `toggleMargin` instead

## 0.3.0 [2022-03-12]

- adds `onTap` parameter
- adds jump method to `ActionSliderController`
- minor gesture detection improvements

## 0.2.1 [2022-02-28]

- changes README.md

## 0.2.0 [2022-02-28]

- BREAKING: changes parameters of `ForegroundBuilder` and `BackgroundBuilder`
- adds `SliderBehaviour.stretch`

## 0.1.2 [2022-02-25]

- BREAKING: changes parameters of `SlideCallback`
- optimizes fade animation

## 0.1.1 [2022-02-21]

- fixes README.md

## 0.1.0 [2022-02-21]

- initial release
