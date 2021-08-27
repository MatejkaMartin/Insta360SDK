//
//  INSCameraCommandOptions+Deprecated.h
//  INSCameraSDK
//
//  Created by HkwKelvin on 2020/7/6.
//  Copyright © 2020 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class INSExtraInfo;

DEPRECATED_MSG_ATTRIBUTE("use 'INSCaptureOptions' instead")
@interface INSBulletTimeOptions : NSObject

@property (nonatomic, nullable) INSExtraInfo *extraInfo;

- (nonnull instancetype)initWithExtraInfo:(nullable INSExtraInfo *)extraInfo;

@end

DEPRECATED_MSG_ATTRIBUTE("use 'INSCaptureOptions' instead")
@interface INSHDRVideoOptions : NSObject

@property (nonatomic, nullable) INSExtraInfo *extraInfo;

- (nonnull instancetype)initWithExtraInfo:(nullable INSExtraInfo *)extraInfo;

@end

NS_ASSUME_NONNULL_END
