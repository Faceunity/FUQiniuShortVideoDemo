# FUQiniuShortVideoDemo 七牛短视频快速接入文档

`FUQiniuShortVideoDemo` 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo) 面部跟踪和虚拟道具功能 和  七牛云短视频的 Demo。

**本文是 FaceUnity SDK  快速对接 七牛云短视频 的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo)**


## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### FaceUnity 模块简介

```objc
+ Abstract          // 美颜参数数据源业务文件夹
    + FUProvider    // 美颜参数数据源提供者
    + ViewModel     // 模型视图参数传递者
-FUManager          //nama 业务类
-authpack.h         //权限文件  
+FUAPIDemoBar     //美颜工具条,可自定义
+items            //美妆贴纸 xx.bundel文件

```

### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在 `QNRecordingViewController.m`  中添加头文件

```C
/* faceU */
#import "FUManager.h"
#import "UIViewController+FaceUnityUIExtension.h"
```

2、在 `viewDidLoad` 方法中初始化FU `setupFaceUnity` 会初始化FUSDK,和添加美颜工具条,具体实现可查看 `UIViewController+FaceUnityUIExtension.m`

```objc
// 初始化 FaceUnity 美颜等参数
[self setupFaceUnity];
```

### 三、在视频数据回调中 加入 FaceUnity  的数据处理

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

### 四、销毁道具

1 视图控制器生命周期结束时,销毁道具
```C
[[FUManager shareManager] destoryItems];
```

2 切换摄像头需要调用,切换摄像头
```C
[[FUManager shareManager] onCameraChange];
```

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo)