//
//  UIViewController+StatusBarStyle.h
//  ZHHPopupController_Example
//
//  Created by 宁小陌 on 2022/9/21.
//  Copyright © 2022 ningxiaomo0516. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UINavigationController (StatusBarStyle)

@end

@interface UIViewController (StatusBarStyle)
@property (nonatomic, assign) BOOL zhh_statusBarHidden;
@property (nonatomic, assign) UIStatusBarStyle zhh_statusBarStyle;
- (void)zhh_statusBarRestoreDefaults;
@end

NS_ASSUME_NONNULL_END
