//
//  UIViewController+StatusBarStyle.m
//  ZHHPopupController_Example
//
//  Created by 宁小陌 on 2022/9/21.
//  Copyright © 2022 ningxiaomo0516. All rights reserved.
//

#import "UIViewController+StatusBarStyle.h"
#import <objc/runtime.h>

@implementation UINavigationController (StatusBarStyle)

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end

@implementation UIViewController (StatusBarStyle)
- (BOOL)zhh_statusBarHidden {
    id value = objc_getAssociatedObject(self, _cmd);
    return [value boolValue];
}

- (void)setZhh_statusBarHidden:(BOOL)zhh_statusBarHidden {
    objc_setAssociatedObject(self, @selector(zhh_statusBarHidden), @(zhh_statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self statusBarAppearanceCheck]) {
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarHidden:zhh_statusBarHidden];
#pragma clang diagnostic pop
    }
}

- (UIStatusBarStyle)zhh_statusBarStyle {
    id value = objc_getAssociatedObject(self, _cmd);
    return [value integerValue];
}

- (void)setZhh_statusBarStyle:(UIStatusBarStyle)zhh_statusBarStyle {
    objc_setAssociatedObject(self, @selector(zhh_statusBarStyle), @(zhh_statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self statusBarAppearanceCheck]) {
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarStyle:zhh_statusBarStyle];
#pragma clang diagnostic pop
    }
}

- (void)zhh_statusBarRestoreDefaults {
    if ([self statusBarAppearanceCheck]) {
        self.zhh_statusBarStyle = UIStatusBarStyleDefault;
        self.zhh_statusBarHidden = NO;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
#pragma clang diagnostic pop
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.zhh_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.zhh_statusBarStyle;
}

- (BOOL)statusBarAppearanceCheck {
    NSDictionary *appInfo = [NSBundle mainBundle].infoDictionary;
    if ([appInfo.allKeys containsObject:@"UIViewControllerBasedStatusBarAppearance"]) {
        return [appInfo[@"UIViewControllerBasedStatusBarAppearance"] integerValue];
    }
    return YES;
}

@end
