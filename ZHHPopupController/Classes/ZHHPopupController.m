//
//  ZHHPopupController.m
//  ZHHAnneKitExample
//
//  Created by 宁小陌 on 2022/8/24.
//  Copyright © 2022 宁小陌y. All rights reserved.
//

#import "ZHHPopupController.h"
#import <objc/runtime.h>

@interface ZHHPopupController () <UIGestureRecognizerDelegate> {
    NSTimer *_timer;
    BOOL _isKeyboardVisible;
    BOOL _directionalVertical;
    BOOL _isDirectionLocked;
}
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, weak) UIView *proxyView;
@property (nonatomic, strong) UITapGestureRecognizer    *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer    *panGesture;
@end

@implementation ZHHPopupController

- (void)defaultValueInitialization {
    _isPresenting = NO;
    _maskType = ZHHPopupMaskTypeBlackOpacity;
    _maskAlpha = 0.5;
    _layoutType = ZHHPopupLayoutTypeCenter;
    _presentationStyle = ZHHPopupSlideStyleFade;
    _dismissonStyle = -1;
    _windowLevel = ZHHPopupWindowLevelNormal;
    _presentationTransformScale = 0.5;
    _dismissonTransformScale = 0.5;
    _dismissOnMaskTouched = YES;
    _dismissAfterDelay = 0;
    _panGestureEnabled = NO;
    _panDismissRatio = 0.5;
    _offsetSpacing = 0;
    _keyboardOffsetSpacing = 0;
    _keyboardChangeFollowed = NO;
    _becomeFirstResponded = NO;
    _directionalVertical = NO;
    _isDirectionLocked = NO;
    _isKeyboardVisible = NO;
}

- (instancetype)initWithView:(UIView *)aView size:(CGSize)size {
    if (self = [super init]) {
        [self defaultValueInitialization];
        CGSize _size = CGSizeEqualToSize(CGSizeZero, size) ? aView.bounds.size : size;
        aView.frame = CGRectMake(0, 0, _size.width, _size.height);
        self.contentView = aView;
        __weak typeof(self) _self = self;
        self.defaultDismissBlock = ^(ZHHPopupController * _Nonnull popupController) {
            [_self dismiss];
        };
    }
    return self;
}

- (void)presentDuration:(NSTimeInterval)duration
                  delay:(NSTimeInterval)delay
                options:(UIViewAnimationOptions)options
                bounced:(BOOL)isBounced
             completion:(void (^)(void))completion {
    if (self.isPresenting) return;
    
    self.maskView.alpha = 0;
    [self prepareSlideStyle];
    self.contentView.center = [self prepareCenter];
    
    __block void (^finishedCallback)(void) = ^() {
        self->_isPresenting = YES;
        if (self.didPresentBlock) {
            self.didPresentBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
                [self.delegate popupControllerDidPresent:self];
            }
        }
        
        if (self.dismissAfterDelay > 0) {
            self->_timer = [NSTimer timerWithTimeInterval:self.dismissAfterDelay target:self selector:@selector(timerPerform) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:self->_timer forMode:NSRunLoopCommonModes];
        }
        
        if (completion) completion();
    };
    
    if (self.keyboardChangeFollowed && self.becomeFirstResponded) {
        self.contentView.center = [self finalCenter];
        if (self.willPresentBlock) {
            self.willPresentBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
                [self.delegate popupControllerWillPresent:self];
            }
        }
        
        [UIView animateWithDuration:duration delay:delay options:options animations:^{
            self.maskView.alpha = 1;
            [self finalSlideStyle];
        } completion:^(BOOL finished) {
            finishedCallback();
        }];
    } else {
     
        if (self.willPresentBlock) {
            self.willPresentBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
                [self.delegate popupControllerWillPresent:self];
            }
        }
        
        if (isBounced) {
            [UIView animateWithDuration:duration * 0.25 delay:delay options:options animations:^{
                self.maskView.alpha = 1;
            } completion:NULL];
            
            [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:0.6 initialSpringVelocity:0.25 options:options animations:^{
                [self finalSlideStyle];
                self.contentView.center = [self finalCenter];
            } completion:^(BOOL finished) {
                finishedCallback();
            }];
        } else {
            [UIView animateWithDuration:duration delay:delay options:options animations:^{
                self.maskView.alpha = 1;
                [self finalSlideStyle];
                self.contentView.center =  [self finalCenter];
            } completion:^(BOOL finished) {
                finishedCallback();
            }];
        }
        
    }
}
- (void)dismissDuration:(NSTimeInterval)duration
                  delay:(NSTimeInterval)delay
                options:(UIViewAnimationOptions)options
             completion:(void (^)(void))completion {
    if (!self.isPresenting) return;
    _isPresenting = NO;
    if (self.willDismissBlock) {
        self.willDismissBlock(self);
    } else {
        if ([self.delegate respondsToSelector:@selector(popupControllerWillDismiss:)]) {
            [self.delegate popupControllerWillDismiss:self];
        }
    }
    
    [UIView animateWithDuration:duration delay:delay options:options animations:^{
        [self dismissSlideStyle];
        self.contentView.center = [self dismissedCenter];
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self finalSlideStyle];
        [self removeSubviews];
        if (self.didDismissBlock) {
            self.didDismissBlock(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerDidDismiss:)]) {
                [self.delegate popupControllerDidDismiss:self];
            }
        }
        
        if (self.dismissAfterDelay > 0) {
            [self->_timer invalidate];
            self->_timer = nil;
        }
        
        if (completion) completion();
    }];
}

- (void)timerPerform {
    if (self.defaultDismissBlock) {
        self.defaultDismissBlock(self);
    }
}

- (void)addSubviewBelow:(UIView *)subview {
    [self.proxyView insertSubview:self.maskView belowSubview:subview];
    [self.proxyView insertSubview:self.contentView aboveSubview:self.maskView];
}

- (void)addSubview {
    [self.proxyView addSubview:self.maskView];
    [self.proxyView addSubview:self.contentView];
}

- (void)removeSubviews {
    [self.contentView removeFromSuperview];
    [_maskView removeFromSuperview];
}

- (void)prepareSlideStyle {
    [self takeSlideStyle:self.presentationStyle scale:self.presentationTransformScale];
}

- (void)dismissSlideStyle {
    [self takeSlideStyle:self.dismissonStyle < 0 ? self.presentationStyle : self.dismissonStyle scale:self.dismissonTransformScale];
}

- (void)takeSlideStyle:(ZHHPopupSlideStyle)slideStyle scale:(CGFloat)scale {
    switch (slideStyle) {
        case ZHHPopupSlideStyleFade: {
            self.contentView.alpha = 0;
        } break;
        case ZHHPopupSlideStyleTransform: {
            self.contentView.alpha = 0;
            self.contentView.transform = CGAffineTransformMakeScale(scale, scale);
        } break;
        default: break;
    }
}

- (void)finalSlideStyle {
    switch (self.presentationStyle) {
        case ZHHPopupSlideStyleFade: {
            self.contentView.alpha = 1;
        } break;
        case ZHHPopupSlideStyleTransform: {
            self.contentView.alpha = 1;
            self.contentView.transform = CGAffineTransformIdentity;
        } break;
        default: break;
    }
}

- (CGPoint)prepareCenter {
    return [self takeCenter:self.presentationStyle];
}

- (CGPoint)dismissedCenter {
    return [self takeCenter:self.dismissonStyle < 0 ? self.presentationStyle : self.dismissonStyle];
}

- (CGPoint)takeCenter:(ZHHPopupSlideStyle)slideStyle {
    CGSize contentViewSize = self.contentView.bounds.size;
    CGSize maskViewSize = self.maskView.bounds.size;
    switch (slideStyle) {
        case ZHHPopupSlideStyleFromTop:
            return CGPointMake([self finalCenter].x, -contentViewSize.height / 2);
        case ZHHPopupSlideStyleFromLeft:
            return CGPointMake(-contentViewSize.width / 2, [self finalCenter].y);
        case ZHHPopupSlideStyleFromBottom:
            return CGPointMake([self finalCenter].x, maskViewSize.height + contentViewSize.height / 2);
        case ZHHPopupSlideStyleFromRight:
            return CGPointMake(maskViewSize.width + contentViewSize.width / 2, [self finalCenter].y);
        default:
            return [self finalCenter];
    }
}

- (CGPoint)finalCenter {
    CGSize contentViewSize = self.contentView.bounds.size;
    CGSize maskViewSize = self.maskView.bounds.size;
    switch (self.layoutType) {
        case ZHHPopupLayoutTypeTop:
            return CGPointMake(self.maskView.center.x, contentViewSize.height / 2 + self.offsetSpacing);
        case ZHHPopupLayoutTypeLeft:
            return CGPointMake(contentViewSize.width / 2 + self.offsetSpacing, self.maskView.center.y);
        case ZHHPopupLayoutTypeBottom:
            return CGPointMake(self.maskView.center.x, maskViewSize.height - contentViewSize.height / 2 - self.offsetSpacing);
        case ZHHPopupLayoutTypeRight:
            return CGPointMake(maskViewSize.width - maskViewSize.width / 2 - self.offsetSpacing, self.maskView.center.y);
        case ZHHPopupLayoutTypeCenter:
            /// only adjust center.y
            return CGPointMake(self.maskView.center.x, self.maskView.center.y + self.offsetSpacing);
        default: break;
    }
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.proxyView.bounds];
        switch (self.maskType) {
            case ZHHPopupMaskTypeDarkBlur: {
                UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
                blurView.frame = _maskView.bounds;
                [_maskView insertSubview:blurView atIndex:0];
            } break;
            case ZHHPopupMaskTypeLightBlur: {
                UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
                blurView.frame = _maskView.bounds;
                [_maskView insertSubview:blurView atIndex:0];
            } break;
            case ZHHPopupMaskTypeExtraLightBlur: {
                UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
                UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
                blurView.frame = _maskView.bounds;
                [_maskView insertSubview:blurView atIndex:0];
            } break;
            case ZHHPopupMaskTypeWhite: {
                _maskView.backgroundColor = [UIColor whiteColor];
            } break;
            case ZHHPopupMaskTypeClear: {
                _maskView.backgroundColor = [UIColor clearColor];
            } break;
            case ZHHPopupMaskTypeBlackOpacity: {
                _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.maskAlpha];
            } break;
            default: break;
        }
        
        // 添加手势
        [self.maskView addGestureRecognizer:self.tapGesture];
        if (self.panGestureEnabled) {
            [self.contentView addGestureRecognizer:self.panGesture];
        }
    }
    return _maskView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return ![touch.view isDescendantOfView:self.contentView];
    }
    return YES;
}

// 是否与其他手势共存(新增)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - HandleGesture
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (self.isPresenting && self.dismissOnMaskTouched) {
        if (self.defaultDismissBlock) {
            self.defaultDismissBlock(self);
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (_isKeyboardVisible || !self.panGestureEnabled) return;
    CGPoint pan = [panGesture translationInView:self.maskView];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            switch (self.layoutType) {
                case ZHHPopupLayoutTypeTop: {
                    CGFloat boundary = panGesture.view.bounds.size.height + self.offsetSpacing;
                    if ((CGRectGetMinY(panGesture.view.frame) + panGesture.view.bounds.size.height + pan.y) < boundary) {
                        panGesture.view.center = CGPointMake(panGesture.view.center.x, panGesture.view.center.y + pan.y);
                    } else {
                        panGesture.view.center = [self finalCenter];
                    }
                    self.maskView.alpha = CGRectGetMaxY(panGesture.view.frame) / boundary;
                } break;
                case ZHHPopupLayoutTypeLeft: {
                    CGFloat boundary = panGesture.view.bounds.size.width + self.offsetSpacing;
                    if ((CGRectGetMinX(panGesture.view.frame) + panGesture.view.bounds.size.width + pan.x) < boundary) {
                        panGesture.view.center = CGPointMake(panGesture.view.center.x + pan.x, panGesture.view.center.y);
                    } else {
                        panGesture.view.center = [self finalCenter];
                    }
                    self.maskView.alpha = CGRectGetMaxX(panGesture.view.frame) / boundary;
                } break;
                case ZHHPopupLayoutTypeBottom: {
                    CGFloat boundary = self.maskView.bounds.size.height - panGesture.view.bounds.size.height - self.offsetSpacing;
                    if ((panGesture.view.frame.origin.y + pan.y) > boundary) {
                        panGesture.view.center = CGPointMake(panGesture.view.center.x, panGesture.view.center.y + pan.y);
                    } else {
                        panGesture.view.center = [self finalCenter];
                    }
                    self.maskView.alpha = 1 - (CGRectGetMinY(panGesture.view.frame) - boundary) / (self.maskView.bounds.size.height - boundary);
                } break;
                case ZHHPopupLayoutTypeRight: {
                    CGFloat boundary = self.maskView.bounds.size.width - panGesture.view.bounds.size.width - self.offsetSpacing;
                    if ((CGRectGetMinX(panGesture.view.frame) + pan.x) > boundary) {
                        panGesture.view.center = CGPointMake(panGesture.view.center.x + pan.x, panGesture.view.center.y);
                    } else {
                        panGesture.view.center = [self finalCenter];
                    }
                    self.maskView.alpha = 1 - (CGRectGetMinX(panGesture.view.frame) - boundary) / (self.maskView.bounds.size.width - boundary);
                } break;
                case ZHHPopupLayoutTypeCenter: {
                    [self directionalLock:pan];
                    if (_directionalVertical) {
                        panGesture.view.center = CGPointMake(panGesture.view.center.x, panGesture.view.center.y + pan.y);
                        CGFloat boundary = self.maskView.bounds.size.height / 2 + self.offsetSpacing - panGesture.view.bounds.size.height / 2;
                        self.maskView.alpha = 1 - (CGRectGetMinY(panGesture.view.frame) - boundary) / (self.maskView.bounds.size.height - boundary);
                    } else {
                        [self directionalUnlock]; // todo...
                    }
                } break;
                default: break;
            }
            
            [panGesture setTranslation:CGPointZero inView:self.maskView];
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            
            BOOL isDismissNeeded = NO;
            switch (self.layoutType) {
                case ZHHPopupLayoutTypeTop: {
                    isDismissNeeded = CGRectGetMaxY(panGesture.view.frame) < self.maskView.bounds.size.height * self.panDismissRatio;
                } break;
                case ZHHPopupLayoutTypeLeft: {
                    isDismissNeeded = CGRectGetMaxX(panGesture.view.frame) < self.maskView.bounds.size.width * self.panDismissRatio;
                } break;
                case ZHHPopupLayoutTypeBottom: {
                    isDismissNeeded = CGRectGetMinY(panGesture.view.frame) > self.maskView.bounds.size.height * self.panDismissRatio;
                } break;
                case ZHHPopupLayoutTypeRight: {
                    isDismissNeeded = CGRectGetMinX(panGesture.view.frame) > self.maskView.bounds.size.width * self.panDismissRatio;
                } break;
                case ZHHPopupLayoutTypeCenter: {
                    if (_directionalVertical) {
                        isDismissNeeded = CGRectGetMinY(panGesture.view.frame) > self.maskView.bounds.size.height * self.panDismissRatio;
                        [self directionalUnlock];
                    }
                } break;
                default: break;
            }
            
            if (isDismissNeeded) {
                if (self.defaultDismissBlock) {
                    self.defaultDismissBlock(self);
                }
            } else {
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.maskView.alpha = 1;
                    panGesture.view.center = [self finalCenter];
                } completion:NULL];
            }
            
        } break;
        default: break;
    }
}

- (void)directionalLock:(CGPoint)translation {
    if (!_isDirectionLocked) {
        _directionalVertical = ABS(translation.x) < ABS(translation.y);
        _isDirectionLocked = YES;
    }
}

- (void)directionalUnlock {
    _isDirectionLocked = NO;
}

- (void)setKeyboardChangeFollowed:(BOOL)keyboardChangeFollowed {
    if (keyboardChangeFollowed) {
        _keyboardChangeFollowed = keyboardChangeFollowed;
        [self bindKeyboardNotifications];
    }
}

- (void)bindKeyboardNotifications {
    if (self.keyboardChangeFollowed) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)unbindKeyboardNotifications {
    if (self.keyboardChangeFollowed) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    _isKeyboardVisible = NO;
    if (_isPresenting) {
        NSDictionary *u = notif.userInfo;
        UIViewAnimationOptions options = [u[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
        NSTimeInterval duration = [u[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.contentView.center = [self finalCenter];
        } completion:NULL];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notif {
    NSDictionary *u = notif.userInfo;
    CGRect frameBegin = [u[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frameEnd = [u[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (frameBegin.size.height > 0 && ABS(CGRectGetMinY(frameBegin) - CGRectGetMinY(frameEnd))) {
        CGRect frameConverted = [self.maskView convertRect:frameEnd fromView:nil];
        CGFloat keyboardHeightConverted = self.maskView.bounds.size.height - CGRectGetMinY(frameConverted);
        if (keyboardHeightConverted > 0) {
            _isKeyboardVisible = YES;
        
            CGFloat originY = CGRectGetMaxY(self.contentView.frame) - CGRectGetMinY(frameConverted);
            CGPoint newCenter = CGPointMake(self.contentView.center.x, self.contentView.center.y - originY - self.keyboardOffsetSpacing);
            NSTimeInterval duration = [u[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            UIViewAnimationOptions options = [u[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
            [UIView animateWithDuration:duration delay:0 options:options animations:^{
                self.contentView.center = newCenter;
            } completion:NULL];
        }
    }
}

#pragma mark - 懒加载
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        _tapGesture.delegate = self;
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (void)dealloc {
    [self unbindKeyboardNotifications];
}

@end


static void *UIViewZHHPopupControllersKey = &UIViewZHHPopupControllersKey;

@implementation UIView (ZHHPopupController)

- (void)zhh_presentPopupController:(ZHHPopupController *)popupController completion:(void (^)(void))completion {
    return [self zhh_presentPopupController:popupController duration:0.25 completion:completion];
}

- (void)zhh_presentPopupController:(ZHHPopupController *)popupController duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    return [self zhh_presentPopupController:popupController duration:duration bounced:NO completion:completion];
}

- (void)zhh_presentPopupController:(ZHHPopupController *)popupController duration:(NSTimeInterval)duration bounced:(BOOL)isBounced completion:(void (^)(void))completion {
    return [self zhh_presentPopupController:popupController duration:duration delay:0 options:UIViewAnimationOptionCurveLinear bounced:isBounced completion:completion];
}

- (void)zhh_presentPopupController:(ZHHPopupController *)popupController duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options bounced:(BOOL)isBounced completion:(void (^)(void))completion {
    NSMutableArray<ZHHPopupController *> *_popupControllers = objc_getAssociatedObject(self, UIViewZHHPopupControllersKey);
    if (!_popupControllers) {
        _popupControllers = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, UIViewZHHPopupControllersKey, _popupControllers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    popupController.proxyView = self;
    
    if (_popupControllers.count > 0) {
        [_popupControllers sortUsingComparator:^NSComparisonResult(ZHHPopupController *obj1, ZHHPopupController *obj2) {
            return obj1.windowLevel < obj2.windowLevel;
        }];
        
        if (popupController.windowLevel >= _popupControllers.lastObject.windowLevel) {
            [popupController addSubview];
        } else {
            for (ZHHPopupController *element in _popupControllers) {
                if (popupController.windowLevel < element.windowLevel) {
                    [popupController addSubviewBelow:element.maskView];
                    break;
                }
            }
        }
    } else {
        [popupController addSubview];
    }
    
    if (![_popupControllers containsObject:popupController]) {
        [_popupControllers addObject:popupController];
    }
    [popupController presentDuration:duration delay:delay options:options bounced:isBounced completion:completion];
}

- (void)zhhdissmissPopupController:(ZHHPopupController *)popupController completion:(void (^)(void))completion {
    return [self zhhdissmissPopupController:popupController duration:0.25 completion:completion];
}

- (void)zhhdissmissPopupController:(ZHHPopupController *)popupController duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    return [self zhhdissmissPopupController:popupController duration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut completion:completion];
}

- (void)zhhdissmissPopupController:(ZHHPopupController *)popupController duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
    NSMutableArray<ZHHPopupController *> *_popupControllers = objc_getAssociatedObject(self, UIViewZHHPopupControllersKey);
    if (_popupControllers.count > 0) {
        [popupController dismissDuration:duration delay:delay options:options completion:completion];
        [_popupControllers removeObject:popupController];
        if (_popupControllers.count < 1) {
            objc_setAssociatedObject(self, UIViewZHHPopupControllersKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

@end


@implementation ZHHPopupController (Convenient)

- (UIWindow *)keyWindow {
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    if (window) return window;
    if (@available(iOS 13.0, *)) {
        return UIApplication.sharedApplication.windows.firstObject;
    } else {
        return UIApplication.sharedApplication.keyWindow;
    }
}

- (void)show {
    return [self.keyWindow zhh_presentPopupController:self completion:NULL];
}

- (void)showInView:(UIView *)view completion:(void (^)(void))completion {
    return [view zhh_presentPopupController:self completion:completion];
}

- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    return [view zhh_presentPopupController:self duration:duration completion:completion];
}

- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration bounced:(BOOL)bounced completion:(void (^)(void))completion {
    return [view zhh_presentPopupController:self duration:duration bounced:bounced completion:completion];
}

- (void)showInView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options bounced:(BOOL)bounced completion:(void (^)(void))completion {
    return [view zhh_presentPopupController:self duration:duration delay:delay options:options bounced:bounced completion:completion];
}

- (void)dismiss {
    return [self.proxyView zhhdissmissPopupController:self completion:NULL];
}

- (void)dismissWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    return [self.proxyView zhhdissmissPopupController:self completion:completion];
}

- (void)dismissWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
    return [self.proxyView zhhdissmissPopupController:self duration:duration delay:delay options:options completion:completion];
}

@end
