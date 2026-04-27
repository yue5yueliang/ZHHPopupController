# ZHHPopupController

[![CI Status](https://img.shields.io/travis/ningxiaomo0516/ZHHPopupController.svg?style=flat)](https://travis-ci.org/ningxiaomo0516/ZHHPopupController)
[![Version](https://img.shields.io/cocoapods/v/ZHHPopupController.svg?style=flat)](https://cocoapods.org/pods/ZHHPopupController)
[![License](https://img.shields.io/cocoapods/l/ZHHPopupController.svg?style=flat)](https://cocoapods.org/pods/ZHHPopupController)
[![Platform](https://img.shields.io/cocoapods/p/ZHHPopupController.svg?style=flat)](https://cocoapods.org/pods/ZHHPopupController)

一个轻量、易用的弹窗控制器，支持弹出/消失动画、布局位置、遮罩（透明/半透明/模糊）、键盘联动、点击/滑动关闭、windowLevel 分层与多弹窗管理等。

## 能力

- 支持多种布局：`center / top / left / bottom / right / aboveCenter / belowCenter / custom`
- 支持多种动画：内置展示/消失动画，支持弹性（bounced）与弹性退出（dismissBounced）
- 遮罩类型：`blackOpacity / clear / none / darkBlur / lightBlur / extraLightBlur / white`，支持自定义透明度
- 交互：点击遮罩关闭、拖拽（pan）关闭（上下左右）
- 键盘：键盘弹出/收起时联动调整内容视图位置
- 多弹窗：支持 `windowLevel` 分层与同层叠加管理

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 15.0+
- Swift 5.x

## Installation

ZHHPopupController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZHHPopupController'
```

## 使用

### 基本用法

```swift
let content = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
content.backgroundColor = .systemBackground
content.layer.cornerRadius = 12
content.layer.masksToBounds = true

let popup = ZHHPopupController(view: content, size: content.bounds.size)
popup.maskType = .blackOpacity
popup.maskAlpha = 0.4
popup.layoutType = .center
popup.presentationStyle = .fromBottom
popup.dismissalStyle = .fromBottom
popup.dismissOnMaskTouched = true

popup.show(in: view, completion: nil)
// popup.dismiss()
```

### 滑动关闭（仅 top/left/bottom/right）

```swift
popup.layoutType = .bottom
popup.panGestureEnabled = true
popup.panDismissEnabled = true
popup.bottomPanFullScreenEnabled = true
popup.panDismissRatio = 0.35
```

### 键盘联动

```swift
popup.layoutType = .center
popup.keyboardChangeFollowed = true
popup.syncFirstResponderWithPresentation = true
popup.keyboardOffsetSpacing = 50
```

## Author

桃色三岁, 136769890@qq.com

## License

ZHHPopupController is available under the MIT license. See the LICENSE file for more info.
