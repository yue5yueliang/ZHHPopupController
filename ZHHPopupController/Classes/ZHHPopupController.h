//
//  ZHHPopupController.h
//  ZHHAnneKitExample
//
//  Created by 宁小陌 on 2022/8/24.
//  Copyright © 2022 宁小陌y. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 控制视图遮罩样式
typedef NS_ENUM(NSUInteger, ZHHPopupMaskType) {
    ZHHPopupMaskTypeDarkBlur = 0,
    ZHHPopupMaskTypeLightBlur,
    ZHHPopupMaskTypeExtraLightBlur,
    ZHHPopupMaskTypeWhite,
    ZHHPopupMaskTypeClear,
    ZHHPopupMaskTypeBlackOpacity // default
};

/// 控制视图呈现样式
typedef NS_ENUM(NSInteger, ZHHPopupSlideStyle) {
    ZHHPopupSlideStyleFromTop = 0,
    ZHHPopupSlideStyleFromBottom,
    ZHHPopupSlideStyleFromLeft,
    ZHHPopupSlideStyleFromRight,
    ZHHPopupSlideStyleFade, // default
    ZHHPopupSlideStyleTransform
};

/// 控制视图的最终位置
typedef NS_ENUM(NSUInteger, ZHHPopupLayoutType) {
    ZHHPopupLayoutTypeTop = 0,
    ZHHPopupLayoutTypeBottom,
    ZHHPopupLayoutTypeLeft,
    ZHHPopupLayoutTypeRight,
    ZHHPopupLayoutTypeCenter // default
};

/// 控制PopupController的显示层级
typedef NS_ENUM(NSUInteger, ZHHPopupWindowLevel) {
    ZHHPopupWindowLevelVeryHigh = 0,
    ZHHPopupWindowLevelHigh,
    ZHHPopupWindowLevelNormal, // default
    ZHHPopupWindowLevelLow,
    ZHHPopupWindowLevelVeryLow
};

@protocol ZHHPopupControllerDelegate;

@interface ZHHPopupController : NSObject

@property (nonatomic, weak) id <ZHHPopupControllerDelegate> _Nullable delegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 指定的初始化方法，必须设置内容视图及其大小。将视图绑定到弹出控制器，一对一
- (instancetype)initWithView:(UIView *)popupView size:(CGSize)size;

/// 视图已初始化弹出视图
@property (nonatomic, strong, readonly) UIView *contentView;

/// 内容视图是否正在显示
@property (nonatomic, assign, readonly) BOOL isPresenting;

/// 设置弹出视图的遮罩样式。默认值是 ZHHPopupMaskTypeBlackOpacity（遮罩透明度：0.5）
@property (nonatomic, assign) ZHHPopupMaskType maskType;

/// 设置弹出视图的显示位置。默认值是 ZHHPopupLayoutTypeCenter
@property (nonatomic, assign) ZHHPopupLayoutType layoutType;

/// 设置弹出视图的呈现滑动样式。默认值是 ZHHPopupSlideStyleFade
@property (nonatomic, assign) ZHHPopupSlideStyle presentationStyle;

/// 设置弹出视图的消失滑动样式。默认值是 presentationStyle
@property (nonatomic, assign) ZHHPopupSlideStyle dismissonStyle;

/// 设置弹出视图的优先级。默认值是 ZHHPopupWindowLevelNormal
@property (nonatomic, assign) ZHHPopupWindowLevel windowLevel;

/// 默认为 0.5，当 maskType 是 ZHHPopupMaskTypeBlackOpacity 时有效。
@property (nonatomic, assign) CGFloat maskAlpha;

/// 默认为 0.5，当 slideStyle 为 ZHHPopupSlideStyleTransform 时有效。
@property (nonatomic, assign) CGFloat presentationTransformScale;

/// 默认为 presentationTransformScale，当 slideStyle 为 ZHHPopupSlideStyleTransform 时有效。
@property (nonatomic, assign) CGFloat dismissonTransformScale;

/// 默认为 YES。如果为 NO，遮罩视图将不会响应事件。
@property (nonatomic, assign) BOOL dismissOnMaskTouched;

/// 视图将在 dismissAfterDelay 秒后消失，默认值为 0，表示不会消失。
@property (nonatomic, assign) NSTimeInterval dismissAfterDelay;

/// 默认为 NO。如果设置为 YES，弹出视图将允许拖动。
@property (nonatomic, assign) BOOL panGestureEnabled;

/// 当拖动位置达到屏幕比例时，视图将消失，默认值为 0.5。
@property (nonatomic, assign) CGFloat panDismissRatio;

/// 通过 offsetSpacing 调整布局位置
@property (nonatomic, assign) CGFloat offsetSpacing;

/// 调整与键盘之间的间距
@property (nonatomic, assign) CGFloat keyboardOffsetSpacing;

/// 默认为 NO。如果设置为 YES，当键盘变化时将调整视图位置。
@property (nonatomic, assign) BOOL keyboardChangeFollowed;

/// 默认为 NO。如果视图成为第一响应者，需要设置为 YES 以保持动画的一致性。
/// 如果你想保持动画的一致性：
/// 你需要在 willPresentBlock 中调用 becomeFirstResponder() 方法，不要在此之前调用。
/// 你需要在 willDismissBlock 中调用 resignFirstResponder() 方法。
@property (nonatomic, assign) BOOL becomeFirstResponded;

/// 当内部触发消失时，块会被调用。
@property (nonatomic, copy) void (^defaultDismissBlock)(ZHHPopupController *popupController);

/// 当 contentView 将要呈现时，块会被调用。
@property (nonatomic, copy) void (^willPresentBlock)(ZHHPopupController *popupController);

/// 当 contentView 已经呈现时，块会被调用。
@property (nonatomic, copy) void (^didPresentBlock)(ZHHPopupController *popupController);

/// 当 contentView 将要消失时，块会被调用。
@property (nonatomic, copy) void (^willDismissBlock)(ZHHPopupController *popupController);

/// 当 contentView 已经消失时，块会被调用。
@property (nonatomic, copy) void (^didDismissBlock)(ZHHPopupController *popupController);

@end


@interface ZHHPopupController (quick)

/// 在窗口中以动画方式显示弹出视图
- (void)show;

/// 以动画方式显示弹出视图
- (void)showInView:(UIView *)view completion:(void (^ __nullable)(void))completion;

/// 使用指定的持续时间以动画方式显示弹出视图
- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration completion:(void (^ __nullable)(void))completion;

/// 使用指定的持续时间和弹跳效果以动画方式显示弹出视图
- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration bounced:(BOOL)bounced completion:(void (^ __nullable)(void))completion;

/// 使用指定的持续时间、延迟、选项、弹跳效果和完成处理程序以动画方式显示弹出视图
- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options bounced:(BOOL)bounced completion:(void (^ __nullable)(void))completion;

/// 以动画方式隐藏弹出视图
- (void)dismiss;

/// 使用指定的持续时间以动画方式隐藏弹出视图
- (void)dismissWithDuration:(NSTimeInterval)duration completion:(void (^ __nullable)(void))completion;

/// 使用指定的持续时间、延迟、选项和完成处理程序以动画方式隐藏弹出视图
- (void)dismissWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^ __nullable)(void))completion;

@end


@protocol ZHHPopupControllerDelegate <NSObject>
@optional

//  委托方法，推荐使用块（block）。
- (void)popupControllerWillPresent:(ZHHPopupController *)popupController;
- (void)popupControllerDidPresent:(ZHHPopupController *)popupController;
- (void)popupControllerWillDismiss:(ZHHPopupController *)popupController;
- (void)popupControllerDidDismiss:(ZHHPopupController *)popupController;

@end

NS_ASSUME_NONNULL_END
