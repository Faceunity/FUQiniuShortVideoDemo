//
//  FUFaceUnityManager.m
//  LiveDemo3
//
//  Created by 千山暮雪 on 2017/7/12.
//  Copyright © 2017年 ZEGO. All rights reserved.
//

#import "FaceUnityManager.h"
#import "FURenderer.h"
#include <sys/mman.h>
#include <sys/stat.h>
#import "authpack.h"

@interface FaceUnityManager ()
{
    int items[3];
}
@end

@implementation FaceUnityManager


+ (instancetype)shareManager {
    static FaceUnityManager *fuManager = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fuManager = [[FaceUnityManager alloc] init];
    });
    return fuManager ;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        
        [self initFaceunity];
    }
    return self;
}

- (void)initFaceunity
{
#warning faceunity全局只需要初始化一次
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        int size = 0;
        
        void *v3 = [self mmap_bundle:@"v3.bundle" psize:&size];
        
#warning 这里新增了一个参数shouldCreateContext，设为YES的话，不用在外部设置context操作，我们会在内部创建并持有一个context。如果设置为YES,则需要调用FURenderer.h中的接口，不能再调用funama.h中的接口。
        [[FURenderer shareRenderer] setupWithData:v3 ardata:NULL authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
    });
    
#warning 开启多脸识别（最高可设为8，不过考虑到性能问题建议设为4以内）
//    [FURenderer setMaxFaces:4];
    
//    // 美颜效果
//    [self loadFilter];
}

- (CVPixelBufferRef)fuManagerRenderPixelBuffer:(CVPixelBufferRef)pixelBuffer FrameID:(int)frameID{
    
    /*设置美颜效果（滤镜、磨皮、美白、瘦脸、大眼....）*/
    [FURenderer itemSetParam:items[1] withName:@"filter_name" value:self.selectedFilter]; //滤镜
    [FURenderer itemSetParam:items[1] withName:@"cheek_thinning" value:@(self.thinningLevel)]; //瘦脸
    [FURenderer itemSetParam:items[1] withName:@"eye_enlarging" value:@(self.enlargingLevel)]; //大眼
    [FURenderer itemSetParam:items[1] withName:@"color_level" value:@(self.beautyLevel)]; //美白
    [FURenderer itemSetParam:items[1] withName:@"blur_level" value:@(self.selectedBlur)]; //磨皮
    [FURenderer itemSetParam:items[1] withName:@"face_shape" value:@(self.faceShape)]; //瘦脸类型
    [FURenderer itemSetParam:items[1] withName:@"face_shape_level" value:@(self.faceShapeLevel)]; //瘦脸等级
    [FURenderer itemSetParam:items[1] withName:@"red_level" value:@(self.redLevel)]; //红润
    
    [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer withFrameId:frameID items:items itemCount:3 flipx:NO];//flipx 参数设为YES可以使道具做水平方向的镜像翻转
    return pixelBuffer ;
}


- (void)FUManagerRenderFrameWithY:(void*)y U:(void*)u V:(void*)v yStride:(int)ystride uStride:(int)ustride vStride:(int)vstride FrameWidth:(int)width FrameHeight:(int)height Frame:(int)frameID {
    
    /*设置美颜效果（滤镜、磨皮、美白、瘦脸、大眼....）*/
    [FURenderer itemSetParam:items[1] withName:@"filter_name" value:self.selectedFilter]; //滤镜
    [FURenderer itemSetParam:items[1] withName:@"cheek_thinning" value:@(self.thinningLevel)]; //瘦脸
    [FURenderer itemSetParam:items[1] withName:@"eye_enlarging" value:@(self.enlargingLevel)]; //大眼
    [FURenderer itemSetParam:items[1] withName:@"color_level" value:@(self.beautyLevel)]; //美白
    [FURenderer itemSetParam:items[1] withName:@"blur_level" value:@(self.selectedBlur)]; //磨皮
    [FURenderer itemSetParam:items[1] withName:@"face_shape" value:@(self.faceShape)]; //瘦脸类型
    [FURenderer itemSetParam:items[1] withName:@"face_shape_level" value:@(self.faceShapeLevel)]; //瘦脸等级
    [FURenderer itemSetParam:items[1] withName:@"red_level" value:@(self.redLevel)]; //红润
    
    [[FURenderer shareRenderer] renderFrame:y u:u v:v ystride:ystride ustride:ustride vstride:vstride width:width height:height frameId:frameID items:items itemCount:3 ];
    
}

- (void)removeAllEffect {
    
    [self destoryFaceunityItems];
}

#pragma -Faceunity Load Data

-(void)loadItem:(NSString *)itemName {
    
    // noitem 没有道具
    if ([itemName isEqualToString:@"noitem"] || itemName == nil ) {
        if (items[0] != 0) {
            NSLog(@"faceunity: destroy item");
            [FURenderer destroyItem:items[0]];
        }
        items[0] = 0;
        return;
    }
    
    int size = 0;
    
    // 先创建再释放可以有效缓解切换道具卡顿问题
    void *data = [self mmap_bundle:[itemName stringByAppendingString:@".bundle"] psize:&size];
    
    int itemHandle = [FURenderer createItemFromPackage:data size:size];
    
    if (items[0] != 0) {
        NSLog(@"faceunity: destroy item");
        [FURenderer destroyItem:items[0]];
    }
    
    items[0] = itemHandle;
    
    NSLog(@"faceunity: load item");
}

- (void)loadFilter
{
    
    int size = 0;
    
    void *data = [self mmap_bundle:@"face_beautification.bundle" psize:&size];
    
    items[1] = [FURenderer createItemFromPackage:data size:size];
}

// 退出时销毁道具
- (void)destoryFaceunityItems {
    
    [FURenderer destroyAllItems];
    
    for (int i = 0; i < sizeof(items) / sizeof(int); i++) {
        items[i] = 0;
    }
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
        close(fd);
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

@end
