//
//  CollectionViewCell.m
//  ShortVideoDemo
//
//  Created by 千山暮雪 on 2017/5/2.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _iconImageView.layer.cornerRadius = 30;
        [self addSubview:_iconImageView];
        
        _iconPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconImageView.frame)+8, CGRectGetMaxX(_iconImageView.bounds), 15)];
        _iconPromptLabel.textAlignment = 1;
        _iconPromptLabel.font = [UIFont systemFontOfSize:11];
        _iconPromptLabel.textColor = [UIColor grayColor];
        [self addSubview:_iconPromptLabel];
        
    }
    return self;
}
@end
