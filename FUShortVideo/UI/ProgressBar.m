//
//  ProgressBar.m
//  ShortVideoDemo
//
//  Created by 千山暮雪 on 2017/4/28.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import "ProgressBar.h"


#define perSec 0.1f  // 每走一格需要的时间
@interface ProgressBar ()
{
    CGFloat _animationDuration ;
    CGFloat perWidth ;// 每走一格的长度
    NSMutableArray *widthArray ; // 记录次视频段的长度
}
@property (nonatomic, strong)UIView *progView ;
@property (nonatomic, strong)NSTimer *animationTimer ;
@end

@implementation ProgressBar

-(instancetype)initWithFrame:(CGRect)frame maxDuration:(CGFloat)maxDuration{
    self = [super initWithFrame:frame];
    if (self) {
        _animationDuration = maxDuration ;
        perWidth = frame.size.width / maxDuration * perSec ;
        widthArray = [NSMutableArray arrayWithCapacity:1];
        [widthArray addObject:@0];
        
        [self addSubs];
    }
    return self ;
}

- (void)addSubs {
    self.backgroundColor = [UIColor lightGrayColor];
    self.autoresizingMask = UIViewAutoresizingNone;
    
    self.progView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
    self.progView.backgroundColor = [UIColor redColor];
    [self addSubview:self.progView];
}

// 开始
- (void)startProgress {
    
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:perSec target:self selector:@selector(run) userInfo:nil repeats:YES];
}

- (void)run {
    static long i = 0 ;
    i ++ ;
    [UIView animateWithDuration:perSec animations:^{
        _progView.frame = CGRectMake(0, 0, _progView.frame.size.width + perWidth, _progView.frame.size.height);
    }];
}

// 停止
- (void)stopProgress {
    [widthArray addObject:@(_progView.frame.size.width)];
    [self.animationTimer invalidate];
    self.animationTimer = nil ;
}
// 删除最后一段
- (void)deleteLastProgress {
    
    [widthArray removeLastObject];
    
    if (widthArray.count > 0) {
        CGFloat width = [widthArray.lastObject floatValue];
        
        self.progView.frame = CGRectMake(self.progView.frame.origin.x, self.progView.frame.origin.y, width, self.progView.frame.size.height);
    }
}

-(void)dealloc {
    [self.animationTimer invalidate];
    self.animationTimer = nil ;
}

@end
