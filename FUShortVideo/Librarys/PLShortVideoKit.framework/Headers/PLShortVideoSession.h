//
//  PLShortVideoSession.h
//  PLShortVideoKit
//
//  Created by suntongmian on 17/3/1.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "PLSVideoConfiguration.h"
#import "PLSAudioConfiguration.h"
#import "PLSTypeDefines.h"
#import "PLSFile.h"

@class PLShortVideoSession;
@protocol PLShortVideoSessionDelegate <NSObject>

@optional
#pragma mark -- 摄像头／麦克风权限变化的回调
/**
 @abstract 摄像头授权状态发生变化的回调
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)session didGetCameraAuthorizationStatus:(PLSAuthorizationStatus)status;

/**
 @abstract 麦克风授权状态发生变化的回调
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)session didGetMicrophoneAuthorizationStatus:(PLSAuthorizationStatus)status;

#pragma mark -- 摄像头／麦克风采集数据的回调
/**
 @abstract 获取到摄像头原数据时的回调, 便于开发者做滤镜等处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致帧率下降
 
 @since      v1.0.0
 */
- (CVPixelBufferRef __nonnull)shortVideoSession:(PLShortVideoSession *__nonnull)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer;

/**
 @abstract 获取到麦克风原数据时的回调，需要注意的是这个回调在 microphone 数据的输出线程，请不要做过于耗时的操作，否则可能阻塞该线程影响音频输出或其他未知问题
 
 @since      v1.0.0
 */
- (CVPixelBufferRef __nonnull)shortVideoSession:(PLShortVideoSession *__nonnull)session microphoneSourceDidGetPixelBuffer:(CVPixelBufferRef __nonnull)audioBuffer;

#pragma mark -- 视频录制动作的回调
/**
 @abstract 开始录制一段视频时
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)shortVideoSession didStartRecordingToOutputFileAtURL:(NSURL *__nonnull)fileURL;

/**
 @abstract 正在录制的过程中。在完成该段视频录制前会一直回调，可用来更新所有视频段加起来的总时长 totalDuration UI。
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)shortVideoSession didRecordingToOutputFileAtURL:(NSURL *__nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration;

/**
 @abstract 删除了某一段视频
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)shortVideoSession didDeleteFileAtURL:(NSURL *__nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration error:(NSError *__nullable)error;

/**
 @abstract 完成一段视频的录制时
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)shortVideoSession didFinishRecordingToOutputFileAtURL:(NSURL *__nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration error:(NSError *__nullable)error;

/**
 @abstract 在达到指定的视频录制时间 maxDuration 后，如果再调用 [PLShortVideoSession startRecording]，那么会立即执行该回调。该回调功能是用于页面跳转
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)shortVideoSession didFinishRecordingMaxDuration:(CGFloat)maxDuration;

/**
 @abstract 完成从相册中选取一段视频的事件
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)shortVideoSession didFinishSelectingMovieFromPhotosAlbumToOutputFileAtURL:(NSURL *__nonnull)fileURL fileDuration:(CGFloat)fileDuration error:(NSError *__nullable)error;

/**
 @abstract 取消从相册中选取一段视频的事件
 
 @since      v1.0.0
 */
- (void)shortVideoSession:(PLShortVideoSession *__nonnull)shortVideoSession didCancelSelectMovieFromPhotosAlbum:(NSError *__nullable)error;

@end

#pragma mark - basic

/**
 * @abstract 短视频录制的核心类。
 *
 * @discussion 一个 PLShortVideoSession 实例会包含了对视频源、音频源的控制，并且对流的操作及流状态的返回都是通过它来完成的。
 */
@interface PLShortVideoSession : NSObject

/**
 @brief 返回代表当前会话的所有视频段文件的 asset
 
 @since      v1.0.0
 */
- (AVAsset *__nonnull)assetRepresentingAllFiles;

/**
 @brief 视频录制的最大时长，单位为秒。默认为10秒
 
 @since      v1.0.0
 */
@property (assign, nonatomic) CGFloat maxDuration;

/**
 @brief 视频录制的最短时间，单位为秒。默认为2秒
 
 @since      v1.0.0
 */
@property (assign, nonatomic) CGFloat minDuration;

/**
 @brief 视频配置，只读
 
 @since      v1.0.0
 */
@property (strong, nonatomic, readonly) PLSVideoConfiguration *__nonnull videoConfiguration;

/**
 @brief 音频配置，只读
 
 @since      v1.0.0
 */
@property (strong, nonatomic, readonly) PLSAudioConfiguration *__nonnull audioConfiguration;

/**
 * @abstract 摄像头的预览视图，在 PLCameraStreamingSession 初始化之后可以获取该视图
 *
 */
@property (strong, nonatomic, readonly) UIView *__nullable previewView;

/**
 @brief 代理对象
 
 @since      v1.0.0
 */
@property (weak, nonatomic) id<PLShortVideoSessionDelegate> __nullable delegate;

/**
 @property   delegateQueue
 @abstract   触发代理对象回调时所在的任务队列。
 
 @discussion 默认情况下该值为 nil，此时代理方法都会通过 main queue 异步执行回调。如果你期望可以所有的回调在自己创建或者其他非主线程调用，
 可以设置改 delegateQueue 属性。
 
 @see        PLShortVideoSessionDelegate
 @see        delegate
 
 @since      v1.0.0
 */
@property (strong, nonatomic) dispatch_queue_t __nullable delegateQueue;

/**
 @brief previewView 中视频的填充方式，默认使用 PLVideoFillModePreserveAspectRatioAndFill
 
 @since      v1.0.0
 */
@property (readwrite, nonatomic) PLSVideoFillModeType fillMode;

/**
 @brief PLShortVideoSession 处于录制状态时为 true
 
 @since      v1.0.0
 */
@property (readonly, nonatomic) BOOL isRecording;

/**
 @abstract   初始化方法
 
 @since      v1.0.0
 */
- (nonnull instancetype)initWithVideoConfiguration:(PLSVideoConfiguration *__nonnull)videoCaptureConfiguration audioConfiguration:(PLSAudioConfiguration *__nonnull)audioConfiguration;

/**
 @brief 开始录制视频
 
 @since      v1.0.0
 */
- (void)startRecording;

/**
 @brief 停止录制视频
 
 @since      v1.0.0
 */
- (void)stopRecording;

/**
 @brief 取消录制会停止视频录制并删除已经录制的视频段文件
 
 @since      v1.0.0
*/
- (void)cancelRecording;

/**
 @brief 删除上一个录制的视频段
 
 @since      v1.0.0
 */
- (void)deleteLastFile;

/**
 @brief 删除所有录制的视频段
 
 @since      v1.0.0
 */
- (void)deleteAllFiles;

/**
 @brief 获取所有录制的视频段的地址
 
 @since      v1.0.0
 */
- (NSArray<NSURL *> *__nullable)getAllFilesURL;

/**
 @brief 获取录制的视频段的总数目
 
 @since      v1.0.0
 */
- (NSInteger)getFilesCount;

/**
 @brief 获取所有录制的视频段加起来的总时长
 
 @since      v1.0.0
 */
- (CGFloat)getTotalDuration;

/**
 @brief 返回值为 NO 时，访问相册失败
 
 @since      v1.0.0
 */
- (BOOL)selectMovieFromPhotosAlbum;

@end

#pragma mark - Category (CameraSource)

/**
 * @category PLCameraStreamingSession(CameraSource)
 *
 * @discussion 与摄像头相关的接口
 
 @since      v1.0.0
 */
@interface PLShortVideoSession (CameraSource)

/**
 @brief default as AVCaptureDevicePositionBack
 
 @since      v1.0.0
 */
@property (assign, nonatomic) AVCaptureDevicePosition   captureDevicePosition;

/**
 @brief 开启 camera 时的采集摄像头的旋转方向，默认为 AVCaptureVideoOrientationPortrait
 
 @since      v1.0.0
 */
@property (assign, nonatomic) AVCaptureVideoOrientation videoOrientation;

/**
 @abstract default as NO.

 @since      v1.0.0
*/
@property (assign, nonatomic, getter=isTorchOn) BOOL torchOn;

/**
 @property  continuousAutofocusEnable
 @abstract  连续自动对焦。该属性默认开启。
 
 @since      v1.0.0
 */
@property (assign, nonatomic, getter=isContinuousAutofocusEnable) BOOL continuousAutofocusEnable;

/**
 @property  touchToFocusEnable
 @abstract  手动点击屏幕进行对焦。该属性默认开启。
 
 @since      v1.0.0
 */
@property (assign, nonatomic, getter=isTouchToFocusEnable) BOOL touchToFocusEnable;

/**
 @property  smoothAutoFocusEnabled
 @abstract  该属性适用于视频拍摄过程中用来减缓因自动对焦产生的镜头伸缩，使画面不因快速的对焦而产生抖动感。该属性默认开启。
 */
@property (assign, nonatomic, getter=isSmoothAutoFocusEnabled) BOOL  smoothAutoFocusEnabled;

/**
 @abstract default as (0.5, 0.5), (0,0) is top-left, (1,1) is bottom-right.
 
 @since      v1.0.0
 */
@property (assign, nonatomic) CGPoint   focusPointOfInterest;

/**
 @abstract 默认为 1.0，设置的数值需要小于等于 videoActiveForat.videoMaxZoomFactor，如果大于会设置失败
 
 @since      v1.0.0
 */
@property (assign, nonatomic) CGFloat videoZoomFactor;

/**
 @brief videoFormats
 
 @since      v1.0.0
 */
@property (strong, nonatomic, readonly) NSArray<AVCaptureDeviceFormat *> *__nonnull videoFormats;

/**
 @brief videoActiveFormat
 
 @since      v1.0.0
 */
@property (strong, nonatomic) AVCaptureDeviceFormat *__nonnull videoActiveFormat;

/**
 @brief 采集的视频的 sessionPreset，默认为 AVCaptureSessionPreset1280x720
 
 @since      v1.0.0
 */
@property (strong, nonatomic) NSString *__nonnull sessionPreset;

/**
 @brief 采集的视频数据的帧率，默认为 25
 
 @since      v1.0.0
 */
@property (assign, nonatomic) NSUInteger videoFrameRate;

/**
 @brief 前置预览是否开启镜像，默认为 YES
 
 @since      v1.0.0
 */
@property (assign, nonatomic) BOOL previewMirrorFrontFacing;

/**
 @brief 后置预览是否开启镜像，默认为 NO
 
 @since      v1.0.0
 */
@property (assign, nonatomic) BOOL previewMirrorRearFacing;

/**
 *  前置摄像头，推的流是否开启镜像，默认 NO
 
 @since      v1.0.0
 */
@property (assign, nonatomic) BOOL streamMirrorFrontFacing;

/**
 *  后置摄像头，推的流是否开启镜像，默认 NO
 
 @since      v1.0.0
 */
@property (assign, nonatomic) BOOL streamMirrorRearFacing;

/**
 *  推流预览的渲染队列
 
 @since      v1.0.0
 */
@property (strong, nonatomic, readonly) dispatch_queue_t __nonnull renderQueue;

/**
 *  推流预览的渲染 OpenGL context
 
 @since      v1.0.0
 */
@property (strong, nonatomic, readonly) EAGLContext *__nonnull renderContext;

/**
 *  切换前置／后置摄像头
 */
- (void)toggleCamera;

/**
 * 开启摄像头 session
 *
 * @discussion 这个方法一般不需要调用，但当你的 App 中需要同时使用到 AVCaptureSession 时，在调用过 - (void)stopCaptureSession 方法后，
 * 如果要重新启用摄像头，可以调用这个方法
 *
 * @see - (void)stopCaptureSession
 
 @since      v1.0.0
 */
- (void)startCaptureSession;

/**
 * 停止摄像头 session
 *
 * @discussion 这个方法一般不需要调用，但当你的 App 中需要同时使用到 AVCaptureSession 时，当你需要暂且切换到你自己定制的摄像头做别的操作时，
 * 你需要调用这个方法来暂停当前 PLShortVideoSession 对 captureSession 的占用。当需要恢复时，调用 - (void)startCaptureSession 方法。
 *
 * @see - (void)startCaptureSession
 
 @since      v1.0.0
 */
- (void)stopCaptureSession;

/**
 *  是否开启美颜
 
 @since      v1.0.0
 */
-(void)setBeautifyModeOn:(BOOL)beautifyModeOn;

/**
 @brief 设置对应 Beauty 的程度参数.
 
 @param beautify 范围从 0 ~ 1，0 为不美颜
 
 @since      v1.0.0
 */
-(void)setBeautify:(CGFloat)beautify;

/**
 *  设置美白程度（注意：如果美颜不开启，设置美白程度参数无效）
 *
 *  @param whiten 范围是从 0 ~ 1，0 为不美白
 
 @since      v1.0.0
 */
-(void)setWhiten:(CGFloat)whiten;

/**
 *  设置红润的程度参数.（注意：如果美颜不开启，设置美白程度参数无效）
 *
 *  @param redden 范围是从 0 ~ 1，0 为不红润
 
 @since      v1.0.0
 */

-(void)setRedden:(CGFloat)redden;

/**
 *  开启水印
 *
 *  @param wateMarkImage 水印的图片
 *  @param position       水印的位置
 
 @since      v1.0.0
 */
-(void)setWaterMarkWithImage:(UIImage *__nonnull)wateMarkImage position:(CGPoint)position;

/**
 *  移除水印
 
 @since      v1.0.0
 */
-(void)clearWaterMark;

- (void)reloadvideoConfiguration:(PLSVideoConfiguration *__nonnull)videoConfiguration;

@end

