//
//  INSVideoTimePicker.h
//  INSCoreMedia
//
//  Created by HFY on 2020/1/13.
//  Copyright © 2020 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class INSTimeScale;
@class INSEmSegment;
@interface INSVideoTimePicker : NSObject

-(instancetype)init NS_UNAVAILABLE;

/// 初始化对象
/// @param url 文件URL
-(instancetype)initWithURL:(NSURL*)url;

-(instancetype) initWithEmSegments:(NSArray<INSEmSegment*>*)emSegments;

/// demux操作，成功返回nil，错误返回error
-(NSError*_Nullable)open;

/// 取得视频所有帧的时间戳, double
-(NSArray<NSNumber*>*)getAllRawFrameTime;


/// 取得导出时有效的视频帧的时间戳,double
/// @param startTime 导出视频起始时间
/// @param endTime 导出视频结束时间
/// @param timeScales 加速段落
-(NSArray<NSNumber*>*)getExportRawFrameTimeWithStartTimeMs:(double)startTime endTimeMs:(double)endTime timeScales:(NSArray<INSTimeScale*>* _Nullable)timeScales;

/// 取得预览时有效的视频帧的时间戳, double
/// @param startTime 导出视频起始时间
/// @param endTime 导出视频结束时间
/// @param timeScales 加速段落
-(NSArray<NSNumber*>*)getPreviewRawFrameTimeWithStartTimeMs:(double)startTime endTimeMs:(double)endTime timeScales:(NSArray<INSTimeScale*>* _Nullable)timeScales;







@end

NS_ASSUME_NONNULL_END
