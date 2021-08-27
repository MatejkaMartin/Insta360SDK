//
//  INSGyroDataSource.h
//  INSCoreMedia
//
//  Created by pengwx on 2017/5/16.
//  Copyright © 2017年 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSExtraGyroData.h"

NS_ASSUME_NONNULL_BEGIN

//gyro数据接收协议
@protocol INSGyroReceiverProtocol <NSObject>

- (void)onGyroDataUpdate:(ins_gyro_info *)gyro;

@end

typedef NS_ENUM(NSUInteger, INSGyroDataSourceType) {
    INSGyroDataSourceTypeUnknown,
    INSGyroDataSourceTypeNano1iPhone,
    INSGyroDataSourceTypeNano12Gyro,
    INSGyroDataSourceTypeLiteGyro,
    INSGyroDataSourceTypeOne2Gyro,
    INSGyroDataSourceTypeEVOGyro,
    INSGyroDataSourceTypeWearableGyro,
    INSGyroDataSourceTypeOneRPano,
    INSGyroDataSourceTypeOneRWide,
    INSGyroDataSourceTypeOneRWideReverse,
    INSGyroDataSourceTypeOneRPanoReverse,
    INSGyroDataSourceTypeOneX2,
    INSGyroDataSourceTypeOneX2Front,
    INSGyroDataSourceTypeOneX2Rear,
    INSGyroDataSourceTypeOneH,
    INSGyroDataSourceTypeGo2,
};

//gyro 数据源
@interface INSGyroDataSource : NSObject

@property (nonatomic, readonly) INSGyroDataSourceType sourceType;

- (void) openWithHandler:(void(^)(ins_gyro_info *info, NSError *error))handler;
- (void) close;
- (void) startGyroData:(id<INSGyroReceiverProtocol>)receiver;
- (void) stopGyroData:(id<INSGyroReceiverProtocol>)receiver;

@end

NS_ASSUME_NONNULL_END
