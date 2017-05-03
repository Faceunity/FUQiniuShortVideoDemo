//
//  PLSAudioConfiguration.h
//  PLShortVideoKit
//
//  Created by suntongmian on 17/3/1.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PLSTypeDefines.h"

@interface PLSAudioConfiguration : NSObject

/**
 @brief 采集音频数据的声道数，默认为 1
 
 @warning 并非所有采集设备都支持多声道数据的采集
 */
@property (assign, nonatomic) NSUInteger numberOfChannels;

/**
 @brief 音频采样率 sampleRate 默认为 PLSAudioSampleRate_44100Hz
 */
@property (assign, nonatomic) PLSAudioSampleRate sampleRate;

/**
 @brief 音频编码码率 bitRate 默认为 PLSAudioBitRate_128Kbps
 */
@property (assign, nonatomic) PLSAudioBitRate bitRate;

/**
 @brief 回声消除开关，默认为 NO
 
 @discussion 视频录制用到回声消除的场景不多，当用户开启返听功能，并且使用外放时，可打开这个开关，防止产生尖锐的啸叫声。
 */
@property (assign, nonatomic) BOOL acousticEchoCancellationEnable;

/**
 @brief 创建一个默认配置的 PLSAudioConfiguration 实例.
  
 @return 创建的默认 PLSAudioConfiguration 对象
 */
+ (instancetype)defaultConfiguration;

@end
