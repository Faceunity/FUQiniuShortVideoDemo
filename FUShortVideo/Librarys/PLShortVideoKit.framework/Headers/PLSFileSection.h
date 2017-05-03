//
//  PLSFileSection.h
//  PLShortVideoKit
//
//  Created by suntongmian on 17/3/1.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PLSFileSection : NSObject

@property (strong, nonatomic) NSURL *fileURL;
@property (assign, nonatomic) CGFloat duration;

@end
