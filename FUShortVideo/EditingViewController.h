//
//  EditingViewController.h
//  FUShortVideo
//
//  Created by 千山暮雪 on 2017/5/3.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface EditingViewController : UIViewController

@property (strong, nonatomic) NSArray *urlsArray;
@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) CGFloat totalDuration;
@end
