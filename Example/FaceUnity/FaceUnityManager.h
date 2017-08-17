//
//  FUFaceUnityManager.h
//  LiveDemo3
//
//  Created by 千山暮雪 on 2017/7/12.
//  Copyright © 2017年 ZEGO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FaceUnityManager : NSObject

// 美颜效果~
@property (nonatomic, assign) NSInteger selectedBlur;  // 磨皮
@property (nonatomic, assign) double redLevel;         // 红润
@property (nonatomic, assign) double faceShapeLevel;   // 瘦脸等级
@property (nonatomic, assign) NSInteger faceShape;     // 瘦脸类型
@property (nonatomic, assign) double beautyLevel;      // 美白
@property (nonatomic, assign) double thinningLevel;    // 瘦脸
@property (nonatomic, assign) double enlargingLevel;   // 大眼
@property (nonatomic, strong) NSString *selectedFilter;// 滤镜

// 记录是否显示 FaceUnity 效果
@property (nonatomic, assign)BOOL isShown ;

+ (instancetype)shareManager ;

- (void)loadItem:(NSString *)itemName ;

- (void)loadFilter ;

- (void)removeAllEffect ;

- (CVPixelBufferRef)fuManagerRenderPixelBuffer:(CVPixelBufferRef)pixelBuffer FrameID:(int)frameID ;

- (void)FUManagerRenderFrameWithY:(void*)y U:(void*)u V:(void*)v yStride:(int)ystride uStride:(int)ustride vStride:(int)vstride FrameWidth:(int)width FrameHeight:(int)height Frame:(int)frameID ;

@end
