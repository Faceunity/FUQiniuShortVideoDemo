//
//  PlayViewController.m
//  FUShortVideo
//
//  Created by 千山暮雪 on 2017/5/3.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayViewController ()

@property (strong, nonatomic) AVAsset *movieAsset;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (nonatomic, strong)UIButton *playBtn ;
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"播放";
    
    self.movieAsset = [AVURLAsset URLAssetWithURL:_url options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:_movieAsset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    self.playerLayer.frame = CGRectMake(0, 0, KWIDTH, KHEIGHT);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:self.playerLayer];
    
    self.playBtn = [[UIButton alloc] initWithFrame:_playerLayer.frame];
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_player pause];
}

- (void)play:(UIButton *)sender {
    
    if (self.playBtn.selected) {
        
        self.playBtn.selected = NO ;
        [self.player pause];
        [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else {
        
        self.playBtn.selected = YES ;
        [self.player play];
        [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

- (void)playerDidPlayToEnd {
    
    self.playBtn.selected = NO ;
    [self.playerItem seekToTime:kCMTimeZero];
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    _player = nil;
    _playerLayer = nil;
    _playerItem = nil;
    _movieAsset = nil;
}

@end
