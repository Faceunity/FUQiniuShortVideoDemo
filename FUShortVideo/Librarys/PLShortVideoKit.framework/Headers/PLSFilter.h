//
//  PLSFilter.h
//  PLShortVideoKit
//
//  Created by suntongmian on 17/4/13.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PLSFilter : NSObject

@property (strong, nonatomic) NSMutableArray *filtersArray;
@property (assign, nonatomic) NSInteger filterType;
@property (strong, nonatomic) id currentFilter;

/**
 *  NSDictionary 中 Key 为 filterName, filterImagePath
 */
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *filters;

/**
 *  是否开启滤镜
 */
@property (assign, nonatomic) BOOL filterModeOn;

@end
