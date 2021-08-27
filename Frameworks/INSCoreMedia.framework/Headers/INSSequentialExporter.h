//
//  INSSequentialExporter.h
//  INSCoreMedia
//
//  Created by HFY on 2019/12/27.
//  Copyright © 2019 insta360. All rights reserved.
//


#import "INSExporter.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class INSExporterInfo;
@class INSBgmClip;

@class INSSequentialExporter;
@protocol INSSequentialExporterDelegate <NSObject>

-(BOOL)isEOF;
-(CVPixelBufferRef _Nullable)sequentialExporter:(INSSequentialExporter*)exporter currentIndex:(int)currentIndex;

@end

@interface INSSequentialExporter : INSExporter

- (instancetype) initWithEstimateDurationMs:(int64_t)estimateDuration bgmClip:(INSBgmClip*_Nullable)bgmClip exporterInfo:(INSExporterInfo*)exporterInfo;

@property(nonatomic) int64_t estimateDuration;
@property(nonatomic) int timescaleFactor;
@property(nonatomic, strong, nullable) INSBgmClip *bgmClip;
@property(nonatomic, strong) INSExporterInfo *exporterInfo;
@property(nonatomic, weak)id<INSSequentialExporterDelegate> delegate;

@end


NS_ASSUME_NONNULL_END
