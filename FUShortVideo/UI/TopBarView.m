//
//  TopBarView.m
//  ShortVideoDemo
//
//  Created by 千山暮雪 on 2017/4/28.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import "TopBarView.h"
#import "Masonry.h"

#define BtnWidth   45.0
#define BtnGap    (self.frame.size.width - 4 * BtnWidth)/ 5.0

@interface TopBarView ()

@property (nonatomic, strong)UIButton *scaleBtn;
@property (nonatomic, strong)UIButton *flashBtn;
@property (nonatomic, strong)UIButton *faceBtn;
@property (nonatomic, strong)UIButton *cameraBtn;

@end

@implementation TopBarView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupButtons];
    }
    return self ;
}

- (void)setupButtons {
    
    [self addSubview:self.scaleBtn];
    [self.scaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(BtnWidth);
        make.left.mas_equalTo(BtnGap);
        make.centerY.mas_equalTo(self);
    }];
    
    [self addSubview:self.flashBtn];
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(BtnWidth);
        make.left.mas_equalTo(self.scaleBtn.mas_right).offset(BtnGap);
        make.centerY.mas_equalTo(self);
    }];
    
    [self addSubview:self.faceBtn];
    [self.faceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(BtnWidth);
        make.left.mas_equalTo(self.flashBtn.mas_right).offset(BtnGap);
        make.centerY.mas_equalTo(self);
    }];
    
    [self addSubview:self.cameraBtn];
    [self.cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(BtnWidth);
        make.left.mas_equalTo(self.faceBtn.mas_right).offset(BtnGap);
        make.centerY.mas_equalTo(self);
    }];
}

-(UIButton *)scaleBtn {
    if (!_scaleBtn) {
        _scaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _scaleBtn.backgroundColor = [UIColor clearColor];
        [_scaleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _scaleBtn.selected = NO;
        [_scaleBtn setTitle:@"1∶1" forState:UIControlStateNormal];
        [_scaleBtn setTitle:@"全屏" forState:UIControlStateSelected];
        [_scaleBtn addTarget:self action:@selector(scaleBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scaleBtn ;
}

-(UIButton *)flashBtn {
    if (!_flashBtn) {
        _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashBtn.backgroundColor = [UIColor clearColor];
        [_flashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flashBtn setTintColor:[UIColor grayColor]];
        _flashBtn.selected = NO;
        [_flashBtn setImage:[UIImage imageNamed:@"flash_close"] forState:UIControlStateNormal];
        [_flashBtn setImage:[UIImage imageNamed:@"flash_open"] forState:UIControlStateSelected];
        [_flashBtn addTarget:self action:@selector(flashBtnDidCiliked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashBtn ;
}

-(UIButton *)faceBtn {
    if (!_faceBtn) {
        _faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceBtn.backgroundColor = [UIColor clearColor];
        [_faceBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _faceBtn.selected = NO;
        [_faceBtn setTitle:@"美颜" forState:UIControlStateNormal];
        [_faceBtn setTitle:@"普通" forState:UIControlStateSelected];
        [_faceBtn addTarget:self action:@selector(faceBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceBtn ;
}

-(UIButton *)cameraBtn {
    if (!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraBtn.backgroundColor = [UIColor clearColor];
        [_cameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cameraBtn setTintColor:[UIColor grayColor]];
        _cameraBtn.selected = NO;
        [_cameraBtn setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
        [_cameraBtn setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateSelected];
        [_cameraBtn addTarget:self action:@selector(cameraBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn ;
}

- (void)scaleBtnDidClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBarDidChangeScale:)]) {
        [self.delegate topBarDidChangeScale:sender];
    }
}

- (void)flashBtnDidCiliked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBarDidChangeFlash:)]) {
        [self.delegate topBarDidChangeFlash:sender];
    }
}

- (void)faceBtnDidClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBarDidChangeFaceBeauty:)]) {
        [self.delegate topBarDidChangeFaceBeauty:sender];
    }
}

- (void)cameraBtnDidClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBarDidChangeCamera:)]) {
        [self.delegate topBarDidChangeCamera:sender];
    }
}
@end
