//
//  TopBarView.h
//  ShortVideoDemo
//
//  Created by 千山暮雪 on 2017/4/28.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopBarViewDelegate <NSObject>

- (void)topBarDidChangeScale:(UIButton *)sender;
- (void)topBarDidChangeFlash:(UIButton *)sender;
- (void)topBarDidChangeFaceBeauty:(UIButton *)sender;
- (void)topBarDidChangeCamera:(UIButton *)sender;
@end


@interface TopBarView : UIView

@property (nonatomic, assign)id<TopBarViewDelegate>delegate ;
@end
