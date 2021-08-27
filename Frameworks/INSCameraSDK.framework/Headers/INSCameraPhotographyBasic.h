//
//  INSCameraPhotographyBasic.h
//  INSCameraSDK
//
//  Created by zeng bin on 4/10/17.
//  Copyright © 2017 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef INSCameraPhotographyBasic_H
#define INSCameraPhotographyBasic_H

typedef NS_ENUM(NSUInteger, INSCameraFovType) {
    INSCameraFovTypeWide = 0,
    INSCameraFovTypeLinear,
    INSCameraFovTypeUltraWide,
    INSCameraFovTypeNarrow,
    INSCameraFovTypePOV,
    INSCameraFovTypeLinearPlus,
    INSCameraFovTypeLinearHorizon,
};

typedef NS_ENUM(NSUInteger, INSSensorDevice) {
    INSSensorDeviceUnknown,
    INSSensorDeviceFront,
    INSSensorDeviceRear,
    INSSensorDeviceAll,
};

#endif /* INSCameraPhotographyBasic_H */
