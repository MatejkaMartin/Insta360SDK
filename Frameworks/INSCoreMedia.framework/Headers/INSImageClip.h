//
//  INSImageClip.h
//  INSCoreMedia
//
//  Created by pengwx on 2018/8/22.
//  Copyright © 2018年 insta360. All rights reserved.
//

#import "INSClip.h"

NS_ASSUME_NONNULL_BEGIN

@interface INSImageClip : INSClip<NSCoding, NSCopying, NSMutableCopying>

- (instancetype) initWithURL:(NSURL*)url mediaFileSize:(int64_t)mediaFileSize durationMs:(double)durationMs;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, readonly) double durationMs;

/**
 帧率，默认值为30
 */
@property (nonatomic) double fps;

/**
 末尾剪切参与过场动画的时长
 */

@property (nonatomic) double endCutDurationMs;

/**
 开始参与过场动画的时间，此时间为视频原始时间
 */
@property (nonatomic, readonly) double startCutTimeMs;

@end

NS_ASSUME_NONNULL_END
