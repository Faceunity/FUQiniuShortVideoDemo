//
//  PLSPlayer.h
//  PLShortVideoKit
//
//  Created by suntongmian on 17/3/7.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import "PLSPlayerView.h"
#import "PLSFilter.h"

@class PLSPlayer;

@protocol PLSPlayerDelegate <NSObject>

@optional
/**
 @abstract  pixelBuffer 格式为 kCVPixelFormatType_32BGRA
 
 @since      v1.0.0
 */
- (CVPixelBufferRef __nonnull)player:(PLSPlayer *__nonnull)player didGetOriginPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer;

- (void)player:(PLSPlayer *__nonnull)player didPlay:(CMTime)currentTime loopsCount:(NSInteger)loopsCount;

- (void)player:(PLSPlayer *__nonnull)player didChangeItem:(AVPlayerItem *__nullable)item;

- (void)player:(PLSPlayer *__nonnull)player didReachEndForItem:(AVPlayerItem *__nonnull)item;

- (void)player:(PLSPlayer *__nonnull)player itemReadyToPlay:(AVPlayerItem *__nonnull)item;

- (void)player:(PLSPlayer *__nonnull)player didSetupPlayerView:(PLSPlayerView *__nonnull)playerView;

- (void)player:(PLSPlayer *__nonnull)player didUpdateLoadedTimeRanges:(CMTimeRange)timeRange;

- (void)player:(PLSPlayer *__nonnull)player itemPlaybackBufferIsEmpty:(AVPlayerItem *__nullable)item;

@end


@interface PLSPlayer : AVPlayer

/**
 @abstract 播放器的代理
 
 @since      v1.0.0
 */
@property (weak, nonatomic) __nullable id<PLSPlayerDelegate> delegate;

/**
 @abstract 循环播放
 
 @since      v1.0.0
 */
@property (assign, nonatomic) BOOL loopEnabled;

/**
 @abstract Whether this instance is currently playing
 
 @since      v1.0.0
 */
@property (readonly, nonatomic) BOOL isPlaying;

/**
 @abstract 播放器的渲染视图
 
 @since      v1.0.0
 */
@property (strong, nonatomic) PLSPlayerView *__nullable playerView;

@property (strong, nonatomic) PLSFilter *__nullable filter;

@property (assign, nonatomic) NSInteger filterType;

+ (PLSPlayer *__nonnull)player;

- (void)setItemByStringPath:(NSString *__nullable)stringPath;

- (void)setItemByUrl:(NSURL *__nullable)url;

- (void)setItemByAsset:(AVAsset *__nullable)asset;

- (void)setItem:(AVPlayerItem *__nullable)item;

/**
 @abstract 将 CVPixelBufferRef 封装为 CMSampleBufferRef
 
 @since      v1.0.0
 */
+ (CMSampleBufferRef __nonnull)getSampleBufferFromCVPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer info:(CMSampleTimingInfo)info;

@end
