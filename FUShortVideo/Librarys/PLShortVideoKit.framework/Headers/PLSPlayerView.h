//
//  PLSPlayerView.h
//  PLShortVideoKit
//
//  Created by suntongmian on 17/4/14.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import "PLSTypeDefines.h"

@interface PLSPlayerView : UIView

@property (assign, nonatomic) PLSVideoFillModeType fillMode;
@property (assign, nonatomic) PLSPlayerRenderModeType renderMode;

- (void)setFilterMode:(id)filterMode;

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
