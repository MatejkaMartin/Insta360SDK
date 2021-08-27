//
//  INSSingleHDRInfo.h
//  INSCoreMedia
//
//  Created by HFY on 2020/1/12.
//  Copyright © 2020 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, INSHDRLevel){
    INSHDRLevelNormal,
    INSHDRLevelSoft,
};

typedef NS_ENUM(NSInteger, INSHDRVersion){
    INSHDRVersionV1,
    INSHDRVersionV2,
};

NS_ASSUME_NONNULL_BEGIN

@interface INSSingleHDRInfo : NSObject

-(instancetype)initWithHDRStrength:(float)strength level:(INSHDRLevel)level;
-(BOOL)isEuqalSingleHDRInfo:(INSSingleHDRInfo*)info;

/// hdr强度, 默认值0.3
@property (nonatomic, readonly) float strength;

//hdr level的设置, 默认值INSHDRLevelNormal
@property(nonatomic, readonly)INSHDRLevel level;

/// hdr version，默认值：INSHDRVersionV2
@property(nonatomic)INSHDRVersion version;

@end


typedef NS_ENUM(NSInteger, INSUnderwaterVersion){
    INSUnderwaterVersionV1,
    INSUnderwaterVersionV2,
};

@interface INSUnderwaterInfo : NSObject

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initVersion:(INSUnderwaterVersion)version lutFilePath:(NSString* _Nullable)lutPath;

@property(nonatomic, readonly)INSUnderwaterVersion version;
@property(nonatomic, strong, readonly, nullable)NSString *lutPath;

-(BOOL)isEualInfo:(INSUnderwaterInfo*)underwaterInfo;

@end

NS_ASSUME_NONNULL_END
