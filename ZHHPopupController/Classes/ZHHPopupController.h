//
//  ZHHPopupController.h
//  ZHHAnneKitExample
//
//  Created by 宁小陌 on 2022/8/24.
//  Copyright © 2022 宁小陌y. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Control view mask style
typedef NS_ENUM(NSUInteger, ZHHPopupMaskType) {
    ZHHPopupMaskTypeDarkBlur = 0,
    ZHHPopupMaskTypeLightBlur,
    ZHHPopupMaskTypeExtraLightBlur,
    ZHHPopupMaskTypeWhite,
    ZHHPopupMaskTypeClear,
    ZHHPopupMaskTypeBlackOpacity // default
};

/// Control the style of view Presenting
typedef NS_ENUM(NSInteger, ZHHPopupSlideStyle) {
    ZHHPopupSlideStyleFromTop = 0,
    ZHHPopupSlideStyleFromBottom,
    ZHHPopupSlideStyleFromLeft,
    ZHHPopupSlideStyleFromRight,
    ZHHPopupSlideStyleFade, // default
    ZHHPopupSlideStyleTransform
};

/// Control where the view finally position
typedef NS_ENUM(NSUInteger, ZHHPopupLayoutType) {
    ZHHPopupLayoutTypeTop = 0,
    ZHHPopupLayoutTypeBottom,
    ZHHPopupLayoutTypeLeft,
    ZHHPopupLayoutTypeRight,
    ZHHPopupLayoutTypeCenter // default
};

/// Control the display level of the PopupController
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

/// Designated initializer，Must set your content view and its size.
/// Bind the view to a popup controller，one-to-one
- (instancetype)initWithView:(UIView *)popupView size:(CGSize)size;

/// The view is the initialized `popupView`
@property (nonatomic, strong, readonly) UIView *view;

/// Whether contentView is presenting.
@property (nonatomic, assign, readonly) BOOL isPresenting;

/// Set popup view mask style. default is ZHHPopupMaskTypeBlackOpacity (maskAlpha: 0.5)
@property (nonatomic, assign) ZHHPopupMaskType maskType;

/// Set popup view display position. default is ZHHPopupLayoutTypeCenter
@property (nonatomic, assign) ZHHPopupLayoutType layoutType;

/// Set popup view present slide style. default is ZHHPopupSlideStyleFade
@property (nonatomic, assign) ZHHPopupSlideStyle presentationStyle;

/// Set popup view dismiss slide style. default is `presentationStyle`
@property (nonatomic, assign) ZHHPopupSlideStyle dismissonStyle;

/// Set popup view priority. default is ZHHPopupWindowLevelNormal
@property (nonatomic, assign) ZHHPopupWindowLevel windowLevel;

/// default is 0.5, When maskType is ZHHPopupMaskTypeBlackOpacity vaild.
@property (nonatomic, assign) CGFloat maskAlpha;

/// default is 0.5, When slideStyle is ZHHPopupSlideStyleTransform vaild.
@property (nonatomic, assign) CGFloat presentationTransformScale;

/// default is `presentationTransformScale`, When slideStyle is ZHHPopupSlideStyleTransform vaild.
@property (nonatomic, assign) CGFloat dismissonTransformScale;

/// default is YES. if NO, Mask view will not respond to events.
@property (nonatomic, assign) BOOL dismissOnMaskTouched;

/// The view will disappear after `dismissAfterDelay` seconds，default is 0 will not disappear
@property (nonatomic, assign) NSTimeInterval dismissAfterDelay;

/// default is NO. if YES, Popup view will allow to drag
@property (nonatomic, assign) BOOL panGestureEnabled;

/// When drag position meets the screen ratio the view will dismiss，default is 0.5
@property (nonatomic, assign) CGFloat panDismissRatio;

/// Adjust the layout position by `offsetSpacing`
@property (nonatomic, assign) CGFloat offsetSpacing;

/// Adjust the spacing between with the keyboard
@property (nonatomic, assign) CGFloat keyboardOffsetSpacing;

/// default is NO. if YES, Will adjust view position when keyboard changes
@property (nonatomic, assign) BOOL keyboardChangeFollowed;

/// default is NO. if the view becomes first responder，you need set YES to keep the animation consistent
/// If you want to make the animation consistent:
/// You need to call the method "becomeFirstResponder()" in "willPresentBlock", don't call it before that.
/// You need to call the method "resignFirstResponder()" in "willDismissBlock".
@property (nonatomic, assign) BOOL becomeFirstResponded;

/// Block gets called when internal trigger dismiss.
@property (nonatomic, copy) void (^defaultDismissBlock)(ZHHPopupController *popupController);

/// Block gets called when contentView will present.
@property (nonatomic, copy) void (^willPresentBlock)(ZHHPopupController *popupController);

/// Block gets called when contentView did present.
@property (nonatomic, copy) void (^didPresentBlock)(ZHHPopupController *popupController);

/// Block gets called when contentView will dismiss.
@property (nonatomic, copy) void (^willDismissBlock)(ZHHPopupController *popupController);

/// Block gets called when contentView did dismiss.
@property (nonatomic, copy) void (^didDismissBlock)(ZHHPopupController *popupController);

@end


@interface ZHHPopupController (Convenient)

/// shows popup view animated in window
- (void)show;

/// shows popup view animated.
- (void)showInView:(UIView *)view completion:(void (^ __nullable)(void))completion;

/// shows popup view animated using the specified duration.
- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration completion:(void (^ __nullable)(void))completion;

/// shows popup view animated using the specified duration and bounced.
- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration bounced:(BOOL)bounced completion:(void (^ __nullable)(void))completion;

/// shows popup view animated using the specified duration, delay, options, bounced, and completion handler.
- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options bounced:(BOOL)bounced completion:(void (^ __nullable)(void))completion;

/// hide popup view animated
- (void)dismiss;

/// hide popup view animated using the specified duration.
- (void)dismissWithDuration:(NSTimeInterval)duration completion:(void (^ __nullable)(void))completion;

/// hide popup view animated using the specified duration, delay, options, and completion handler.
- (void)dismissWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^ __nullable)(void))completion;

@end


@protocol ZHHPopupControllerDelegate <NSObject>
@optional

// - The Delegate method, block is preferred.
- (void)popupControllerWillPresent:(ZHHPopupController *)popupController;
- (void)popupControllerDidPresent:(ZHHPopupController *)popupController;
- (void)popupControllerWillDismiss:(ZHHPopupController *)popupController;
- (void)popupControllerDidDismiss:(ZHHPopupController *)popupController;

@end

NS_ASSUME_NONNULL_END
