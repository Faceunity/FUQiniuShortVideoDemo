//
//  FUCamera.m
//  FULiveDemo
//
//  Created by liuyang on 2016/12/26.
//  Copyright © 2016年 liuyang. All rights reserved.
//

#import "FUCamera.h"
#import <UIKit/UIKit.h>
#import "FURecordEncoder.h"
#import <SVProgressHUD/SVProgressHUD.h>



typedef enum : NSUInteger {
    CommonMode,
    PhotoTakeMode,
    VideoRecordMode,
    VideoRecordEndMode,
} RunMode;

typedef void(^FUCameraRecordVidepCompleted)(NSString *videoPath);

@interface FUCamera()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    RunMode runMode;
    BOOL videoHDREnabled;
    
    void *cameraQueueKey;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput       *backCameraInput;//后置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *frontCameraInput;//前置摄像头输入
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) AVCaptureDevice *camera;
@property (copy  , nonatomic) dispatch_queue_t  cameraQueue;//视频采集的队列

@property (assign, nonatomic) AVCaptureDevicePosition cameraPosition;

@property (strong, nonatomic) FURecordEncoder          *recordEncoder;//录制编码

@property (nonatomic, strong) AVCaptureDeviceInput      *audioMicInput;//麦克风输入
@property (nonatomic, strong) AVCaptureAudioDataOutput  *audioOutput;//音频输出
@property (copy, nonatomic) FUCameraRecordVidepCompleted recordVidepCompleted;

@property (nonatomic) FUCameraFocusModel cameraFocusModel;
@end

@implementation FUCamera

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition captureFormat:(int)captureFormat
{
    if (self = [super init]) {
        self.cameraPosition = cameraPosition;
        self.captureFormat = captureFormat;
        _sessionPreset = AVCaptureSessionPreset1280x720;
        videoHDREnabled = YES;
    }
    return self;
}

- (void)startCapture{
    [self cameraQueueSync:^{
        NSLog(@"Frame debug: self.captureCamera startCapture");
        self->_cameraFocusModel = FUCameraFocusModelAutoFace;
        
        if (![self.captureSession isRunning]) {
            //        [self addAudio];
            [self.captureSession startRunning];
            /* 设置曝光中点 */
            [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:CGPointMake(0.5, 0.5) monitorSubjectAreaChange:YES];
            NSLog(@"视频采集开启");
        }else{
            NSLog(@"[self.captureSession isRunning] %d",[self.captureSession isRunning]);
        }
    }];
}

- (void)stopCapture {
    [self cameraQueueSync:^{
        //    [self removeAudio];
        NSLog(@"Frame debug: self.captureCamera stopCapture");
        if ([self.captureSession isRunning]) {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            [self.captureSession stopRunning];
            NSLog(@"stopRunning stopCapture used time %f",CFAbsoluteTimeGetCurrent() - startTime);
            
            NSLog(@"视频采集关闭");
        }
    }];
}

- (void)addAudio{
    [self cameraQueueSync:^{
        if ([self->_captureSession canAddOutput:self.audioOutput]) {
            [self->_captureSession addOutput:self.audioOutput];
        }
    }];
}

- (void)removeAudio {
    [self cameraQueueSync:^{
        [self->_captureSession removeOutput:self.audioOutput];
    }];
}

- (AVCaptureSession *)captureSession
{
    [self cameraQueueSync:^{
        if (!self->_captureSession) {
            self->_captureSession = [[AVCaptureSession alloc] init];

            
            AVCaptureDeviceInput *deviceInput = self.isFrontCamera ? self.frontCameraInput:self.backCameraInput;
            
            [_captureSession beginConfiguration]; // the session to which the receiver's AVCaptureDeviceInput is added.
            
            if ([_captureSession canAddInput: deviceInput]) {
                [_captureSession addInput: deviceInput];
            }
            
            if ([_captureSession canAddOutput:self.videoOutput]) {
                [_captureSession addOutput:self.videoOutput];
            }
            
            if ([_captureSession canAddInput:self.audioMicInput]) {
                [_captureSession addInput:self.audioMicInput];
            }
            
            if ([_captureSession canSetSessionPreset:self->_sessionPreset]) {
                self->_captureSession.sessionPreset = self ->_sessionPreset;
            }else{
                self->_sessionPreset = AVCaptureSessionPreset1280x720;
                NSLog(@"Can't set %@ to captureSession, auto set AVCaptureSessionPreset1280x720 to captureSession", self ->_sessionPreset);
            }
            
//            [self addAudio];
            
            [self.videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            if (self.videoConnection.supportsVideoMirroring && self.isFrontCamera) {
                self.videoConnection.videoMirrored = YES;
            }
            
            
            if ( [deviceInput.device lockForConfiguration:NULL] ) {
                [deviceInput.device setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
                [deviceInput.device unlockForConfiguration];
            }
            [_captureSession commitConfiguration]; //
        }
    }];
    return _captureSession;
}

//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    [self cameraQueueSync:^{
        if (_backCameraInput == nil) {
            NSError *error;
            _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
            if (error) {
                NSLog(@"获取后置摄像头失败~");
            }
        }
        self.camera = _backCameraInput.device;
        //    if ( [self.camera lockForConfiguration:NULL] ) {
        //        self.camera.automaticallyAdjustsVideoHDREnabled = NO;
        //        self.camera.videoHDREnabled = videoHDREnabled;
        //        [self.camera unlockForConfiguration];
        //    }
    }];
    
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    [self cameraQueueSync:^{
        if (_frontCameraInput == nil) {
            NSError *error;
            _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
            if (error) {
                NSLog(@"获取前置摄像头失败~");
            }
        }
        self.camera = _frontCameraInput.device;
    }];
    
//    if ([self.camera lockForConfiguration:NULL] ) {
//        self.camera.automaticallyAdjustsVideoHDREnabled = NO;
//        self.camera.videoHDREnabled = videoHDREnabled;
//        [self.camera unlockForConfiguration];
//    }


    return _frontCameraInput;
}

- (AVCaptureDeviceInput *)audioMicInput
{
    [self cameraQueueSync:^{
        if (!self->_audioMicInput) {
            //添加后置麦克风的输出
            
            AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            NSError *error;
            self->_audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
            if (error) {
                NSLog(@"获取麦克风失败~");
            }
        }
    }];
    return _audioMicInput;
}

- (AVCaptureAudioDataOutput *)audioOutput
{
    if (!_audioOutput) {
        [self cameraQueueSync:^{
            //添加音频输出
            _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
            [_audioOutput setSampleBufferDelegate:self queue:self.audioCaptureQueue];
            
        }];
    }
    return _audioOutput;
}


//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

-(BOOL)supportsAVCaptureSessionPreset:(BOOL)isFront {
    if (isFront) {
        return [self.frontCameraInput.device supportsAVCaptureSessionPreset:_sessionPreset];
    }else {
        return [self.backCameraInput.device supportsAVCaptureSessionPreset:_sessionPreset];
    }
}

//切换前后置摄像头
-(void)changeCameraInputDeviceisFront:(BOOL)isFront {

    [self cameraQueueSync:^{
        BOOL isRunning = self.captureSession.isRunning;
        if (isRunning) {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            [self.captureSession stopRunning];
            NSLog(@"stopRunning changeCameraInputDeviceisFront used time %f",CFAbsoluteTimeGetCurrent() - startTime);
            
        }
        if (isFront) {
            [self.captureSession removeInput:self.backCameraInput];
            if ([self.captureSession canAddInput:self.frontCameraInput]) {
                [self.captureSession addInput:self.frontCameraInput];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.camera];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_camera];
                
                NSLog(@"前置添加监听----");
            }
            self.cameraPosition = AVCaptureDevicePositionFront;
        }else {
            [self.captureSession removeInput:self.frontCameraInput];
            if ([self.captureSession canAddInput:self.backCameraInput]) {
                [self.captureSession addInput:self.backCameraInput];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.camera];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_camera];
                NSLog(@"后置添加监听----");
            }
            self.cameraPosition = AVCaptureDevicePositionBack;
        }
        
        
        
        AVCaptureDeviceInput *deviceInput = isFront ? self.frontCameraInput:self.backCameraInput;
        
        [self.captureSession beginConfiguration]; // the session to which the receiver's AVCaptureDeviceInput is added.
        if ( [deviceInput.device lockForConfiguration:NULL] ) {
            [deviceInput.device setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
            [deviceInput.device unlockForConfiguration];
        }
        [self.captureSession commitConfiguration];
        
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
        if (self.videoConnection.supportsVideoMirroring) {
            self.videoConnection.videoMirrored = isFront;
        }
        
        /* 与标准视频稳定相比，这种稳定方法减少了摄像机的视野，在视频捕获管道中引入了更多的延迟，并消耗了更多的系统内存 */
        if(self.videoConnection.supportsVideoStabilization && !isFront) {//前置保持大视野，关闭防抖
            self.videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
            NSLog(@"activeVideoStabilizationMode = %ld",(long)self.videoConnection.activeVideoStabilizationMode);
        }else {
            NSLog(@"connection don't support video stabilization");
            self.videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeOff;
        }
        if (isRunning) {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            [self.captureSession startRunning];
            NSLog(@"startRunning changeCameraInputDeviceisFront used time %f",CFAbsoluteTimeGetCurrent() - startTime);
        }
    }];
    
}

//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {

    //    //返回和视频录制相关的所有默认设备
    //    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //    //遍历这些设备返回跟position相关的设备
    //    for (AVCaptureDevice *device in devices) {
    //        if ([device position] == position) {
    //            return device;
    //        }
    //    }
    //    return nil;
    __block AVCaptureDevice* newDevice = nil;
    [self cameraQueueSync:^{
        if (@available(iOS 10.2, *)) {
            
            newDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:position];
            if(!newDevice){
                newDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
            }
        }else{
            //返回和视频录制相关的所有默认设备
            NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            //遍历这些设备返回跟position相关的设备
            for (AVCaptureDevice *device in devices) {
                if ([device position] == position) {
                    newDevice = device;
                    break;
                }
            }
        }
    }];
    return newDevice;
}

- (AVCaptureDevice *)camera
{
    if (!_camera) {
        [self cameraQueueSync:^{
            NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            for (AVCaptureDevice *device in devices) {
                if ([device position] == self.cameraPosition)
                {
                    _camera = device;
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_camera];
                }
            }
        }];
    }
    return _camera;
}

- (AVCaptureVideoDataOutput *)videoOutput
{
    if (!_videoOutput) {
        [self cameraQueueSync:^{
            //输出
            _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
            [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
            [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_captureFormat] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
            [_videoOutput setSampleBufferDelegate:self queue:self.videoCaptureQueue];
        }];
    }
    return _videoOutput;
}

//相机操作队列
- (dispatch_queue_t)cameraQueue {
    if (_cameraQueue == nil) {
//        _videoCaptureQueue = dispatch_queue_create("com.faceunity.videoCaptureQueue", NULL);
        cameraQueueKey = &cameraQueueKey;
        _cameraQueue = dispatch_queue_create("com.faceunity.cameraQueue", NULL);
        
#if OS_OBJECT_USE_OBJC
        dispatch_queue_set_specific(_cameraQueue, cameraQueueKey, (__bridge void *)self, NULL);
#endif
    }
    return _cameraQueue;
}

//视频采集队列
- (dispatch_queue_t)videoCaptureQueue {
    if (_videoCaptureQueue == nil) {
        _videoCaptureQueue = dispatch_queue_create("com.faceunity.videoCaptureQueue", NULL);
//        _videoCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    return _videoCaptureQueue;
}

//音频采集队列
- (dispatch_queue_t)audioCaptureQueue {
    if (_audioCaptureQueue == nil) {
        _audioCaptureQueue = dispatch_queue_create("com.faceunity.audioCaptureQueue", NULL);
    }
    return _audioCaptureQueue;
}

//视频连接
- (AVCaptureConnection *)videoConnection {
    [self cameraQueueSync:^{
        _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        _videoConnection.automaticallyAdjustsVideoMirroring =  NO;
    }];
    
    return _videoConnection;
}

//设置采集格式
- (void)setCaptureFormat:(int)captureFormat
{
    [self cameraQueueSync:^{
        if (self->_captureFormat == captureFormat) {
            return;
        }
        
        self->_captureFormat = captureFormat;
        
        if (((NSNumber *)[[self->_videoOutput videoSettings] objectForKey:(id)kCVPixelBufferPixelFormatTypeKey]).intValue != captureFormat) {
            
            [self->_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self->_captureFormat] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
            NSLog(@"切换码流格式");
            if ([self.camera lockForConfiguration:nil]){
                [self.camera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                [self.camera unlockForConfiguration];
            }
        }
    }];
    
}

/**
 * 切换回连续对焦和曝光模式
 * 中心店对焦和曝光(centerPoint)
 */
- (void)resetFocusAndExposureModes {
    [self cameraQueueSync:^{
        AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
        BOOL canResetFocus = [self.camera isFocusPointOfInterestSupported] && [self.camera isFocusModeSupported:focusMode];
        
        AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        BOOL canResetExposure = [self.camera isExposurePointOfInterestSupported] && [self.camera isExposureModeSupported:exposureMode];
        
        CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
        
        NSError *error;
        if ([self.camera lockForConfiguration:&error]) {
            if (canResetFocus) {
                self.camera.focusMode = focusMode;
                self.camera.focusPointOfInterest = centerPoint;
            }
            if (canResetExposure) {
                self.camera.exposureMode = exposureMode;
                self.camera.exposurePointOfInterest = centerPoint;
            }
            [self.camera unlockForConfiguration];
        } else {
            NSLog(@"%@",error);
        }
    }];
    
}


- (void)subjectAreaDidChange:(NSNotification *)notification
{
    dispatch_async(self.videoCaptureQueue, ^{
        CGPoint devicePoint = CGPointMake(0.5, 0.5);
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];

        [self cameraChangeModle:FUCameraFocusModelAutoFace];
    });

}


#pragma  mark -  曝光补偿
- (void)setExposureValue:(float)value {
    [self cameraQueueSync:^{
        //    NSLog(@"camera----曝光值----%lf",value);
        NSError *error;
        if ([self.camera lockForConfiguration:&error]){
            [self.camera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [self.camera setExposureTargetBias:value completionHandler:nil];
            [self.camera unlockForConfiguration];
        }else{
        }
    }];
}


#pragma  mark -  分辨率
-(BOOL)changeSessionPreset:(AVCaptureSessionPreset)sessionPreset{
    __block BOOL res = NO;
    [self cameraQueueSync:^{

        if ([self.captureSession canSetSessionPreset:sessionPreset]) {
            BOOL isRunning = self.captureSession.isRunning;
            if (isRunning) {
                CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
                [self.captureSession stopRunning];
                NSLog(@"stopRunning changeSessionPreset used time %f",CFAbsoluteTimeGetCurrent() - startTime);
            }
            [self.captureSession beginConfiguration];
            self.captureSession.sessionPreset = sessionPreset;
            self.sessionPreset = sessionPreset;
            [self.captureSession commitConfiguration];
            if (isRunning) {
                [self.captureSession startRunning];
            }
            res = YES;
        }else{
            NSLog(@"Can't set %@ to captureSession!", self ->_sessionPreset);
        }
    }];
    return res;
}

#pragma  mark -  镜像
-(void)changeVideoMirrored:(BOOL)videoMirrored{
    [self cameraQueueSync:^{
        if (self.videoConnection.supportsVideoMirroring) {
            self.videoConnection.videoMirrored = videoMirrored;
        }
    }];
}

#pragma  mark -  帧率
-(void)changeVideoFrameRate:(int)frameRate{
    [self cameraQueueSync:^{
        if (frameRate <= 30) {//此方法可以设置相机帧率,仅支持帧率小于等于30帧.
            AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            [videoDevice lockForConfiguration:NULL];
            [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(10, frameRate * 10)];
            [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(10, frameRate * 10)];
            [videoDevice unlockForConfiguration];
            return;
        }
        
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        for(AVCaptureDeviceFormat *vFormat in [videoDevice formats] ) {
            CMFormatDescriptionRef description= vFormat.formatDescription;
            float maxRate = ((AVFrameRateRange*) [vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
            if (maxRate > frameRate - 1 &&
                CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                if ([videoDevice lockForConfiguration:nil]) {
                    /* 设置分辨率的方法activeFormat与sessionPreset是互斥的 */
                    videoDevice.activeFormat = vFormat;
                    [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(10, frameRate * 10)];
                    [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(10, frameRate * 10)];
                    [videoDevice unlockForConfiguration];
                    break;
                }
            }
        }
    }];
}




- (BOOL)focusPointSupported
{
    return self.camera.focusPointOfInterestSupported;
}


- (BOOL)exposurePointSupported
{
    return self.camera.exposurePointOfInterestSupported;
}


- (BOOL)isFrontCamera
{
    return self.cameraPosition == AVCaptureDevicePositionFront;
}

- (BOOL)isMirrored{
    return self.videoConnection.isVideoMirrored;
}

- (AVCaptureVideoOrientation)videoOrientation{
    return self.videoConnection.videoOrientation;
}

//NSTimeInterval preTime = 0;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (captureOutput == self.audioOutput) {
        if ([self.audioDelegate respondsToSelector:@selector(didOutputAudioSampleBuffer:)]) {
            [self.audioDelegate didOutputAudioSampleBuffer: sampleBuffer];
        }
        return ;
    }
    
    if([self.delegate respondsToSelector:@selector(didOutputVideoSampleBuffer:)])
    {
//        NSTimeInterval start = CFAbsoluteTimeGetCurrent();
//        if (preTime != 0) {
//            NSLog(@"每帧时间间隔: %fms",(start - preTime) * 1000);
//        }
//        preTime = start;
        [self.delegate didOutputVideoSampleBuffer:sampleBuffer];
    }
    /* 人脸对焦判断 */
    [self cameraFocusAndExpose];
}

#pragma  mark -  人脸曝光逻辑
-(void)cameraFocusAndExpose{
    [self cameraQueueSync:^{
        if (self->_cameraFocusModel == FUCameraFocusModelAutoFace) {
            
            if ([self.dataSource respondsToSelector:@selector(fuCaptureFaceCenterInImage:)]) {
                CGPoint center =  [self.dataSource fuCaptureFaceCenterInImage:self];
                if (center.y >= 0) {
                    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:center monitorSubjectAreaChange:YES];
                }else{
                    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:CGPointMake(0.5, 0.5) monitorSubjectAreaChange:YES];
                }
            }
        }
    }];
}



-(void)videoCompleted{
    [self cameraQueueSync:^{
        NSString *path = self.recordEncoder.path;
        self.recordEncoder = nil;
        if (self.recordVidepCompleted) {
            self.recordVidepCompleted(path);
        }
    }];
}


- (void)takePhotoAndSave
{
    [self cameraQueueSync:^{
        self->runMode = PhotoTakeMode;
    }];
}

//开始录像
- (void)startRecord
{
    [self cameraQueueSync:^{
        self->runMode = VideoRecordMode;
    }];
}

//停止录像
- (void)stopRecordWithCompletionHandler:(void (^)(NSString *videoPath))handler
{
    [self cameraQueueSync:^{
        self.recordVidepCompleted =  handler;
        self->runMode = VideoRecordEndMode;
    }];

}

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    
    CVPixelBufferLockBaseAddress(pixelBufferRef, 0);
    
    CGFloat SW = [UIScreen mainScreen].bounds.size.width;
    CGFloat SH = [UIScreen mainScreen].bounds.size.height;
    
    float width = CVPixelBufferGetWidth(pixelBufferRef);
    float height = CVPixelBufferGetHeight(pixelBufferRef);
    
    float dw = width / SW;
    float dh = height / SH;

    float cropW = width;
    float cropH = height;

    if (dw > dh) {
        cropW = SW * dh;
    }else
    {
        cropH = SH * dw;
    }

    CGFloat cropX = (width - cropW) * 0.5;
    CGFloat cropY = (height - cropH) * 0.5;

    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBufferRef];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(cropX, cropY,
                                                 cropW,
                                                 cropH)];
    
    UIImage *image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    CVPixelBufferUnlockBaseAddress(pixelBufferRef, 0);
    
    return image;
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"保存图片失败", nil)];
    }else{
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"图片已保存到相册", nil)];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error != NULL){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"保存视频失败", nil)];
        
    }else{
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"视频已保存到相册", nil)];
    }
}

- (void)setCaptureVideoOrientation:(AVCaptureVideoOrientation) orientation {
    [self cameraQueueSync:^{
        if (self.captureSession) {
            [self.videoConnection setVideoOrientation:orientation];
        }
    }];
}

- (void)getCurrentExposureValue:(float *)current max:(float *)max min:(float *)min{
    *min = self.camera.minExposureTargetBias;
    *max = self.camera.maxExposureTargetBias;
    *current = self.camera.exposureTargetBias;

}



- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async(self.videoCaptureQueue, ^{
        AVCaptureDevice *device = self.camera;

        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
            // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
            if ( device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode] ) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }

            if ( device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode] ) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }
        
//            NSLog(@"---point --%@",NSStringFromCGPoint(point));
            
            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    });
}


-(void)cameraChangeModle:(FUCameraFocusModel)modle
{
    [self cameraQueueSync:^{
        self->_cameraFocusModel = modle;
    }];
}


//缩放
- (CGFloat)maxZoomFactor
{
    return MIN(self.camera.activeFormat.videoMaxZoomFactor, 4.0f);
}

- (void)setZoomValue:(CGFloat)zoomValue
{
    [self cameraQueueSync:^{
        if (!self.camera.isRampingVideoZoom) {
            NSError *error;
            if ([self.camera lockForConfiguration:&error]) {
                CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
                self.camera.videoZoomFactor = zoomFactor;
                [self.camera unlockForConfiguration];
            }
        }
    }];
    
}


- (void)cameraQueueAsync:(dispatch_block_t)block{
    [self cameraQueueBlock:block async:YES];
}


- (void)cameraQueueSync:(dispatch_block_t)block{
    [self cameraQueueBlock:block async:NO];
}

- (void)cameraQueueBlock:(dispatch_block_t)block async:(BOOL)async{
    
    EAGLContext *currentContext = [EAGLContext currentContext];
    
    void (^tmpBlock)(void) = [^void(void){
 
        block();
        
        [EAGLContext setCurrentContext:currentContext];
    } copy];
    
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == glQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific(cameraQueueKey))
#endif
        {
            tmpBlock();
        }else
        {
            if (async) {
                dispatch_async(self.cameraQueue, ^{
                    tmpBlock();
                });
            }else{
                 dispatch_sync(self.cameraQueue, ^{
                    tmpBlock();
                });
            }
        }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"camera dealloc");
}
@end
