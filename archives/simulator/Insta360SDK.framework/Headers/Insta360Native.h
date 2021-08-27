//
//  Insta360Native.h
//  VisualizingSceneSemantics
//
//  Created by Plamen L on 6/17/21.
//  Copyright © 2021 Apple. All rights reserved.
//

#ifndef Insta360Native_h
#define Insta360Native_h
#import <Foundation/Foundation.h>

@interface Insta360Native : NSObject
@property (nonatomic) dispatch_queue_t queue;


- (void)saveImage:(NSString *)photoURI: (NSString *)folderURI;
- (void)connectCamera;
- (void)takePicture:(int )exposureProgram: (int )iso: (int )shutterSpeed : (int )brightness: (int )exposureBias;

@end

#endif /* Insta360Native_h */
