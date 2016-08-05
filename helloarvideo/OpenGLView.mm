/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#import "OpenGLView.h"
#import "AppDelegate.h"

#include <iostream>
#include "ar.hpp"
#include "renderer.hpp"

/*
* Steps to create the key for this sample:
*  1. login www.easyar.com
*  2. create app with
*      Name: HelloARVideo
*      Bundle ID: cn.easyar.samples.helloarvideo
*  3. find the created item in the list and show key
*  4. set key string bellow
*/
NSString* key = @"jBTf6DyQex8YgSQvVRplOPb6tqY9Sx18Elj8un7y4JY7gyt0w4GmhVHX3Ofn9o4tIk046mPRPwSYo5rMJ7U4U8vm9bSRbWAAoAlZ844c2177cc06f353157c22b4e1e5f18cz7hhvNwUo7N3J776uMHtNDdOlbhP95jzehMxmP3js3zpzXwTYh2ksL0r1JYOcKXKpwn3";

namespace EasyAR {
namespace samples {

class HelloARVideo : public AR
{
public:
    HelloARVideo();
    ~HelloARVideo();
    virtual void initGL();
    virtual void resizeGL(int width, int height);
    virtual void render();
    virtual bool clear();
private:
    Vec2I view_size;
    VideoRenderer* renderer[3];
    int tracked_target;
    int active_target;
    int texid[3];
    ARVideo* video;
    VideoRenderer* video_renderer;
};

HelloARVideo::HelloARVideo()
{
    view_size[0] = -1;
    tracked_target = 0;
    active_target = 0;
    for(int i = 0; i < 3; ++i) {
        texid[i] = 0;
        renderer[i] = new VideoRenderer;
    }
    video = NULL;
    video_renderer = NULL;
}

HelloARVideo::~HelloARVideo()
{
    for(int i = 0; i < 3; ++i) {
        delete renderer[i];
    }
}

void HelloARVideo::initGL()
{
    augmenter_ = Augmenter();
    for(int i = 0; i < 3; ++i) {
        renderer[i]->init();
        texid[i] = renderer[i]->texId();
    }
}

void HelloARVideo::resizeGL(int width, int height)
{
    view_size = Vec2I(width, height);
}

void HelloARVideo::render()
{
    glClearColor(0.f, 0.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    Frame frame = augmenter_.newFrame();
    if(view_size[0] > 0){
        int width = view_size[0];
        int height = view_size[1];
        Vec2I size = Vec2I(1, 1);
        if (camera_ && camera_.isOpened())
            size = camera_.size();
        if(portrait_)
            std::swap(size[0], size[1]);
        float scaleRatio = std::max((float)width / (float)size[0], (float)height / (float)size[1]);
        Vec2I viewport_size = Vec2I((int)(size[0] * scaleRatio), (int)(size[1] * scaleRatio));
        if(portrait_)
            viewport_ = Vec4I(0, height - viewport_size[1], viewport_size[0], viewport_size[1]);
        else
            viewport_ = Vec4I(0, width - height, viewport_size[0], viewport_size[1]);
        if(camera_ && camera_.isOpened())
            view_size[0] = -1;
    }
    augmenter_.setViewPort(viewport_);
    augmenter_.drawVideoBackground();
    glViewport(viewport_[0], viewport_[1], viewport_[2], viewport_[3]);

    AugmentedTarget::Status status = frame.targets()[0].status();
    if(status == AugmentedTarget::kTargetStatusTracked){
        int id = frame.targets()[0].target().id();
        if(active_target && active_target != id) {
            video->onLost();
            delete video;
            video = NULL;
            tracked_target = 0;
            active_target = 0;
        }
        if (!tracked_target) {
            if (video == NULL) {
                if(frame.targets()[0].target().name() == std::string("argame") && texid[0]) {
                    video = new ARVideo;
                    video->openVideoFile("video.mp4", texid[0]);
                    video_renderer = renderer[0];
                }
                else if(frame.targets()[0].target().name() == std::string("namecard") && texid[1]) {
                    video = new ARVideo;
                    video->openTransparentVideoFile("transparentvideo.mp4", texid[1]);
                    video_renderer = renderer[1];
                }
                else if(frame.targets()[0].target().name() == std::string("idback") && texid[2]) {
                    video = new ARVideo;
                    video->openStreamingVideo("http://7xl1ve.com5.z0.glb.clouddn.com/sdkvideo/EasyARSDKShow201520.mp4", texid[2]);
                    video_renderer = renderer[2];
                } else if(frame.targets()[0].target().name() == std::string("rrt") && texid[2]) {
                    video = new ARVideo;
                    video->openStreamingVideo("http://7xl1ve.com5.z0.glb.clouddn.com/sdkvideo/EasyARSDKShow201520.mp4", texid[2]);
                    video_renderer = renderer[2];
                }else  {
                    NSLog(@"123"); //msldljjehhtjh
                    video = new ARVideo;
                    video->openStreamingVideo("http://45.124.125.92/v.cctv.com/flash/mp4video6/TMS/2011/01/05/cf752b1c12ce452b3040cab2f90bc265_h264818000nero_aac32-1.mp4?wsiphost=local", texid[2]);
                    video_renderer = renderer[2];
                }
            }
            if (video) {
                video->onFound();
                tracked_target = id;
                active_target = id;
            }
        }
        Matrix44F projectionMatrix = getProjectionGL(camera_.cameraCalibration(), 0.2f, 500.f);
        Matrix44F cameraview = getPoseGL(frame.targets()[0].pose());
        ImageTarget target = frame.targets()[0].target().cast_dynamic<ImageTarget>();
        if(tracked_target) {
            video->update();
            video_renderer->render(projectionMatrix, cameraview, target.size());
        }
    } else {
        if (tracked_target) {
            video->onLost();
            tracked_target = 0;
        }
    }
}

bool HelloARVideo::clear()
{
    AR::clear();
    if(video){
        delete video;
        video = NULL;
        tracked_target = 0;
        active_target = 0;
    }
    return true;
}

}
}
EasyAR::samples::HelloARVideo ar;

@interface OpenGLView ()
{
}

@property(nonatomic, strong) CADisplayLink * displayLink;

- (void)displayLinkCallback:(CADisplayLink*)displayLink;

@end

@implementation OpenGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = frame.size.height = MAX(frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if(self){
        [self setupGL];

        EasyAR::initialize([key UTF8String]);
        ar.initGL();
        [self setName];
    }

    return self;
}

- (void)dealloc
{
    ar.clear();
}

- (void)setupGL
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;

    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
    if (![EAGLContext setCurrentContext:_context])
        NSLog(@"Failed to set current OpenGL context");

    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);

    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);

    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);

    GLuint depthRenderBuffer;
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
}

- (void)start{
    ar.initCamera();
  //  ar.loadAllFromJsonFile("targets.json");
//    ar.loadFromImage("namecard.jpg");
//     ar.loadFromImage("IMG_0421.jpg");
    ar.loadFromImage("idback.jpg");
    ar.loadFromImage("rrt.jpg");
    
    ///var/mobile/Containers/Data/Application/55FE7ADA-69A3-4FE3-A983-A9C3F80AF961/Documents/imagei
    ar.loadFromImage([[self getIdentificationImages:@"0"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"1"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"2"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"3"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"4"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"5"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"6"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"7"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"8"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"9"] UTF8String]);
    ar.loadFromImage([[self getIdentificationImages:@"76"] UTF8String]);
    ar.start();
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(NSString*)getIdentificationImages:(NSString*)idx
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"image"];
    NSString *location = [NSString stringWithFormat:@"%@/%@.jpg",path,idx];
    return location;
}

- (void)stop
{
    ar.clear();
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    if (!((AppDelegate*)[[UIApplication sharedApplication]delegate]).active)
        return;
    ar.render();

    (void)displayLink;
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = FALSE;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            isPortrait = TRUE;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = FALSE;
            break;
        default:
            break;
    }
    ar.setPortrait(isPortrait);
    ar.resizeGL(frame.size.width, frame.size.height);
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            EasyAR::setRotationIOS(270);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            EasyAR::setRotationIOS(90);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            EasyAR::setRotationIOS(180);
            break;
        case UIInterfaceOrientationLandscapeRight:
            EasyAR::setRotationIOS(0);
            break;
        default:
            break;
    }
}

- (void)setName
{
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.frame = self.bounds;
    [self.layer addSublayer:emitter];
    
    //configure emitter
    emitter.renderMode = kCAEmitterLayerAdditive;
    emitter.emitterPosition = CGPointMake(emitter.frame.size.width / 2.0, emitter.frame.size.height / 2.0);
    
    //create a particle template
    CAEmitterCell *cell = [[CAEmitterCell alloc] init];
    cell.contents = (__bridge id)[UIImage imageNamed:@"Spark.png"].CGImage;
    cell.birthRate = 150;
    cell.lifetime = 5.0;
    cell.color = [UIColor colorWithRed:1 green:0.5 blue:0.1 alpha:1.0].CGColor;
    cell.alphaSpeed = -0.4;
    cell.velocity = 50;
    cell.velocityRange = 50;
    cell.emissionRange = M_PI * 2.0;
    
    //add particle template to emitter
    emitter.emitterCells = @[cell];
}
@end
