//
//  PLSFile.h
//  PLShortVideoKit
//
//  Created by suntongmian on 17/3/1.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class PLSFileSection;

@class PLSFile;
@protocol PLSFileDelegate <NSObject>

/// @abstract 输出拼接视频文件的视频数据，用来做滤镜处理
- (CVPixelBufferRef __nonnull)file:(PLSFile *__nonnull)file didOutputPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer;

/// @abstract 输出拼接视频文件的进度，progress从0到1
- (void)file:(PLSFile *__nonnull)file didOutputProgress:(CGFloat)progress;

/// @abstract 输出拼接后的视频文件的地址
- (void)file:(PLSFile *__nonnull)file didFinishMergingToOutputFileAtURL:(NSURL *__nonnull)url;

/// @abstract 将拼接后的视频文件导入到相册
- (void)file:(PLSFile *__nonnull)file didExportFileToPhotosAlbum:(NSError *__nullable)error;

/// @abstract 完成从相册中选取视频
- (void)file:(PLSFile *__nonnull)file didFinishSelectingMovieFromPhotosAlbumToOutputFileAtURL:(NSURL *__nonnull)url fileDuration:(CGFloat)fileDuration error:(NSError *__nullable)error;

/// @abstract 取消从相册中选取视频的操作
- (void)file:(PLSFile *__nonnull)file didCancelSelectMovieFromPhotosAlbum:(NSError *__nullable)error;

@end

@interface PLSFile : NSObject

@property (weak, nonatomic) __nullable id<PLSFileDelegate> delegate;
@property (strong, nonatomic) NSMutableArray<PLSFileSection *> *__nullable filesArray;
@property (strong, nonatomic) NSURL *__nullable currentFileURL;
@property (assign, nonatomic) CGFloat currentFileDuration;
@property (assign, nonatomic) CGFloat totalDuration;
@property (readonly, nonatomic) CGFloat intervalDuration;
@property (readonly, nonatomic) float progress;

/**
 @property   delegateQueue
 @abstract   触发代理对象回调时所在的任务队列。
 
 @discussion 默认情况下该值为 nil，此时代理方法都会通过 main queue 异步执行回调。如果你期望可以所有的回调在自己创建或者其他非主线程调用，
 可以设置改 delegateQueue 属性。
 
 @see        PLSFileDelegate
 @see        delegate
 
 @since      v1.0.0
 */
@property (strong, nonatomic) dispatch_queue_t __nullable delegateQueue;

+ (BOOL)createFolderIfNotExist;
+ (NSString *__nonnull)getFileSavePath;

- (void)writeMovieWithUrls:(NSArray<NSURL *> *__nonnull)urls filter:(id __nullable)filter;

- (void)writeMovieWithAsset:(AVAsset *__nonnull)asset filter:(id __nullable)filter;

/// 将沙盒中的视频文件导入到相册，urls 中保存的是视频的完整路径
- (void)exportMovieToPhotosAlbum:(NSArray<NSURL *> *__nonnull)urls;
    
/// 返回值为 NO 时，访问相册失败
- (BOOL)selectMovieFromPhotosAlbum;
@end
