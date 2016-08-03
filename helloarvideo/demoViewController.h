//
//  demoViewController.h
//  helloarvideo
//
//  Created by Yue Shen on 16/7/28.
//  Copyright © 2016年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,phase)
{
    love,
    hate
};

@interface demoViewController : UIViewController
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *age;
@property (nonatomic,assign) phase status;
@end
