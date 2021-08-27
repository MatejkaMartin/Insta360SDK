//
//  INSCameraDevice.h
//  INSCameraSDK
//
//  Created by zeng bin on 3/9/17.
//  Copyright © 2017 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSCameraDeviceSettings.h"

NS_ASSUME_NONNULL_BEGIN

#ifndef INSTA360_CAMERA_NAMES
#define INSTA360_CAMERA_NAMES

/// name of Insta360 Nano
extern NSString *const kInsta360CameraNameNano;

/// name of Insta360 ONE
extern NSString *const kInsta360CameraNameOne;

/// name of Insta360 Nano S
extern NSString *const kInsta360CameraNameNanoS;

/// name of Insta360 One X
extern NSString *const kInsta360CameraNameOneX;

/// name of Insta360 EVO
extern NSString *const kInsta360CameraNameEVO;

/// name of Insta360 GO
extern NSString *const kInsta360CameraNameGo;

/// name of Insta360 ONE R
extern NSString *const kInsta360CameraNameOneR;

/// name of Insta360 ONE X2
extern NSString *const kInsta360CameraNameOneX2;

/// name of Insta360 ONE GO 2
extern NSString *const kInsta360CameraNameGo2;

#if INCLUDE_INSTA360APP_ONLY
/// name of Insta360 ONE H
extern NSString *const kInsta360CameraNameOneH;

#endif

#endif


extern int64_t insFirmwareRevisionNumberOfString(NSString *firmwareRevision);

typedef NS_ENUM(NSUInteger, INSCameraDeviceType) {
    INSCameraDeviceTypeUSB = 0,
    INSCameraDeviceTypeSocket,
    INSCameraDeviceTypeBluetooth,
    INSCameraDeviceTypeLite,
};

@class INSCameraOptions;

@protocol INSCameraDevice <NSObject>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly, nullable) NSString *cameraType;
@property (nonatomic, readonly) NSString *serialNumber;
@property (nonatomic, readonly) NSString *firmwareRevision;
@property (nonatomic, readonly) int64_t firmwareRevisionNumber;

@property (nullable, nonatomic) INSCameraDeviceSettings *settings;

@property (nonatomic, readonly) BOOL hasGyroscope;

@property (nonatomic, readonly) BOOL hasExposure;

@property (nonatomic, readonly) INSCameraDeviceType deviceType;

@property (nonatomic, readonly) BOOL isSelfie;

/*!
 * similar to NSString's compare:options:.
 *
 * @param aFirmwareRevision the revision string, e.g. @"1.5.30"
 *
 * @return NSOrderedAscending if camera's firmware is lower than aFirmwareRevision; NSOrderedSame if camera's firmware is equal to aFirmwareRevision; NSOrderedDescending if camera's firmware is higher than aFirmwareRevision;
 */
- (NSComparisonResult)compareFirmwareRevision:(NSString *)aFirmwareRevision;

- (void)updateWithOptions:(INSCameraOptions *)options validTypes:(nonnull NSArray<NSNumber *> *)types;

@end

NS_ASSUME_NONNULL_END
