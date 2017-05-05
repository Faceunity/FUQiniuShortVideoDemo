//
//  ViewController.m
//  FUShortVideo
//
//  Created by 千山暮雪 on 2017/5/2.
//  Copyright © 2017年 千山暮雪. All rights reserved.
//

#import "ViewController.h"
#import <PLShortVideoKit/PLShortVideoKit.h>
#import "TopBarView.h"
#import "ProgressBar.h"
#import "Masonry.h"
#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import "FURenderer.h"
#import "authpack.h"
#include <sys/mman.h>
#include <sys/stat.h>
#import "EditingViewController.h"


#define MaxDuration 60.0f // 最大录制时间

@interface ViewController ()<TopBarViewDelegate, PLShortVideoSessionDelegate, FUAPIDemoBarDelegate>
{
    int items[3];
    int frameID;
    BOOL needLoadItem;
}
@property (nonatomic, strong)TopBarView *topBarView;
@property (nonatomic, strong)ProgressBar *progressBar;
@property (nonatomic, strong)UIButton *recordBtn ;
@property (nonatomic, strong)UILabel *recordTimeLabel;
@property (nonatomic, strong)UIButton *deleteBtn ;
@property (nonatomic, strong)UIButton *finishBtn ;

@property (nonatomic, strong)PLShortVideoSession *shortVideoSession;

@property (nonatomic, strong)FUAPIDemoBar *demoBar;//工具条
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 短视频录制核心类设置
    [self setupShortVideoSession];
    
    // 添加 UI
    [self addViews];
    
    needLoadItem = YES ;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES ];
    
    // 开启摄像头
    [self.shortVideoSession startCaptureSession];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES ];
    
    // 停止摄像头
    [self.shortVideoSession stopCaptureSession];
}

// 短视频录制核心类设置
- (void)setupShortVideoSession {
    PLSVideoConfiguration *videoConfiguration = [PLSVideoConfiguration defaultConfiguration];
    videoConfiguration.position = AVCaptureDevicePositionFront;
    videoConfiguration.videoSize = CGSizeMake(480, 854);
    videoConfiguration.videoFrameRate = 25;
    videoConfiguration.averageVideoBitRate = 1024*1000;
    PLSAudioConfiguration *audioConfiguration = [PLSAudioConfiguration defaultConfiguration];
    self.shortVideoSession = [[PLShortVideoSession alloc] initWithVideoConfiguration:videoConfiguration audioConfiguration:audioConfiguration];
    self.shortVideoSession.previewView.frame = CGRectMake(0, 0, KWIDTH, KHEIGHT);
    [self.view addSubview:self.shortVideoSession.previewView];
    self.shortVideoSession.delegate = self;
    self.shortVideoSession.maxDuration = MaxDuration; // 设置最长录制时长
}

#pragma mark ---- UI 

- (void)addViews {
    [self.view addSubview:self.topBarView];
    [self.view addSubview:self.progressBar];
    [self.view addSubview:self.recordBtn];
    [self.view addSubview:self.recordTimeLabel];
    [self.view addSubview:self.deleteBtn];
    [self.view addSubview:self.finishBtn];
    
    self.demoBar = [[FUAPIDemoBar alloc] init];
    [self.view addSubview:self.demoBar ];
    [self.demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(128);
    }];
}

-(TopBarView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[TopBarView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 64)];
        _topBarView.delegate = self ;
    }
    return _topBarView ;
}

-(ProgressBar *)progressBar {
    if (!_progressBar) {
        _progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(0, 54, KWIDTH, 10) maxDuration:MaxDuration];
    }
    return _progressBar ;
}

-(UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordBtn.frame = CGRectMake((KWIDTH - 200)/2.0, KHEIGHT - 56 - 128, 200, 44);
        _recordBtn.backgroundColor = [UIColor clearColor];
        _recordBtn.layer.masksToBounds = YES ;
        _recordBtn.layer.cornerRadius = 22 ;
        _recordBtn.layer.borderWidth = 2;
        _recordBtn.layer.borderColor = [UIColor cyanColor].CGColor;
        [_recordBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_recordBtn setTitle:@"开始录像" forState:UIControlStateNormal];
        [_recordBtn setTitle:@"结束录像" forState:UIControlStateSelected];
        [_recordBtn addTarget:self action:@selector(recordBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn ;
}

-(UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        _deleteBtn .frame = CGRectMake(50, KHEIGHT - 250, 60, 60);
        _deleteBtn.backgroundColor = [UIColor lightGrayColor];
        _deleteBtn.layer.masksToBounds = YES ;
        _deleteBtn.layer.cornerRadius = 30 ;
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delegate"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteLastShortVideo) forControlEvents:UIControlEventTouchUpInside];
        
        _deleteBtn.hidden = YES ;
    }
    return _deleteBtn ;
}

-(UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.frame = CGRectMake(KWIDTH - 110, KHEIGHT - 250, 60, 60);
        _finishBtn.backgroundColor = [UIColor lightGrayColor];
        _finishBtn.layer.masksToBounds = YES ;
        _finishBtn.layer.cornerRadius = 30 ;
        [_finishBtn setBackgroundImage:[UIImage imageNamed:@"finish"] forState:UIControlStateNormal];
        [_finishBtn addTarget:self action:@selector(finishShortVideo) forControlEvents:UIControlEventTouchUpInside];
        
        _finishBtn.hidden = YES ;
    }
    return _finishBtn ;
}

-(UILabel *)recordTimeLabel{
    
    if (!_recordTimeLabel) {
        _recordTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 64, 50, 20)];
        _recordTimeLabel.backgroundColor = [UIColor clearColor];
        _recordTimeLabel.textAlignment = NSTextAlignmentCenter ;
        _recordTimeLabel.font = [UIFont systemFontOfSize:14];
        _recordTimeLabel.textColor = [UIColor cyanColor];
    }
    return _recordTimeLabel;
}

-(void)setDemoBar:(FUAPIDemoBar *)demoBar {
    
    _demoBar = demoBar;
    _demoBar.itemsDataSource = @[@"noitem", @"Deer", @"tiara", @"item0208", @"YellowEar", @"PrincessCrown", @"Mood", @"HappyRabbi", @"BeagleDog", @"item0501", @"item0210",  @"item0204", @"hartshorn", @"ColorCrown"];
    _demoBar.selectedItem = _demoBar.itemsDataSource[1];
    _demoBar.filtersDataSource = @[@"nature", @"delta", @"electric", @"slowlived", @"tokyo", @"warm"];
    _demoBar.selectedFilter = _demoBar.filtersDataSource[0];
    _demoBar.selectedBlur = 6;
    _demoBar.beautyLevel = 0.5;
    _demoBar.thinningLevel = 1.0;
    _demoBar.enlargingLevel = 1.0;
    _demoBar.delegate = self;
}

- (void)recordBtnDidClicked:(UIButton *)sender {
    if (sender.selected) {
        [self stopRecording];
    }else {
        [self startRecording];
    }
    sender.selected = !sender.selected;
}

- (void)startRecording {
    NSLog(@"--- 开始录像~");
    self.deleteBtn.hidden = YES ;
    self.finishBtn.hidden = YES ;
    [self.shortVideoSession startRecording];
}

- (void)stopRecording {
    NSLog(@"--- 结束录像~");
    [self.progressBar stopProgress];
    [self.shortVideoSession stopRecording];
}

// 删除上一段视频
- (void)deleteLastShortVideo {
    [self.shortVideoSession deleteLastFile];
}

// 结束录像，进入视频编辑页面
- (void)finishShortVideo {
  
    // 获取当前会话的所有的视频段文件
    NSArray *filesURLArray = [_shortVideoSession getAllFilesURL];
    AVAsset *asset = _shortVideoSession.assetRepresentingAllFiles;
    
    EditingViewController *editingView = [[EditingViewController alloc] init];
    editingView.urlsArray = filesURLArray;
    editingView.asset = asset;
    CGFloat duration = [_shortVideoSession getTotalDuration];
    editingView.totalDuration = duration;
    [self.navigationController pushViewController:editingView animated:YES];
}

#pragma mark --- PLShortVideoSessionDelegate

/** 获取到摄像头原数据时的回调  
 *  在此处加载 FaceUnity 的贴图和美颜效果
 */
- (CVPixelBufferRef)shortVideoSession:(PLShortVideoSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    
    // Faceunity初始化：启动后只需要初始化一次Faceunity即可，切勿多次初始化。
    // g_auth_package 为密钥数组
#warning 此步骤不可放在异步线程中执行
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        int size = 0 ;
        void *v3 = [self mmap_bundle:@"v3.bundle" psize:&size];
        
        [[FURenderer shareRenderer] setupWithData:v3 ardata:NULL authPackage:&g_auth_package authSize:sizeof(g_auth_package)];
        //        fuSetMaxFaces(2);// 最多识别两张脸
        
    });
    // 加载贴纸、3D道具
#warning 如果需要异步加载道具，需停止调用Faceunity的其他接口，否则将会产生崩溃
    if (needLoadItem) {
        needLoadItem = NO;
        [self reloadItem];
    }
    if (items[1] == 0) {
        [self loadFilter] ;
    }
    
    fuItemSetParamd(items[1], "cheek_thinning", self.demoBar.thinningLevel); //瘦脸
    fuItemSetParamd(items[1], "eye_enlarging", self.demoBar.enlargingLevel); //大眼
    fuItemSetParamd(items[1], "color_level", self.demoBar.beautyLevel); //美白
    fuItemSetParams(items[1], "filter_name", (char *)[_demoBar.selectedFilter UTF8String]); //滤镜
    fuItemSetParamd(items[1], "blur_level", self.demoBar.selectedBlur); //磨皮
    
    //--------------------------------
    // Faceunity核心接口，将道具效果作用到图像中，执行完此函数pixelBuffer即包含贴纸效果
    // 其中frameID用来记录当前处理了多少帧图像，该参数与道具中的动画播放有关。itemCount为传入接口的道具数量。
    // 此函数会修改 pixelBuffer 数据，执行完成之后 pixelBuffer 即包含贴纸效果
#warning 此步骤不可放在异步线程中执行
    [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer withFrameId:frameID  items:items itemCount:3];
    frameID += 1 ;
    
    return pixelBuffer;
}

// 开始录制一段视频
-(void)shortVideoSession:(PLShortVideoSession *)shortVideoSession didStartRecordingToOutputFileAtURL:(NSURL *)fileURL {
    
    // 进度条开始走
    [self.progressBar startProgress];
}
// 录制过程
-(void)shortVideoSession:(PLShortVideoSession *)shortVideoSession didRecordingToOutputFileAtURL:(NSURL * _Nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration {
    
    self.recordTimeLabel.text = [NSString stringWithFormat:@"%.2fs", totalDuration];
}

/**
 * 完成一段视频的录制
 * @param fileURL 当前视频地址
 * @param fileDuration 当前时长
 * @param totalDuration 总时长
 */
-(void)shortVideoSession:(PLShortVideoSession *)shortVideoSession didFinishRecordingToOutputFileAtURL:(NSURL * _Nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration error:(NSError * _Nullable)error {
    
    self.deleteBtn.hidden = NO ;
    self.finishBtn.hidden = NO ;
    self.recordBtn.selected = NO;
    [self.progressBar stopProgress];
}

// 在达到指定的视频录制时间 maxDuration 后，如果再调用 [PLShortVideoSession startRecording]，直接执行该回调
-(void)shortVideoSession:(PLShortVideoSession *)shortVideoSession didFinishRecordingMaxDuration:(CGFloat)maxDuration {
    // 结束录制
    [self stopRecording];
    
    self.deleteBtn.hidden = NO ;
    self.finishBtn.hidden = NO ;
    self.recordBtn.selected = NO;
}

// 删除了上一段视频
-(void)shortVideoSession:(PLShortVideoSession *)shortVideoSession didDeleteFileAtURL:(NSURL * _Nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration error:(NSError * _Nullable)error {
    NSLog(@"------ %f",totalDuration);
    if (totalDuration <= 0.0000001f) {
        self.deleteBtn.hidden = YES;
        self.finishBtn.hidden = YES;
    }
    [self.progressBar setProgressWithSec:totalDuration];
    self.recordTimeLabel.text = [NSString stringWithFormat:@"%.2fs", totalDuration];
}

#pragma mark --- TopBarView Delegate

// 屏幕录制比例
- (void)topBarDidChangeScale:(UIButton *)sender {
    
    if (sender.selected) {
        // 全屏状态
        NSLog(@"---- 全屏状态~");
        PLSVideoConfiguration *videoConfiguration = [PLSVideoConfiguration defaultConfiguration];
        videoConfiguration.videoSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale);
        //        videoConfiguration.videoSize = CGSizeMake(480, 854);
        [self.shortVideoSession reloadvideoConfiguration:videoConfiguration];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shortVideoSession.previewView.frame = CGRectMake(0, 0, KWIDTH, KHEIGHT);
        });
    }else {
        // 1：1状态
        NSLog(@"---- 1：1状态~");
        PLSVideoConfiguration *videoConfiguration = [PLSVideoConfiguration defaultConfiguration];
        videoConfiguration.videoSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale);
        [self.shortVideoSession reloadvideoConfiguration:videoConfiguration];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shortVideoSession.previewView.frame = CGRectMake(0, 0, KWIDTH, KWIDTH);
            self.shortVideoSession.previewView.center = self.view.center ;
        });
    }
    
    sender.selected = !sender.selected ;
}

// 切换闪光灯
- (void)topBarDidChangeFlash:(UIButton *)sender {
    
    if (_shortVideoSession.torchOn) {
        _shortVideoSession.torchOn = NO;
    } else {
        _shortVideoSession.torchOn = YES;
    }
    
    sender.selected = !sender.selected ;
}

// 七牛自带美颜效果
- (void)topBarDidChangeFaceBeauty:(UIButton *)sender {
    
    if (sender.selected) {
        // 关闭美颜
        NSLog(@"---- 关闭美颜~");
        [self.shortVideoSession setBeautifyModeOn:NO];
    }else {
        // 开启美颜状态
        NSLog(@"---- 开启美颜~");
        [self.shortVideoSession setBeautifyModeOn:YES];
    }
    
    sender.selected = !sender.selected ;
}

// 更改前后置摄像头
- (void)topBarDidChangeCamera:(UIButton *)sender {
    
    [_shortVideoSession toggleCamera];
}

#pragma mark --- delegate

- (void)demoBarDidSelectedItem:(NSString *)item {
    
    [self reloadItem];
}

- (void)loadFilter {
    
    int size = 0;
    
    void *data = [self mmap_bundle:@"face_beautification.bundle" psize:&size];
    
    items[1] = fuCreateItemFromPackage(data, size);
}

- (void)reloadItem {
    
    if ([_demoBar.selectedItem isEqual: @"noitem"] || _demoBar.selectedItem == nil)
    {
        if (items[0] != 0) {
            NSLog(@"faceunity: destroy item");
            fuDestroyItem(items[0]);
        }
        items[0] = 0;
        return;
    }
    
    int size = 0;
    
    // 先创建再释放可以有效缓解切换道具卡顿问题
    void *data = [self mmap_bundle:[_demoBar.selectedItem stringByAppendingString:@".bundle"] psize:&size];
    
    int itemHandle = fuCreateItemFromPackage(data, size);
    
    if (items[0] != 0) {
        NSLog(@"faceunity: destroy item");
        fuDestroyItem(items[0]);
    }
    
    items[0] = itemHandle;
    
    NSLog(@"faceunity: load item");
}


- (void *)mmap_bundle:(NSString *)bundle psize:(int *)psize {
    
    // Load item from predefined item bundle
    NSString *str = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundle];
    const char *fn = [str UTF8String];
    int fd = open(fn,O_RDONLY);
    
    int size = 0;
    void* zip = NULL;
    
    if (fd == -1) {
        NSLog(@"faceunity: failed to open bundle");
        size = 0;
    }else
    {
        size = [self getFileSize:fd];
        zip = mmap(nil, size, PROT_READ, MAP_SHARED, fd, 0);
    }
    
    *psize = size;
    return zip;
}

- (int)getFileSize:(int)fd
{
    struct stat sb;
    sb.st_size = 0;
    fstat(fd, &sb);
    return (int)sb.st_size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
