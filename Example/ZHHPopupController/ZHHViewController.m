//
//  ZHHViewController.m
//  ZHHPopupController
//
//  Created by 宁小陌 on 09/08/2022.
//  Copyright (c) 2022 宁小陌y. All rights reserved.
//

#import "ZHHViewController.h"
#import "UIViewController+StatusBarStyle.h"
#import "UIViewController+zhStatusBarStyle.h"

@interface ZHHViewController ()
@property (nonatomic, assign) BOOL isLight;
@end

@implementation ZHHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.zh_statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = UIColor.whiteColor;
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = @"界面效果查看ZHHAnneKitExample";
    [self.view addSubview:messageLabel];
    self.title = @"TableViewCell折叠";

    UIButton *whiteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [whiteBtn setTitleColor:UIColor.purpleColor forState:UIControlStateNormal];
    [whiteBtn setTitle:@"设置状态栏为白色" forState:UIControlStateNormal];
    [self.view addSubview:whiteBtn];
    UIButton *blackBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [blackBtn setTitleColor:UIColor.purpleColor forState:UIControlStateNormal];
    [blackBtn setTitle:@"设置状态栏为黑色" forState:UIControlStateNormal];
    [self.view addSubview:blackBtn];
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetBtn setTitleColor:UIColor.purpleColor forState:UIControlStateNormal];
    [resetBtn setTitle:@"重置状态栏颜色" forState:UIControlStateNormal];
    [self.view addSubview:resetBtn];
    
    blackBtn.frame = CGRectMake(0, 0, 300, 50);
    blackBtn.center = self.view.center;
    
    blackBtn.frame = CGRectMake(CGRectGetMinX(blackBtn.frame), CGRectGetMinY(blackBtn.frame) - 50, 300, 50);
    whiteBtn.frame = CGRectMake(CGRectGetMinX(blackBtn.frame), CGRectGetMinY(blackBtn.frame) - 50, 300, 50);
    resetBtn.frame = CGRectMake(CGRectGetMinX(blackBtn.frame), CGRectGetMinY(blackBtn.frame) + 100, 300, 50);
    
    [whiteBtn addTarget:self action:@selector(whiteBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [blackBtn addTarget:self action:@selector(blackBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [resetBtn addTarget:self action:@selector(resetBtnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)whiteBtnAction{
//    self.zhh_statusBarStyle = UIStatusBarStyleLightContent;
    self.isLight = YES;
}

- (void)blackBtnAction{
    self.isLight = NO;
//    self.zhh_statusBarStyle = UIStatusBarStyleDarkContent;
}

- (void)resetBtnAction{
    
}

- (void)setIsLight:(BOOL)isLight {
    _isLight = isLight;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return self.isLight ? UIStatusBarStyleDarkContent : UIStatusBarStyleLightContent;
    } else {
        return self.isLight ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
    }
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
