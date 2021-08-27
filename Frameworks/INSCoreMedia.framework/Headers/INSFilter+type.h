//
//  INSFilter+type.h
//  INSCoreMedia
//
//  Created by HFY on 2020/3/24.
//  Copyright © 2020 insta360. All rights reserved.
//

#import "INSFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface INSFilter (type)

/**
 * 由type与lutScale生成滤镜对象，lutScale对lut滤镜有效
 */
+ (INSFilter*_Nullable) filterWithType:(INSFilterType)type lutScale:(CGFloat)lutScale;

/**
 *  由type生成滤镜对象，默认lutScale为1.0
 */
+ (INSFilter*_Nullable) filterWithType:(INSFilterType)type;

+ (INSFilter*_Nullable) filterWithType:(INSFilterType)type ConfigDic:(NSDictionary* _Nullable)configdic;

@end

NS_ASSUME_NONNULL_END
