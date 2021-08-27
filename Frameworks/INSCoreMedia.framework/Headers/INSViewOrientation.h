//
//  INSViewOrientation.h
//  INSCoreMedia
//
//  Created by HFY on 2019/12/16.
//  Copyright © 2019 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, INSViewOrientationType){
    INSViewOrientationTypeLens1Front,
    INSViewOrientationTypeLens2Front,
};

NS_ASSUME_NONNULL_BEGIN

@interface INSViewOrientation : NSObject

+(GLKQuaternion)viewOrientation:(INSViewOrientationType)type;

+(GLKQuaternion)viewOrientationBottom:(GLKQuaternion)q;

+(GLKQuaternion)viewOrientationTop:(GLKQuaternion)q;

+(GLKQuaternion)transformRectToSphereCenterWithROI:(CGRect)roiRect width:(float)width height:(float)height;

+ (GLKVector3) eulerFromQuaternion:(GLKQuaternion)q;
+ (GLKQuaternion) quaternionFronEuler:(GLKVector3)euler;

+(GLKVector3)eulerFromQuaternion2:(GLKQuaternion)q;
+ (GLKQuaternion) quaternionFronEuler2:(GLKVector3)euler;
@end

NS_ASSUME_NONNULL_END
