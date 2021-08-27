//
//  INSExtraGyroDataGroup.h
//  INSCoreMedia
//
//  Created by HFY on 2021/1/5.
//  Copyright © 2021 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSExtraGyroData.h"

NS_ASSUME_NONNULL_BEGIN

@class INSExtraGyroData;

@interface INSExtraGyroDataGroup : NSObject

@property (nonatomic, readonly) int64_t groupCount;

@property (nonatomic, readonly) INSGyroDataType type;

@property (nonatomic, readonly) int64_t gyroCount;

@property (nonatomic, readonly) NSMutableArray<NSNumber *> *timeOffsetGroup;

- (BOOL)appendGyroData:(INSExtraGyroData *)gyroData;

// 获取本次输入的data，会删除结尾处于上一段重合的部分
- (NSData *)getGyroValidData;

// 获取当前已经获取的所有曝光时间数据；
- (NSData *)getExposureTotalData;


@end

NS_ASSUME_NONNULL_END
