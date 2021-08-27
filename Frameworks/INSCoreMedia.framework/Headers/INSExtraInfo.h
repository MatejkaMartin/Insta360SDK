//
//  INSMediaExtraInfo.h
//  INSMediaApp
//
//  Created by jerett on 16/8/11.
//  Copyright © 2016年 Insta360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSExtraMetadata.h"
#import "INSExtraGyroData.h"
#import "INSExtraProtobufInfo.h"
#import "INSExtraGPSData.h"
#import "INSExtraAAAData.h"
#import "INSExtraHighlightData.h"

typedef NS_ENUM(NSUInteger, INSExtraInfoVersion) {
    INSExtraInfoVersionNano = 2,
    INSExtraInfoVersionOne = 3,
    INSExtraInfoVersionNanoS = 3,
    INSExtraInfoVersionOne2 = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface INSExtraInfo : NSObject

- (nonnull instancetype)initWithVersion:(int)version
                               metadata:(nullable INSExtraMetadata *)metadata
                               gyroData:(nullable INSExtraGyroData *)gyroData;

/**
 *  版本
 */
@property (nonatomic) int version;

/**
 *  metadata 数据, 可以为nil
 */
@property (nullable, nonatomic, strong) INSExtraMetadata *metadata;

/**
 *  thumbnail 数据, 可以为nil, nano 2 才有
 */
@property (nullable, nonatomic, strong) NSData *thumbnail;

/**
 *  ext thumbnail 数据, 可以为nil, one x 5.7k 才有
 */
@property (nullable, nonatomic, strong) NSData *ext_thumbnail;

/**
 *  gyro 数据
 */
@property (nullable, nonatomic, strong) INSExtraGyroData *gyroData;

/**
 *  曝光数据, 可以为nil, ONE 才有
 */
@property (nullable, nonatomic, strong) NSData *exposureData;

/**
 *  每一帧的pts数据, 可以为nil, one x timelapse 才有
 */
@property (nullable, nonatomic, strong) NSData *framePtsData;


/**
 *  一组GPS数据，对应视频帧时间戳, one x (fw:谷歌街景)才有
 */
@property (nullable, nonatomic, strong) INSExtraGPSData *gpsData;

/**
 *  一组表示GPS数据信号强度的数据, one x (fw:20190425)才有, INSExtraGPSData中可访问解析值
 */
@property (nullable, nonatomic, strong) NSData *gpsStarNumData;



/**
 * 一组3A数据值，记录任意帧对应的时间戳与ISO值
 */
@property (nullable, nonatomic, strong) INSExtraAAAData *aaaData;


/**
 *  一组highlight数据值，记录拍摄时的打点信息
*/
@property (nullable, nonatomic, strong) INSExtraHighlightData *highLightData;


/**
 * 固件用来测试的数据，为了能够保证重新写入文件该字段的数据不丢失，这里需要解析出来
 */
@property (nullable, nonatomic, strong) NSData *aaaSimData;

/**
 *  protobuf 数据, 只在nano 1 上使用。
 *  不要直接设置protobufInfo 的属性，而应该设置extraInfo 的属性。
 */
//@property (nullable, nonatomic, strong) INSExtraProtobufInfo *protobufInfo;

/**
 *  gyro数据的文件存储结构信息, 目前需要控制仅仅timelapse视频需要该方法
 */
@property (nullable, nonatomic) INSExtraGyroFileInfo *gyroFileInfo;

@property (nullable, nonatomic, strong) NSData *highlightRawData;

/**
 文件尾总长度, 不参与Serializer
 */
@property (nonatomic) int64_t totalSize;

@end

NS_ASSUME_NONNULL_END
