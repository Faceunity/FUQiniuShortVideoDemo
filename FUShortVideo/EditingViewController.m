//
//  EditingViewController.m
//  FUShortVideo
//
//  Created by 千山暮雪 on 2017/5/3.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import "EditingViewController.h"
#import "PLShortVideoKit/PLShortVideoKit.h"
#import "PlayViewController.h"
#import "CollectionViewCell.h"

@interface EditingViewController ()<PLSPlayerDelegate, PLSFileDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) PLSPlayer *player;
@property (strong, nonatomic) PLSPlayerView *playerView;
@property (strong, nonatomic) PLSFile *moviefile;

@property (strong, nonatomic) UIView *baseToolboxView;
@property (strong, nonatomic) UIView *editToolboxView;
@property (strong, nonatomic) UICollectionView *editVideoCollectionView;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *filtersArray;
@property (assign, nonatomic) NSInteger filterType;

@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation EditingViewController
{
    BOOL isUseSdkFilter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        isUseSdkFilter = YES; // 是否使用 SDK 内部自带的滤镜，YES: 使用 SDK 内部自带的滤镜，NO: 使用外部滤镜
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_player setItemByAsset:self.asset];
    [_player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑视频";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonClick)];
    
    [self setupEditToolboxView];
    // 播放器
    _player = [PLSPlayer player];
    _player.delegate = self;
    _player.loopEnabled = YES;
    self.playerView = [[PLSPlayerView alloc] initWithFrame:CGRectMake(0, 64, KWIDTH, KWIDTH)];
    self.playerView.fillMode = PLSVideoFillModePreserveAspectRatio;
    _player.playerView.frame = CGRectMake(0, 64, KWIDTH, KWIDTH);
    _player.playerView = self.playerView;
    [self.view addSubview:_player.playerView];
    
    _player.filter.filterModeOn = isUseSdkFilter; // // YES: 启用 SDK 内部滤镜，NO: 关闭 SDK 内部滤镜
    
    _moviefile = [[PLSFile alloc] init];
    _moviefile.delegate = self;
    
//    // SDK 内部自带的美颜后，加入外部滤镜
//    if (!isUseSdkFilter) {
//        // 外部滤镜
//        
//    }
}

- (void)setupEditToolboxView {
    self.editToolboxView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + KWIDTH, KWIDTH, KHEIGHT - 64 - KWIDTH)];
    self.editToolboxView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.editToolboxView];
    
    // 滤镜
    UIButton *filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 35, 35)];
    [filterButton setTitle:@"滤镜" forState:UIControlStateNormal];
    [filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    filterButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.editToolboxView addSubview:filterButton];
    
    // 展示滤镜效果的 UICollectionView
    CGRect frame = self.editVideoCollectionView.frame;
    self.editVideoCollectionView.frame = CGRectMake(frame.origin.x,  CGRectGetMaxY(filterButton.frame)+20, frame.size.width, frame.size.height);
    [self.editToolboxView addSubview:_editVideoCollectionView];
    [self.editVideoCollectionView reloadData];
    
    // 展示拼接视频的进度
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 5, 110, 45)];
    self.progressLabel.textAlignment =  NSTextAlignmentLeft;
    self.progressLabel.textColor = [UIColor whiteColor];
    [self.editToolboxView addSubview:self.progressLabel];
    
    // 展示拼接视频的动画
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    self.activityIndicatorView.center = self.view.center;
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

// 加载拼接视频的动画
- (void)loadActivityIndicatorView {
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
    }
    
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

// 移除拼接视频的动画
- (void)removeActivityIndicatorView {
    [self.activityIndicatorView removeFromSuperview];
    [self.activityIndicatorView stopAnimating];
}

// 滤镜资源
- (NSArray<NSDictionary *> *)filtersArray {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (isUseSdkFilter) {
        // SDK 内部的滤镜
        for (NSDictionary *filterDic in _player.filter.filters) {
            NSString *filterName = [filterDic objectForKey:@"filterName"];
            NSString *filterImagePath = [filterDic objectForKey:@"filterImagePath"];
            
            NSDictionary *dic = @{
                                  @"filterImagePath" : filterImagePath,
                                  @"filterName" : filterName
                                  };
            
            [array addObject:dic];
        }
    }
    else {
        // 客户外部的滤镜
        
    }
    
    return array;
}

// 加载 collectionView 视图
- (UICollectionView *)editVideoCollectionView {
    if (!_editVideoCollectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(65, 80);
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        
        _editVideoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, layout.itemSize.height) collectionViewLayout:layout];
        _editVideoCollectionView.backgroundColor = [UIColor clearColor];
        
        _editVideoCollectionView.showsHorizontalScrollIndicator = NO;
        _editVideoCollectionView.showsVerticalScrollIndicator = NO;
        [_editVideoCollectionView setExclusiveTouch:YES];
        
        [_editVideoCollectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class])];
        
        _editVideoCollectionView.delegate = self;
        _editVideoCollectionView.dataSource = self;
    }
    return _editVideoCollectionView;
}

- (void)nextButtonClick {[_player pause];
    [self loadActivityIndicatorView];
    
    // 是否启用了 SDK 内部自带的滤镜
    if (isUseSdkFilter) {
        // SDK 内部自带的滤镜
        [_moviefile writeMovieWithAsset:self.asset filter:_player.filter.currentFilter];
        //        [_moviefile writeMovieWithUrls:self.urlsArray filter:_player.filter.currentFilter];
    }
    else {
        // 外部滤镜
        [_moviefile writeMovieWithAsset:self.asset filter:nil];
    }
}

#pragma mark -- UICollectionView delegate  用来展示和处理 SDK 内部自带的滤镜效果
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.filtersArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class]) forIndexPath:indexPath];
    
    if (isUseSdkFilter) {
        // SDK 内部自带的滤镜
        NSDictionary *dic = self.filtersArray[indexPath.row];
        
        NSString *filterImagePath = [dic objectForKey:@"filterImagePath"];
        NSString *filterName = [dic objectForKey:@"filterName"];
        
        cell.iconImageView.image = [UIImage imageWithContentsOfFile:filterImagePath];
        cell.iconPromptLabel.text = filterName;
    }
    else {
        // 外部滤镜
        NSDictionary *dic = self.filtersArray[indexPath.row];
        NSString *filterImagePath = [[NSBundle mainBundle] pathForResource:@"Effects4" ofType:@".png"];
        NSString *filterName = [dic objectForKey:@"filterName"];
        
        cell.iconImageView.image = [UIImage imageWithContentsOfFile:filterImagePath];
        cell.iconPromptLabel.text = filterName;
    }
    
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (isUseSdkFilter) {
        // SDK 内部自带的滤镜
        if (!indexPath.row) {
            _filterType = 0;
        }  else {
            _filterType = indexPath.row;
        }
        
        _player.filterType = _filterType;
    }
    else {
        // 外部滤镜
        
    }
}
#pragma mark -- PLSPlayerDelegate 处理视频数据，并将加了滤镜效果的视频数据返回
- (CVPixelBufferRef)player:(PLSPlayer *)player didGetOriginPixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer {
    //此处可以做美颜/滤镜等处理
    
    if (isUseSdkFilter) {
        // SDK 内部自带的滤镜
        return pixelBuffer;
    }
    
    // 外部滤镜
    return [self useExternalFilter:pixelBuffer];
}

#pragma mark -- PLSFileDelegate 处理视频文件的回调
- (void)file:(PLSFile *)file didExportFileToPhotosAlbum:(NSError *)error {
    NSLog(@"didExportFileToPhotosAlbum: error: %@", error.localizedDescription);
}

- (void)file:(PLSFile *)file didFinishMergingToOutputFileAtURL:(NSURL *)url {
    [self joinNextViewController:url];
}

- (void)file:(PLSFile *)file didOutputProgress:(CGFloat)progress {
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(progress * 100)];
}

- (CVPixelBufferRef)file:(PLSFile *)file didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    // 视频数据可用来做滤镜处理，将滤镜效果写入视频文件中
    if (isUseSdkFilter) {
        // SDK 内部自带的滤镜
        return pixelBuffer;
    }
    
    // 外部滤镜
    return [self useExternalFilter:pixelBuffer];
}

// 外部滤镜
- (CVPixelBufferRef)useExternalFilter:(CVPixelBufferRef)pixelBuffer {
    // 外部滤镜
    
    return pixelBuffer;
}

- (void)joinNextViewController:(NSURL *)url {
    [self removeActivityIndicatorView];
    
    // 将拼接得到的视频文件导入到相册
    [_moviefile exportMovieToPhotosAlbum:@[url]];
    
    PlayViewController *playView = [[PlayViewController alloc] init];
    playView.url = url ;
    [self.navigationController pushViewController:playView animated:YES];
}

#pragma mark -- 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    _player.delegate = nil;
    _player = nil;
    _playerView = nil;
    
    _moviefile.delegate = nil;
    _moviefile = nil;
    
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView = nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
