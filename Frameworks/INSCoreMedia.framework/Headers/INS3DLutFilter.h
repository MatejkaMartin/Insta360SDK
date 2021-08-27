//
//  INS3DLutFilter.h
//  INSCoreMedia
//
//  Created by kahn on 2018/7/30.
//  Copyright © 2018年 insta360. All rights reserved.
//

#import "INSFilter.h"

@interface INS3DLutFilter : INSFilter

/*
 * if you set the lut filter data, you should set the 'type' of the filter data as well.
 */
- (instancetype)initWithFilterData:(NSData *)data type:(INSFilterType)type;
- (instancetype)initWithFilterData:(NSData *)data type:(INSFilterType)type lutScale:(CGFloat)lutScale;

/*
 * if you put the lut data binary in bundle, file path like "MainBundle/INSMedia.bundle/filter/xxx.cube.binary", you can use INSFilterType to construct a lut filter. The type should between INSFilterTypeLutPortraitM5 and INSFilterTypeLutBlackWhiteLegacy
 */
- (instancetype)initWithFilterType:(INSFilterType)type;
- (instancetype)initWithFilterType:(INSFilterType)type lutScale:(CGFloat)lutScale;

@end
