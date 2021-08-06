//
//  FUManager.h
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/18.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FUBaseModel.h"
#import "FUViewModelManager.h"

@protocol FUManagerProtocol <NSObject>

//用于检测是否有ai人脸和人形
- (void)checkAI;

@end

@class FULiveModel ;

@interface FUManager : NSObject

@property (nonatomic, strong) dispatch_queue_t asyncLoadQueue;
@property (nonatomic, assign) BOOL showFaceUnityEffect ;
@property (nonatomic, assign) BOOL flipx ;
@property (nonatomic, assign) BOOL trackFlipx;
@property (nonatomic, assign) BOOL isRender;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, weak) id<FUManagerProtocol>delegate;

@property (nonatomic, strong) FUViewModelManager *viewModelManager;

/* 美肤参数 */
@property (nonatomic, strong) NSMutableArray<FUBaseModel *> *skinParams;
/* 美型参数 */
@property (nonatomic, strong) NSMutableArray<FUBaseModel *> *shapeParams;
/* 滤镜参数 */
@property (nonatomic, strong) NSMutableArray<FUBaseModel *> *filters;
/* 贴纸参数 */
@property (nonatomic, strong) NSMutableArray<FUBaseModel *> *stickers;
/* 美妆参数 */
@property (nonatomic, strong) NSMutableArray<FUBaseModel *> *makeupParams;
/* 美体参数 */
@property (nonatomic, strong) NSMutableArray<FUBaseModel *> *bodyParams;

+ (FUManager *)shareManager;

/**销毁全部道具*/
- (void)destoryItems;

#pragma  mark -  render
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (int)renderItemWithTexture:(int)texture Width:(int)width Height:(int)height ;
- (void)processFrameWithY:(void*)y U:(void*)u V:(void*)v yStride:(int)ystride uStride:(int)ustride vStride:(int)vstride FrameWidth:(int)width FrameHeight:(int)height;
/**获取75个人脸特征点*/
- (void)getLandmarks:(float *)landmarks;

/**
 获取图像中人脸中心点位置

 @param frameSize 图像的尺寸，该尺寸要与视频处理接口或人脸信息跟踪接口中传入的图像宽高相一致
 @return 返回一个以图像左上角为原点的中心点
 */
- (CGPoint)getFaceCenterInFrameSize:(CGSize)frameSize;

/**切换摄像头要调用此函数*/
- (void)onCameraChange;

/**获取错误信息*/
- (NSString *)getError;
@end
