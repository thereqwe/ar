//
//  demoViewController.m
//  helloarvideo
//
//  Created by Yue Shen on 16/7/28.
//  Copyright © 2016年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

#import "demoViewController.h"
#import <objc/runtime.h>
@implementation demoViewController

- (void)viewDidLoad
{
    
}

- (void)setupUI
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    UIButton *btn = [UIButton new];
    
    [btn setFrame:CGRectMake(0, 0, 150, 120)];
    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchDown];
    btn.layer.sublayers = nil;
    btn.accessibilityElements = nil;
    [self.view addSubview:btn];
    [self.view setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:[UIImageView new]];
    objc_setAssociatedObject(self, @"pro", nil, OBJC_ASSOCIATION_RETAIN);

}
@end
