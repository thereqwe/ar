/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#import "ViewController.h"
#import "HTTPService.h"
#import "UIImageView+WebCache.h"
@interface ViewController ()
{
    NSString *path;
    UIView *ui_view_now_saved_img;
    CGFloat old_longitude;
    CGFloat old_latitude;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    self.glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
    [self.glView setOrientation:self.interfaceOrientation];
    
    [AMapServices sharedServices].apiKey = @"e590b8299c0475aaff1e3d58e3c22964";
    [self configLocationManager];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshImgs) name:@"new_data" object:nil];
    
    ui_view_now_saved_img = [UIView new];
    ui_view_now_saved_img.frame = (CGRect){0,80,44,450};
    ui_view_now_saved_img.backgroundColor = RED;
    [self.view addSubview:ui_view_now_saved_img];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView start];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView stop];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.glView setOrientation:toInterfaceOrientation];
}


#pragma mark - get location
- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    [self startSerialLocation];
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

/**
 *  刷新图片
 */
- (void)refreshImgs
{
    if(old_longitude==0){
        return;
    }
    [self performSelector:@selector(getImgsWithLocation:) withObject:[[CLLocation alloc]initWithLatitude:old_latitude longitude:old_longitude] afterDelay:1 inModes:nil];
    [self getImgsWithLocation:[[CLLocation alloc]initWithLatitude:old_latitude longitude:old_longitude]];
}

/**
 *  根据地址获取识别图
 *
 *  @param location <#location description#>
 */
- (void)getImgsWithLocation:(CLLocation *)location
{
    NSDictionary *dictParam = @{@"guid":@"9c553730ef5b6c8c542bfd31b5e25b69",@"_os_":@"iPhone",@"_product_":@"tudou",@"latitude":@(location.coordinate.latitude),@"longitude":@(location.coordinate.longitude)};
    [[HTTPService Instance] mobileGET:@"http://139.129.47.4:8080" path:@"/gpspic/query" parameters:[dictParam mutableCopy]  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *views = [ui_view_now_saved_img subviews];
            for(UIView* view in views){
                [view removeFromSuperview];
            }
            for (int i=0;i<[responseObject[@"data"] count];i++) {
                NSString *location = [NSString stringWithFormat:@"%@/%d.jpg",path,i];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://139.129.47.4:8080",responseObject[@"data"][i][@"pic"]]]];
                BOOL rst = [imageData writeToFile:location atomically:YES];
                UIImageView *img = [UIImageView new];
                img.frame = (CGRect){0,i*45,44,45};
                [img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://139.129.47.4:8080",responseObject[@"data"][i][@"pic"]]]];
                [ui_view_now_saved_img addSubview:img];
                NSLog(@"123");
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                if([responseObject[@"data"] count]>0){
                    [self.glView stop];
                    [self.glView start];
                }
            });
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    if(fabsl(location.coordinate.latitude-old_latitude)<0.0001&&fabsl(old_longitude-location.coordinate.longitude)<0.0001){
        return;
    }
    //定位结果
    NSLog(@"location:{维度:%f; 经度:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    old_latitude = location.coordinate.latitude;
    old_longitude = location.coordinate.longitude;
    [self getImgsWithLocation:location];
}

#pragma mark - file path
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
    
}
@end
