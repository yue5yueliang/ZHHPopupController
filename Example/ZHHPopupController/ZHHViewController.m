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
#import <ZHHPopupController/ZHHPopupController.h>

@interface ZHHViewController ()
@property (nonatomic, strong) ZHHPopupController *popController;
@end

@implementation ZHHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = UIColor.whiteColor;
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = @"界面效果查看ZHHAnneKitExample";
    [self.view addSubview:messageLabel];

    UIButton *lookBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [lookBtn setTitleColor:UIColor.purpleColor forState:UIControlStateNormal];
    [lookBtn setTitle:@"点我查看" forState:UIControlStateNormal];
    [self.view addSubview:lookBtn];
    
    lookBtn.frame = CGRectMake(0, 0, 300, 50);
    lookBtn.center = self.view.center;
    messageLabel.frame = CGRectMake(0, CGRectGetMidY(lookBtn.frame)-60, self.view.frame.size.width, 30);
    
    [lookBtn addTarget:self action:@selector(lookBtnAction) forControlEvents:UIControlEventTouchUpInside];
}


- (void)lookBtnAction{
    UIView *popupView = [UIView new];
    popupView.backgroundColor = UIColor.whiteColor;
    popupView.frame = CGRectMake(0, 0, self.view.frame.size.width, 400);
    ZHHPopupController *popController = [[ZHHPopupController alloc] initWithView:popupView size:popupView.bounds.size];
    popController.maskType = ZHHPopupMaskTypeBlackOpacity;
    popController.layoutType = ZHHPopupLayoutTypeLeft;
    popController.presentationStyle = ZHHPopupSlideStyleFromLeft;

    popController.panGestureEnabled = YES;
    [popController showInView:[UIApplication sharedApplication].keyWindow completion:^{

    }];
    self.popController = popController;
}

@end
