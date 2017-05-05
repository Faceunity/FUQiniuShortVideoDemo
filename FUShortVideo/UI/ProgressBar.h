//
//  ProgressBar.h
//  ShortVideoDemo
//
//  Created by 千山暮雪 on 2017/4/28.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressBar : UIView

-(instancetype)initWithFrame:(CGRect)frame maxDuration:(CGFloat)maxDuration ;

// 开始
- (void)startProgress;
// 停止
- (void)stopProgress;
// 删除
- (void)setProgressWithSec:(CGFloat)sec ;
@end
