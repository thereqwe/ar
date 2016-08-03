//
//  uploadPhotoViewController.m
//  helloarvideo
//
//  Created by Yue Shen on 16/8/1.
//  Copyright © 2016年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

#import "uploadPhotoViewController.h"
#import "HTTPService.h"
@implementation uploadPhotoViewController
{
    UIButton *ui_btn_start_get_position;
    UIButton *ui_btn_take_photo;
    UILabel *ui_lb_lat_lon;
    UIImagePickerController *imagePickerController;
}

- (void)setupUI
{
    ui_btn_start_get_position = [UIButton new];
    ui_btn_start_get_position.frame= (CGRect){100,100,100,44};
    [ui_btn_start_get_position setTitle:@"定位开始" forState:UIControlStateNormal];
    [ui_btn_start_get_position setBackgroundColor:[UIColor redColor]];
    [ui_btn_start_get_position addTarget:self action:@selector(startSerialLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ui_btn_start_get_position];
    
    ui_btn_take_photo = [UIButton new];
    ui_btn_take_photo.frame= (CGRect){100,200,150,44};
    [ui_btn_take_photo setTitle:@"拍照采集数据" forState:UIControlStateNormal];
    [ui_btn_take_photo setBackgroundColor:[UIColor blueColor]];
    [ui_btn_take_photo addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ui_btn_take_photo];
    
    ui_lb_lat_lon = [UILabel new];
    ui_lb_lat_lon.frame = (CGRect){0,300,300,20};
    [self.view addSubview:ui_lb_lat_lon];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [AMapServices sharedServices].apiKey = @"e590b8299c0475aaff1e3d58e3c22964";
    [self configLocationManager];
}

#pragma mark - get location
- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
}

- (void)startSerialLocation
{
    //开始定位
    [self.locationManager startUpdatingLocation];
}

- (void)stopSerialLocation
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    //定位错误
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    //定位结果
    NSLog(@"location:{维度:%f; 经度:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    ui_lb_lat_lon.text = [NSString stringWithFormat:@"{维度:%f; 经度:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy];
}

#pragma mark - take photo
- (void)takePhoto
{
    imagePickerController = [[UIImagePickerController alloc]init];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.sourceType = sourcheType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取照片的原图
    UIImage* original = [info objectForKey:UIImagePickerControllerOriginalImage];
    //获取图片裁剪的图
    UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
    NSLog(@"%@,%@",original,edit);
    [picker dismissViewControllerAnimated:YES completion:nil];
    

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]init];
    manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", @"text/javascript", @"text/plain", nil];
    AFHTTPRequestOperation *op = [manager POST:[NSString stringWithFormat:@"%@/%@",@"http://139.129.47.4:8080",@"gpspic/insert"] parameters:@{@"guid":@"9c553730ef5b6c8c542bfd31b5e25b69",@"_os_":@"iPhone",@"_product_":@"tudou"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(edit, 1);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = responseObject  ;
        // NSLog(@"%@",[[NSString alloc]initWithData:data encoding:kCFStringEncodingUTF8]);
        if([responseObject[@"errCode"] isEqualToString:@"000"]){
            NSLog(@"get the response from server");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err %@",error);
    }];
    
}
@end
