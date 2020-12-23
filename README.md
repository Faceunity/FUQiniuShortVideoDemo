# FUQiniuShortVideoDemo 七牛短视频快速接入文档

`FUQiniuShortVideoDemo` 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪和虚拟道具功能 和  七牛云短视频的 Demo。

**本文是 FaceUnity SDK  快速对接 七牛云短视频 的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**


## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 上述NamaSDK 依赖库使用 Pods 管理 会自动添加依赖,运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### FaceUnity 模块简介
```objc
-FUManager              //nama 业务类
-FUCamera               //视频采集类(示例程序未用到)    
-authpack.h             //权限文件
+FUAPIDemoBar     //美颜工具条,可自定义
+items       //贴纸和美妆资源 xx.bundel文件
      
```


### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在 `QNRecordingViewController.m`  中添加头文件，并创建页面属性

```C
/* faceU */
#import "FUAPIDemoBar.h"
#import "FUManager.h"


@property (nonatomic, strong) FUAPIDemoBar *demoBar;

```

2、初始化 UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `bottomDidChange:` 切换贴纸 和 `filterValueChange:` 更新美颜参数。

```C
/// 初始化demoBar
    _demoBar = [[FUAPIDemoBar alloc] init];
    _demoBar.mDelegate = self;
    [self.view addSubview:_demoBar];
    
    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(self.rateControl.mas_top)
        .mas_offset(-25);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(195);
    }];

```

#### 切换贴纸

```C
// 切换贴纸
-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}

```

#### 更新美颜参数

```C
// 更新美颜参数    
- (void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}
```

### 三、在 `viewDidLoad:` 调用 `setupFaceUnity` 方法,初始化SDK,添加美颜工具条

```C

#pragma mark - 相芯科技贴纸

- (void)setupFaceUnity {

    [[FUTestRecorder shareRecorder] setupRecord];
    
    // 加载FU
    [[FUManager shareManager] loadFilter];
    [FUManager shareManager].isRender = YES;
    [FUManager shareManager].flipx = YES;
    [FUManager shareManager].trackFlipx = YES;
    
    _demoBar = [[FUAPIDemoBar alloc] init];
    _demoBar.mDelegate = self;
    [self.view addSubview:_demoBar];
    
    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(self.rateControl.mas_top)
        .mas_offset(-25);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(195);
    }];
    
    
}

```

### 四、在视频数据回调中 加入 FaceUnity  的数据处理

在 `PLShortVideoRecorderDelegate`代理方法中 可以看到

```C
/*!
 @method shortVideoRecorder:pixelBuffer:
 @abstract 获取到摄像头原数据时的回调, 便于开发者做滤镜等处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致帧率下降
 
 @param recorder PLShortVideoRecorder 实例
 @param pixelBuffer 视频帧数据
 @param timingInfo 采样时间信息
 
 @since      v3.1.1
 */
- (CVPixelBufferRef __nonnull)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder cameraSourceDidGetPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer timingInfo:(CMSampleTimingInfo)timingInfo;

```

```C

- (CVPixelBufferRef)shortVideoRecorder:(PLShortVideoRecorder *)recorder cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer timingInfo:(CMSampleTimingInfo)timingInfo{
    
    // 进行滤镜处理
    if (self.isPanning) {
        // 正在滤镜切换过程中，使用 processPixelBuffer:leftPercent:leftFilter:rightFilter 做滤镜切换动画
        pixelBuffer = [self.filterGroup processPixelBuffer:pixelBuffer leftPercent:self.leftPercent leftFilter:self.leftFilter rightFilter:self.rightFilter];
    } else {
        // 正常滤镜处理
        pixelBuffer = [self.filterGroup.currentFilter process:pixelBuffer];
    }

    if (!self.forbidFaceUnity) {
        // FaceUnity 进行贴纸处理
        pixelBuffer = [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    }
    
    return pixelBuffer;
}
    
```



### 五、销毁道具

1 视图控制器生命周期结束时,销毁道具
```C
[[FUManager shareManager] destoryItems];
```

2 切换摄像头需要调用,切换摄像头
```C
[[FUManager shareManager] onCameraChange];
```

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)