//
//  INSExtraHighlightData.h
//  INSCoreMedia
//
//  Created by HFY on 2019/10/24.
//  Copyright © 2019 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class INSMediaHighlight;
@interface INSExtraHighlightData : NSObject

- (instancetype)initWithRawData:(NSData *)rawData timeOffset:(double)timeOffset framePtsData:(NSData * _Nullable)framePtsData;

/// 所有highlight数据，会在内部解析该数据
@property (nullable, nonatomic, readonly) NSData *rawData;
/// timelapse视频才有
@property (nullable, nonatomic) NSData *framePtsData;
/// 视频第一帧时间戳
@property (nonatomic, readonly) int64_t timeOffset;

/// 点数据
@property (nullable, nonatomic) NSArray <INSMediaHighlight *> *spotDatas;

/// 段数据
@property (nullable, nonatomic) NSArray <INSMediaHighlight *> *segDatas;

/// 屏幕指向数据
@property (nullable, nonatomic) NSArray <INSMediaHighlight *> *markDatas;

/// 无线遥控指向数据
@property (nullable, nonatomic) NSArray <INSMediaHighlight *> *wirelessDatas;

/// multi cam 外屏数据
@property (nullable, nonatomic) NSArray <INSMediaHighlight *> *multiCamRearDatas;

/// multi cam 内屏数据
@property (nullable, nonatomic) NSArray <INSMediaHighlight *> *multiCamFrontDatas;

/// multi cam 内外分屏数据
@property (nullable, nonatomic) NSArray <INSMediaHighlight *> *multiCamBothDatas;

/// 对所有类型的highlight数据，做trim过滤，且做时间戳的重新定义
/// @param trimStart 原素材中配置的trim节点
/// @param trimEnd 原素材中配置的trim节点
/// @param timeOffset trim后视频的first frame timestamp，和metadata中保持一致
- (nullable INSExtraHighlightData *)duplicateWithTrimStart:(double)trimStart trimEnd:(double)trimEnd  timeOffset:(double)timeOffset;

@end

NS_ASSUME_NONNULL_END
