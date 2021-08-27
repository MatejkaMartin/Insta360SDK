//
//  INSPreviewer2.h
//  INSCoreMedia
//
//  Created by pengwx on 2018/7/2.
//  Copyright © 2018年 insta360. All rights reserved.
//



#import "INSPlayerProtocol.h"


NS_ASSUME_NONNULL_BEGIN
//option key
extern NSString* const kINSPreview2DisableLeftChannel;              //value: bool
extern NSString* const kINSPreview2DisableRightChannel;             //value: bool
extern NSString* const kINSPreview2SmoothSwitchCachingDurationMs;   //value: int
extern NSString* const kINSPreview2EnableVideoHwaccel;              //value: bool
extern NSString* const kINSPreview2OutputRange;                     //value: enum INSPreviewer2OutputColorRange {kVideoRange = 0,kFullRange = 1,kAuto = 2,}

/// TODO: delete after debug
extern NSString* const kINSPreview2EnableVideoHwaccel;              //value: bool
extern NSString* const kINSPreview2EnableBuffering;                 //value: bool
extern NSString* const kINSPreview2EnableBufferingProgress;         //value: bool
extern NSString* const kINSPreview2DisableImageAutoScale;           //value: bool
extern NSString* const kINSPreview2EnableShareDecoderInJumpcut;     //value: bool
extern NSString* const kINSPreview2Force10bitVideoOutputNV12;       //value: bool

typedef NS_ENUM(NSInteger, INSPreviewer2Status){
    INSPreviewer2StatusUnknown,
    INSPreviewer2StatusPrepared,
    INSPreviewer2StatusPlaying,
    INSPreviewer2StatusPaused,
};

typedef NS_ENUM(NSInteger, INSPreviewer2OutputColorRange) {
    INSPreviewer2OutputColorRangeVideoRange = 0,
    INSPreviewer2OutputColorRangeFullRange  = 1,
    INSPreviewer2OutputColorRangeAuto = 2,
};

typedef NS_ENUM(NSInteger, INSPreviewer2BufferingStatus) {
    INSPreviewer2BufferingStatusStart = 0,
    INSPreviewer2BufferingStatusUpdate  = 1,
    INSPreviewer2BufferingStatusEnd = 2,
};

typedef NS_ENUM(NSInteger, INSPreviewer2AudioType) {
    INSPreviewer2AudioTypeOriginal = 0,
    INSPreviewer2AudioTypeBgm  = 1,
};


@class INSPreviewer2;
@class INSPlayerImage;
@protocol INSPreviewer2Delegate <NSObject>

- (void) previewerPrepare:(INSPreviewer2*)previewer error:(NSError* _Nullable)error;
- (void) previewerComplete:(INSPreviewer2*)previewer;
- (void) previewerSeek:(INSPreviewer2*)previewer serialId:(int)serialId;
- (void) previewer:(INSPreviewer2*)previewer error:(NSError*)error;

@optional

/**
 预览播放的帧
 @param previewer 预览器
 @param playerImage 视频帧
 */
- (void) previewer:(INSPreviewer2*)previewer playerImage:(INSPlayerImage*)playerImage;

/// buffering信息
/// @param previewer 预览器
/// @param status buffering状态
/// @param progress buffering进度，0~1.0
- (void) previewer:(INSPreviewer2*)previewer bufferingStatus:(INSPreviewer2BufferingStatus)status progress:(double)progress;

@end


@class INSClip;
@class INSBgmClip;
@class INSBgmSource;
@class INSFileClip;
@class INSFileClipPos;
@class INSPreviewer2Pos;
@interface INSPreviewer2: NSObject

@property (nonatomic, readonly) INSPreviewer2Status actionStatus;
@property (nonatomic, weak) id<INSPlayDisplay> displayDelegate;
@property (nonatomic, weak) id<INSPreviewer2Delegate> delegate;
@property (nonatomic) float playRate;
@property (nonatomic) double volume;


/// 只解关键帧接口，默认值NO
@property (nonatomic) BOOL forceVideoKeyFrameOnly;

/**
 设置播放资源
 @param videoClips 可以处理的类型为INSFileClip(视频），INSImageClip（图片）
 @param audioClips 可以处理的类型为INSFileClip(声音），INSEmptyClip（静音）
 @param bgmClips 背景音乐
 @param weight 背景音乐权重，范围 0 ~ 1
 */
//- (void) setVideoSource:(NSArray<INSClip *> *)videoClips bgmSource:(INSBgmClip*_Nullable)bgmClip videoSilent:(BOOL)videoSilent;
- (void) setVideoSource:(NSArray<INSClip *> *)videoClips bgmSource:(INSBgmSource*_Nullable)bgmSource videoSilent:(BOOL)videoSilent;


/**
 设置previewer2的option
 函数必须在setVideoSource之后，prepareAsync之前调用
 @param options option值， key见option key
 */
- (void) setOptions:(NSDictionary*)options;


/**
 设置cache地址
 函数必须在setVideoSource之后，prepareAsync之前调用
 @param cacheURL cache地址
 */
- (void) setCacheDirectory:(NSURL*)cacheURL;

- (void) prepareAsync:(double)mediaTimeMs;

- (void) play;

- (void) pause;


/**
 seek
 @param position seek的时间点，单位：ms
 @return seek的serialId，INSPreviewer2Delegate的seek回调会使用
 */
-(int)seek:(double)position;


-(void)setAudioVolumeType:(INSPreviewer2AudioType)audioType clipIndex:(int)index volume:(double)volume;

/**
 preivewer是否正在seeking中
 @return YES为正在seek
 */
-(BOOL)isSeeking;

-(void)shutdown;

-(INSPreviewer2Pos*) currentPosition;

- (double) getDurationMs;
- (double) getClipStartCutTimeMs:(int)index;
//- (BOOL) mapCurrentPosition:(int64_t)currentPos toFileClipPosition:(INSFileClipPos* _Nullable *_Nonnull)fileClipPos;
//- (BOOL) mapFileClipPosition:(INSFileClipPos*)fileClipPos toCurrentPosition:(int64_t*)currentPos;
- (BOOL) mapMediaTimeMs:(double)mediaTime toSrcTime:(INSFileClipPos* _Nullable *_Nonnull)fileClipPos;
- (BOOL) mapSrcTime:(INSFileClipPos*)fileClipPos toMediaTimeMs:(double*)mediaTime;

/// 获得当前播放器，指定clip下的帧时间戳序列，单位毫秒，NSNumber为double类型
/// @param clipIndex clip index, 0 ~ n
/// @param error error pointer
//- (NSArray<NSNumber*>* _Nullable)getPreviewTimeSequence:(int)clipIndex error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
