//
//  PLSAVAssetExportSession.h
//  PLShortVideoKit
//
//  Created by suntongmian on 2017/7/11.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PLSTypeDefines.h"


@class PLSEditAudio;
@class PLSAVAssetExportSession;

@protocol PLSAVAssetExportSessionDelegate <NSObject>

/**
 @abstract 输出视频文件的视频数据，用来做滤镜处理
 
 @since      v1.1.0
 */
- (CVPixelBufferRef __nonnull)assetExportSession:(PLSAVAssetExportSession *__nonnull)assetExportSession didOutputPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer __deprecated_msg("Method deprecated in v1.9.0. Use `assetExportSession: didOutputPixelBuffer: timestamp:`");

/**
 @abstract 输出视频文件的视频数据，用来做滤镜处理
 @param pixelBuffer 视频帧
 @param timestamp 视频帧的时间戳
 
 @since      v1.9.0
 */
- (CVPixelBufferRef __nonnull)assetExportSession:(PLSAVAssetExportSession *__nonnull)assetExportSession didOutputPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer timestamp:(CMTime)timestamp;

@end

@interface PLSAVAssetExportSession : NSObject

/**
 @abstract 操作视频段的代理
 
 @since      v1.1.0
 */
@property (weak, nonatomic) __nullable id<PLSAVAssetExportSessionDelegate> delegate;

/**
 @property   delegateQueue
 @abstract   触发代理对象回调时所在的任务队列。
 
 @discussion 默认情况下该值为 nil，此时代理方法都会通过 main queue 异步执行回调。如果你期望可以所有的回调在自己创建或者其他非主线程调用，
 可以设置改 delegateQueue 属性。
 
 @see        PLSAVAssetExportSessionDelegate
 @see        delegate
 
 @since      v1.1.0
 */
@property (strong, nonatomic) dispatch_queue_t __nullable delegateQueue;


/**
 @brief 实例初始化方法
 
 @since      v1.1.0
 */
- (instancetype _Nullable )initWithAsset:(AVAsset *_Nullable)asset;

/**
 @brief 将视频导出到相册，默认为 NO
 
 @since      v1.4.0
 */
@property (assign, nonatomic) BOOL isExportMovieToPhotosAlbum;

/**
 @brief 视频导出的文件类型，默认为 PLSFileTypeMPEG4(.mp4)

 @since      v1.1.0
 */
@property (assign, nonatomic) PLSFileType outputFileType;

/**
 @brief 视频导出的路径
 
 @warning 生成 URL 需使用 [NSURL fileURLWithPath:fileName] 方式，让 URL 的 scheme 合法（file://，http://，https:// 等）。
 
 @since      v1.1.0
 */
@property (strong, nonatomic) NSURL * _Nullable outputURL;

/**
 @brief 视频的码率，默认为原视频的码率
 
 @since      v1.11.0
 */
@property (assign, nonatomic) float bitrate;

/**
 @brief 视频旋转，默认为 PLSPreviewOrientationPortrait 视频的原始方向
 
 @since      v1.7.0
 */
@property (assign, nonatomic) PLSPreviewOrientation videoLayerOrientation;

/**
 @brief 视频导出的分辨率
 
 @since      v1.5.0
 */
@property (assign, nonatomic) CGSize outputVideoSize;

/**
 @brief 视频的帧率，默认为原视频的帧率. 如果设置的帧率大于原视频的帧率，将会使用原视频的帧率作为导出视频的帧率，
        没有特别的需求不建议使用此属性.
 
        使用此属性的场景举例：在编辑阶段对帧率为 60 FPS 的视频进行 “极速“ 处理，然后使用 PLSAVAssetExportSession
        导出这个极速处理的视频，如果不加帧率限制，导出的将会是 120 FPS 的视频，iPhone 设备播放 120 FPS 的视频会存在
        问题。此时可以使用此属性将导出视频的帧率限制在 60 FPS 以内。
 
 @since      v1.15.0
 */
@property (assign, nonatomic) float outputVideoFrameRate;

/**
 @brief 是否设置便于网络环境下的传输，默认为 YES
 
 @since      v1.1.0
 */
@property (assign, nonatomic) BOOL shouldOptimizeForNetworkUse;

/**
 @brief 视频导出的设置信息
 
 @since      v1.1.0
 */
@property (strong, nonatomic) NSDictionary * _Nullable outputSettings;

/**
 @brief 视频导出的进度
 
 @since      v1.1.0
 */
@property (nonatomic, readonly) float progress;

/**
 @abstract 视频导出完成的 block
 
 @since      v1.1.0
 */
@property (copy, nonatomic) void(^ _Nullable completionBlock)(NSURL * _Nullable url);

/**
 @abstract 视频导出失败的 block
 
 @since      v1.1.0
 */
@property (copy, nonatomic) void(^ _Nullable failureBlock)(NSError* _Nullable error);

/**
 @abstract 视频导出进度的 block，可在该 block 中刷新导出进度条 UI
 
 @since      v1.1.0
 */
@property (copy, nonatomic) void(^ _Nullable processingBlock)(float progress);

/**
 @brief 异步进行视频导出
 
 @since      v1.1.0
 */
- (void)exportAsynchronously;

/**
 @brief 取消视频导出
 
 @since      v1.1.0
 */
- (void)cancelExport;

/**
 *  添加滤镜效果
 *
 *  @param colorImagePath 当前使用的滤镜的颜色表图的路径
 
 @since      v1.5.0
 */
- (void)addFilter:(NSString *_Nullable)colorImagePath;

/**
 *  添加 MV 图层方法 1, 相当于 addMVLayerWithColor:colorURL alpha:alphaURL timeRange:kCMTimeRangeZero loopEnable:NO
 *
 *  @param colorURL 彩色层视频的地址
 *  @param alphaURL 被彩色层当作透明层的视频的地址
 
 @since      v1.5.0
 */
- (void)addMVLayerWithColor:(NSURL *_Nullable)colorURL alpha:(NSURL *_Nullable)alphaURL;


/**
 *  添加 MV 图层方法 2
 *
 *  @param colorURL 彩色层视频的地址
 *  @param alphaURL 被彩色层当作透明层的视频的地址
 *  @param timeRange  选取 MV 文件的时间段, 如果选取整个 MV，直接传入 kCMTimeRangeZero 即可
 *  @param loopEnable 当 MV 时长(timeRange.duration)小于视频时长时，是否循环播放 MV
 
 @since      v1.14.0
 */
- (void)addMVLayerWithColor:(NSURL *)colorURL alpha:(NSURL *)alphaURL timeRange:(CMTimeRange)timeRange loopEnable:(BOOL)loopEnable;

@end


