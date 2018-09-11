//
//  VideoSelectViewController.m
//  PLShortVideoKitDemo
//
//  Created by hxiongan on 2018/5/19.
//  Copyright © 2018年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "VideoSelectViewController.h"
#import "MixRecordViewController.h"
#import "VideoMixViewController.h"

@interface VideoSelectViewController ()

@end

@implementation VideoSelectViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextButtonClick:(UIButton *)sender {
    
    if ([self.dynamicScrollView selectedAssets].count < self.needVideoCount) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"请选择 %d 个视频", self.needVideoCount] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.needVideoCount; i ++) {
        PHAsset *asset = [self.dynamicScrollView.selectedAssets objectAtIndex:i];
        [urls addObject:asset.movieURL];
    }
    
    if (enumVideoNextActionPingtu == self.actionType) {
        
        VideoMixViewController *mulitMixViewController = [[VideoMixViewController alloc] init];
        mulitMixViewController.urls = urls;
        [self presentViewController:mulitMixViewController animated:YES completion:nil];
        
    } else if (enumVideoNextActionRecording == self.actionType) {
        
        MixRecordViewController *recordViewController = [[MixRecordViewController alloc] init];
        recordViewController.mixURL = urls[0];
        [self presentViewController:recordViewController animated:YES completion:nil];
        
    }
}
@end
