//
//  ZHHViewController.m
//  ZHHPopupController
//
//  Created by 宁小陌 on 09/08/2022.
//  Copyright (c) 2022 宁小陌y. All rights reserved.
//

#import "ZHHViewController.h"

@interface ZHHViewController ()

@end

@implementation ZHHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColor.whiteColor;
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    messageLabel.text = @"界面效果查看ZHHAnneKitExample";
    [self.view addSubview:messageLabel];
    self.title = @"TableViewCell折叠";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
