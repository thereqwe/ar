//
//  userTakePhotoViewController.m
//  helloarvideo
//
//  Created by Yue Shen on 16/7/21.
//  Copyright © 2016年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

//#import "userTakePhotoViewController.h"
#include "easyar/utility.hpp"
#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>

@interface userTakePhotoViewController : UIViewController

@end
@implementation userTakePhotoViewController
{
    UIButton *ui_btn_take_photo;
    UITextField *ui_tf_photo_tag;
    UIImagePickerController *imagePickerController;
    NSString *path;
    UIImageView *ui_img_saved_pic;
}

- (void)setupData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    path = [documentsDirectory stringByAppendingPathComponent:@"image"];
        NSFileManager *fileManager=[NSFileManager defaultManager];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"FileDir is exists.");
    }
    [self seePath];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
    [self setName];
}

- (void)setupUI
{
    ui_btn_take_photo = [UIButton new];
    ui_btn_take_photo.frame = {100, 100, 150, 44};
    [ui_btn_take_photo addTarget:self action:@selector(chooseImg) forControlEvents:UIControlEventTouchUpInside];
    [ui_btn_take_photo setTitle:@"拍图入本地库" forState:UIControlStateNormal];
    [ui_btn_take_photo setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [self.view addSubview:ui_btn_take_photo];
    
    ui_tf_photo_tag = [UITextField new];
    ui_tf_photo_tag.text = @"76";
    ui_tf_photo_tag.placeholder = @"图片名称";
    ui_tf_photo_tag.borderStyle = UITextBorderStyleBezel;
    ui_tf_photo_tag.frame = CGRectMake(0, 150, 300, 44);
    [self.view addSubview:ui_tf_photo_tag];
    
    ui_img_saved_pic = [UIImageView new];
    [self.view addSubview:ui_img_saved_pic];
    ui_img_saved_pic.frame = CGRectMake(80, 180, 250, 250);
    NSData *data= [NSData dataWithContentsOfFile:[self getIdentificationImages]];
    UIImage *img = [[UIImage alloc]initWithData:data];
    [ui_img_saved_pic setImage:img];
}

-(void)chooseImg
{
    imagePickerController = [[UIImagePickerController alloc]init];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.sourceType = sourcheType;
    imagePickerController.delegate = (id<UIImagePickerControllerDelegate>)self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *fileName = [ui_tf_photo_tag.text stringByAppendingString:@".jpg"];
    NSString *location = [NSString stringWithFormat:@"%@/%@",path,fileName];
    //获取照片的原图
    UIImage* original = [info objectForKey:UIImagePickerControllerOriginalImage];
    //获取图片裁剪的图
    UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(edit, 1);
    BOOL rst = [imageData writeToFile:location atomically:YES];
    NSLog(@"---->location :%@<---",location);
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:location]];
    UIImageView *iv = [[UIImageView alloc]initWithImage:image];
    iv.frame = CGRectMake(200, 200, 50, 50);
    [self.view addSubview:iv];
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        
    }];

    [self seePath];
}

- (void)seePath
{
    NSDirectoryEnumerator *myDirectoryEnumerator;
    
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:documentsDirectory];
    
    
    
    NSString *docPath;
    
    docPath = path;   //得到文件的路径
    
    NSLog(@"%@", docPath);
    
    NSMutableArray* filePathArray = [[NSMutableArray alloc]init];   //用来存目录名字的数组
    
    NSFileManager* localFileManager=[[NSFileManager alloc] init];  //用于获取文件列表
    
    
    NSString *file;
    
    while((file=[myDirectoryEnumerator nextObject]))     //遍历当前目录
        
    {
        
       if([[file pathExtension] isEqualToString:@"jpg"])   //取得后缀名这.png的文件名
            
       {
            
            [filePathArray addObject:[docPath stringByAppendingPathComponent:file]]; //存到数组
            
            NSLog(@"--->%@",file);
            
//          /  NSLog(@"%@",filePathArray);
        
        }
    }
}



-(NSString*)getIdentificationImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"image"];
    NSString *location = [NSString stringWithFormat:@"%@/%@",path,@"76.jpg"];
    CGPoint point = {123,234};
    CGSize size = {22,34};
    CGRect frame = {12,34,34,34};
    return location;
}


- (void)setName
{
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.frame = self.view.bounds;
    [self.view.layer addSublayer:emitter];
    
    //configure emitter
    emitter.renderMode = kCAEmitterLayerUnordered;//kCAEmitterLayerAdditive;
    emitter.emitterPosition = CGPointMake(emitter.frame.size.width / 2, emitter.frame.size.height-150);
    emitter.emitterSize = CGSizeMake(50, 50);
    
    //create a particle template
    CAEmitterCell *cell = [[CAEmitterCell alloc] init];
    cell.contents = (__bridge id)[UIImage imageNamed:@"heart-icon"].CGImage;

    cell.birthRate = 2;
    cell.scale = 0.1;
    cell.lifetime = 15.0;
    cell.color = [UIColor colorWithRed:1 green:0.5 blue:0.1 alpha:1.0].CGColor;
    cell.alphaSpeed = -0.1;
    cell.velocity = 50;
    cell.emissionLongitude = - M_PI_2;
      cell.yAcceleration = 0.5;
    cell.velocityRange = 50;
    cell.emissionRange =   0.09 * M_PI;
    //子旋转角度范围
    cell.spinRange = 0.01 * M_PI;
    
    //ls get the last path of emitter
    //add particle template to emitter
    emitter.preservesDepth = YES;
    emitter.emitterCells = @[cell];

}

+ (instancetype)sharedInstance
{
    static dispatch_once_t __singletonToken;
    static id __singleton__;
    dispatch_once( &__singletonToken, ^{
        __singleton__ = [[self alloc] init];} );
    return __singleton__;
}
@end
