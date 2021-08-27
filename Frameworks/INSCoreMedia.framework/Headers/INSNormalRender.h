//
//  INSNormalRender.h
//  INSMediaApp
//
//  Created by pengwx on 16/7/7.
//  Copyright © 2016年 Insta360. All rights reserved.
//

#import "INSRender.h"

typedef struct {
    CGPoint center;
    CGFloat scale;
} SRenderTransform ;

typedef NS_ENUM(NSInteger, INSContentMode){
    INSContentModeScaleToFill,
    INSContentModeScaleAspectFit,
    INSContentModeScaleAspectFill,
};

typedef NS_ENUM(NSInteger, INSBackgroundMode){
    INSBackgroundModeColor,
    INSBackgroundModeBlur,
};

NS_ASSUME_NONNULL_BEGIN

@interface INSNormalRender : INSRender


/**
 默认值为INSContentModeScaleToFill
 */
@property (nonatomic) INSContentMode contentMode;

///背景填充方案，默认值INSBackgroundModeColor
@property (nonatomic) INSBackgroundMode backgroundMode;

/**
 由INSContentMode\contentWidth\contentHeight三者共同计算得出，默认 CGRectMake(0,0,renderWidth,renderHeihgt)
 如果在INSContentModeScaleAspectFit模式下，结果应该是视频主体的rect。

 */
@property (nonatomic, readonly) CGRect contentRect;

/**
 默认值为(0.0, 0.0, 0.0, 1.0)
 */
@property (nonatomic) GLKVector4 contentBackgroundColor;

@property (nonatomic) UIEdgeInsets contentEdgeInset;

/// 视频帧的尺寸，实际为videoFrameWidth\videoFrameHeight
@property (nonatomic) int contentWidth;
@property (nonatomic) int contentHeight;


/**
 相机的旋转方向，单位：弧度
 */
@property (nonatomic) float cameraRoll;

@property (nonatomic)SRenderTransform renderTransform;

// 默认为NO，开启后，可用projection数据调整renderTransform
@property (nonatomic) BOOL useProjectionConvertTransform;


/// 是否使用视频metadata中的旋转量,  默认YES
@property(nonatomic)BOOL useMetadataRotation;

-(void) movePosition:(CGPoint)pt1 toPosition:(CGPoint)pt2;
-(void) scaleCenterPosition:(CGPoint)pt factor:(float)factor;
-(void) resetRenderTransform;

- (void)SetSourceTarget:(INSRenderTarget*)renderTarget;

@end

NS_ASSUME_NONNULL_END
