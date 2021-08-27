//
//  INSSequenceExporter.h
//  INSCoreMedia
//
//  Created by pengwx on 2019/6/12.
//  Copyright © 2019 insta360. All rights reserved.
//

#import "INSExporter.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class INSExporterInfo;
@class INSBgmClip;

@class INSSequenceExporter;
@protocol INSSequenceExporterDelegate <NSObject>

-(CVPixelBufferRef _Nullable)sequenceExporter:(INSSequenceExporter*)exporter totalFrameCount:(int)totalCount currentIndex:(int)currentIndex;

@end

@interface INSSequenceExporter : INSExporter

- (instancetype) initWithExportTotalFrameCount:(int)totalCount bgmClip:(INSBgmClip*_Nullable)bgmClip exporterInfo:(INSExporterInfo*)exporterInfo;

@property(nonatomic) int totalFrameCount;
@property(nonatomic, strong, nullable) INSBgmClip *bgmClip;
@property(nonatomic, strong) INSExporterInfo *exporterInfo;
@property(nonatomic, weak)id<INSSequenceExporterDelegate> delegate;

@end


NS_ASSUME_NONNULL_END
