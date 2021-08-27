//
//  INSExtraGyroData.h
//  INSCoreMedia
//
//  Created by pengwx on 17/3/23.
//  Copyright © 2017年 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSExtraMetadata.h"

CF_EXTERN_C_BEGIN

struct ins_gyro_info {
    int64_t timestamp;      //millisecond
    double gravity_x;
    double gravity_y;
    double gravity_z;
    double rotation_x;
    double rotation_y;
    double rotation_z;
};

#pragma pack(1)
struct ins_gyro_info_raw {
    int64_t timestamp;      //microsecond
    uint16_t gravity_x;
    uint16_t gravity_y;
    uint16_t gravity_z;
    uint16_t rotation_x;
    uint16_t rotation_y;
    uint16_t rotation_z;
//    uint16_t accel[3];
//    uint16_t gyro[3];
};
#pragma pack()

typedef struct ins_gyro_info ins_gyro_info;

typedef struct ins_gyro_info_raw ins_gyro_info_raw;

/// 将ONE 的陀螺仪数据转为标准坐标系的数据， 以Nano 插着手机的时候为标准坐标系
CF_EXPORT ins_gyro_info ins_gyro_convert_to_one_coord(ins_gyro_info gyro_info);

/// 将标准坐标系的陀螺仪数据转为ONE 的数据， 以Nano 插着手机的时候为标准坐标系
CF_EXPORT ins_gyro_info ins_gyro_convert_from_one_coord(ins_gyro_info gyro_info);

/// 将ONE2 的陀螺仪数据转为标准坐标系的数据， 以Nano 插着手机的时候为标准坐标系
CF_EXPORT ins_gyro_info ins_gyro_convert_to_one2_coord(ins_gyro_info gyro_info);

/// 将标准坐标系的陀螺仪数据转为ONE2 的数据， 以Nano 插着手机的时候为标准坐标系
CF_EXPORT ins_gyro_info ins_gyro_convert_from_one2_coord(ins_gyro_info gyro_info);

/// 将EVO 的陀螺仪数据转为标准坐标系的数据， 以Nano 插着手机的时候为标准坐标系
CF_EXPORT ins_gyro_info ins_gyro_convert_to_evo_coord(ins_gyro_info gyro_info);

/// 将标准坐标系的陀螺仪数据转为EVO 的数据， 以Nano 插着手机的时候为标准坐标系
CF_EXPORT ins_gyro_info ins_gyro_convert_from_evo_coord(ins_gyro_info gyro_info);

CF_EXPORT ins_gyro_info ins_gyro_from_raw(ins_gyro_info_raw gyro_info_raw);

CF_EXPORT ins_gyro_info_raw raw_from_gyro_info(ins_gyro_info gyro_info);

CF_EXTERN_C_END

//陀螺仪数据类型，不同硬件不一样
typedef NS_ENUM(NSInteger, INSGyroDataType){
    INSGyroDataTypeNano         = 0,
    INSGyroDataTypeNano2        = 1,
    INSGyroDataTypeAir          = 2,
    INSGyroDataTypeAir2         = 3,
    INSGyroDataTypeOne2         = 4,
    INSGyroDataTypeEVO          = 5,
    INSGyroDataTypeWearable     = 6,
    INSGyroDataTypeOneRPano     = 7,
    INSGyroDataTypeOneRWide     = 8,
    INSGyroDataTypeOneRWideReverse  = 9,
    INSGyroDataTypeOneRPanoReverse  = 10,
    INSGyroDataTypeOneX2 = 11,                      //ONEX2 fisheye
    INSGyroDataTypeOneX2Front = 12,                 //ONEX2 left
    INSGyroDataTypeOneX2Rear = 13,                  //ONEX2 right
    INSGyroDataTypeOneH = 14,
    INSGyroDataTypeGo2 = 15,
};

NS_ASSUME_NONNULL_BEGIN

@interface INSExtraGyroFileInfo : NSObject

@property (nonatomic) NSURL *url;                           //gyro所在的文件路径

@property (nonatomic) NSUInteger location;                  // gyro数据在整个文件中的位置

@property (nonatomic) NSUInteger length;                    //二进制数据的长度

@property (nullable, nonatomic) NSData *firstGyroData;      //ins_gyro_info二进制数据

@property (nonatomic) INSSubMediaType mediaType;            //存储了文件类型

@end


@interface INSExtraGyroData : NSObject

// 最好是通过INSVideoInfoParser获取该值，如果你要自行创建该对象，调用该方法初始化，且需要显式配置timeOffset，type，count等属性
- (instancetype)initWithGyroData:(NSData *)gyroData;

- (nullable INSExtraGyroData *)trimWithLeft:(int64_t)leftTimestamp right:(int64_t)rightTimestamp over:(int64_t)over;
- (nullable INSExtraGyroData *)trimToIndex:(int)index;

//视频帧对应的时间戳, 必须配置，一般是第一帧视频的时间戳，单位 毫秒；如果是isRawGyro 为YES，则单位为 微秒
@property (nonatomic) int64_t timeOffset;

//gyro 数据类型， 必须配置，根据镜头类型
@property (nonatomic) INSGyroDataType type;

//ins_gyro_info类型的数量， 必须配置， 理论上 count = gyroData.length / sizeof(ins_gyro_info),如果通过initWithGyroData初始化，则会在内部计算好，此时无需配置
@property (nonatomic) int count;

//是否应用gyro防抖, 默认是YES， 可忽略
@property (nonatomic) BOOL isApply;

//ins_gyro_info二进制数据
@property (nullable, nonatomic, strong) NSData *gyroData;

//是否为2khz的陀螺仪数据，如果YES，陀螺仪数据的采样率是2khz，且时间戳单位是 微秒
@property (nonatomic) BOOL isRawGyro;

//曝光时间数据，存储在INSExtraInfo
@property (nullable, nonatomic, strong) NSData *exposureData;
@property (nullable, nonatomic, strong) NSData *exposureIndexData;

//帧时间戳数据，存储在INSExtraInfo，只有timelapse视频有
@property (nullable, nonatomic, strong) NSData *framePtsData;

//记录gyro文件的存储信息， 只有timelapse视频，且陀螺仪数据大于150M时，通过解析文件尾才会被赋值
@property (nullable, nonatomic) INSExtraGyroFileInfo *gyroFileInfo;

// 陀螺仪数据是否过大，需要流式传输， 默认为NO ，当gyroFileInfo != nil 时，该值一定为YES
@property (nonatomic) BOOL gyroDataOverflow;

@end

NS_ASSUME_NONNULL_END
