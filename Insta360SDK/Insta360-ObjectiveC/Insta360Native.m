#import <Foundation/Foundation.h>
#import "Insta360Native.h"

#if TARGET_IPHONE_SIMULATOR

@implementation Insta360Native

- (void)connectCamera { }

- (void)takePicture:(int )exposureProgram: (int )iso: (int )shutterSpeed : (int )brightness: (int )exposureBias  {}

- (void)saveImage:(NSString *)photoURI: (NSString *)folderURI {}


@end


#else

#import "GCDTimer.h"
#import <INSCameraSDK/INSCameraSDK.h>

@implementation Insta360Native

- (void)connectCamera {
    if ([INSCameraManager socketManager].cameraState == INSCameraStateConnected) {
        NSLog(@"Camera is already connected");
    }
    else {
        [[INSCameraManager socketManager] setup];


        //[self startSendingHeartbeats];
        NSArray *notification = @[INSCameraBatteryStatusNotification, INSCameraBatteryLowNotification, INSCameraTakePictureStateUpdateNotification];

        for (NSString *name in notification) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:)
                name:name object:nil];
        }

        [[INSCameraManager socketManager] addObserver:self
                                           forKeyPath:@"cameraState"
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
    }
}

- (void)startSendingHeartbeats {
    NSLog(@"heartbeat start");

    _queue = dispatch_queue_create("com.insta360.sample.heartbeat", DISPATCH_QUEUE_SERIAL);
    [[GCDTimer defaultTimer] scheduledDispatchTimerWithName:@"HeartbeatsTimer" timeInterval:0.5 queue:_queue repeats:YES action:^{
        [[INSCameraManager socketManager].commandManager sendHeartbeatsWithOptions:nil];
    }];


}

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"received notification %@, info: %@)",notification.name, notification.userInfo);
    if ([notification.name isEqualToString:@"kINSCamNotifTakePictureStateUpdate"]) {
        NSTimeInterval timestamp = ([[NSDate date] timeIntervalSince1970] * 1000000000);
        NSDictionary *timestampData = @{@"imageTimestamp" : @(timestamp), @"data2": @"value2"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Insta360Events" object:nil userInfo:timestampData];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![object isKindOfClass:[INSCameraManager class]]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return ;
    }
    INSCameraManager *manager = (INSCameraManager *)object;

    if (manager == [INSCameraManager socketManager] && [keyPath isEqualToString:@"cameraState"]) {
        //row = [self.form formRowWithTag:@"socket_connect_status"];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        //[self updateDeviceInfo];

        INSCameraState state = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        switch (state) {
            case INSCameraStateFound: {
                //row.value = @"Found";
                break;
            }
            case INSCameraStateConnected: {
                NSLog(@"Camera connected!");
                if (manager == [INSCameraManager socketManager]) {
                    [self startSendingHeartbeats];
                    NSDictionary *connectedData = @{@"cameraConnected" : @1, @"data2": @"value2"};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Insta360Events" object:nil userInfo:connectedData];
                }
                break;
            }
            case INSCameraStateConnectFailed: {
                //row.value = @"Failed";
                //[self stopSendingHeartbeats];
                break;
            }
            default:
                //row.value = @"Not Connected";
                //[self stopSendingHeartbeats];
                break;
        }
    });
}

- (void)stopSendingHeartbeats {
    NSLog(@"heartbeat canceled");

    [[GCDTimer defaultTimer] cancelTimerWithName:@"HeartbeatsTimer"];
}

- (void)setOptions:(int )exposureProgram: (int )iso: (int )shutterSpeed: (int )brightness: (int )exposureBias {
    // take normal picture
    INSCameraExposureOptions *stillExposureOptions = [[INSCameraExposureOptions alloc] init];
    stillExposureOptions.program = exposureProgram;
    stillExposureOptions.iso = iso;
    stillExposureOptions.shutterSpeed = CMTimeMake(1, shutterSpeed);

    INSPhotographyOptions *options = [[INSPhotographyOptions alloc] init];
    options.stillExposure = stillExposureOptions;
    options.brightness = brightness;
    options.exposureBias = exposureBias;

    NSArray *types = @[@(INSPhotographyOptionsTypeStillExposureOptions), @(INSPhotographyOptionsTypeExposureBias), @(INSPhotographyOptionsTypeBrightness)];

    [[INSCameraManager sharedManager].commandManager
     setPhotographyOptions:options forFunctionMode:INSCameraFunctionModeNormalImage
     types:types completion:^(NSError * _Nullable error, NSArray<NSNumber *> * _Nullable successTypes) {
        NSLog(@"Set Photogtaphy Options brightness %d eb %d error %@",brightness, exposureBias, error);
    }];

}

- (void)takePicture:(int )exposureProgram: (int )iso: (int )shutterSpeed : (int )brightness: (int )exposureBias {
    INSExtraInfo *extraInfo = [[INSExtraInfo alloc] init];
    INSTakePictureOptions *options = [[INSTakePictureOptions alloc] initWithExtraInfo:extraInfo];

    //INSCameraExposureOptions *stillExposureOptions = [[INSCameraExposureOptions alloc] init];

    /*
     INSCameraExposureProgramAuto = 0,
     INSCameraExposureProgramISOPriority = 1,
     INSCameraExposureProgramShutterPriority = 2,
     INSCameraExposureProgramManual = 3,
     INSCameraExposureProgramAdaptive = 4,

     */
    /*if (exposureProgram == 1) {
        stillExposureOptions.program = INSCameraExposureProgramISOPriority;
    } else if (exposureProgram == 2) {
        stillExposureOptions.program = INSCameraExposureProgramShutterPriority;
    } else if (exposureProgram == 3) {
        stillExposureOptions.program = INSCameraExposureProgramManual;
    } else if (exposureProgram == 4) {
        stillExposureOptions.program = INSCameraExposureProgramAdaptive;
    }

    if (exposureProgram != 0) {
        stillExposureOptions.iso = iso;
        stillExposureOptions.shutterSpeed = CMTimeMake(1, shutterSpeed);
        options.currenExposureOptions = stillExposureOptions;
    }*/



    [self setOptions:exposureProgram :iso :shutterSpeed :brightness :exposureBias];


    __block NSString *photoUri = nil;
    if ([INSCameraManager socketManager].cameraState == INSCameraStateConnected) {
        NSLog(@"Camera is connected, we can take a picture");

        [[INSCameraManager sharedManager].commandManager takePictureWithOptions:options completion:^(NSError * _Nullable error, INSCameraPhotoInfo * _Nullable photoInfo) {
            NSLog(@"take picture uri: %@, error: %@",photoInfo.uri,error);
            photoUri = photoInfo.uri;
            //photoUri = [photoUri stringByReplacingOccurrencesOfString:@"insp"
            //                                     withString:@"jpg"];
            NSDictionary *myData = @{@"imageUri" : photoUri, @"data2": @"value2"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Insta360Events" object:nil userInfo:myData];


        }];
    }
}

- (void)saveImage:(NSString *)photoURI: (NSString *)folderURI {
    [[INSCameraManager sharedManager].commandManager fetchPhotoWithURI:photoURI completion:^(NSError * _Nullable error, NSData * _Nullable photoData) {
        NSLog(@"saving image: %@ to folder %@",photoURI, folderURI);
        if (photoData) {
            //UIImage *image = [[UIImage alloc] initWithData:photoData];
            NSURL *url = [NSURL fileURLWithPath:photoURI];
            NSString *fileName = url.lastPathComponent;
            //fileName = [fileName stringByReplacingOccurrencesOfString:@"insp"
            //                                     withString:@"jpg"];

            NSLog(@"Write returned error: %@", [error localizedDescription]);

            NSString *filePath = [folderURI stringByAppendingPathComponent:fileName];

            [photoData writeToFile:filePath options:NSDataWritingAtomic error:&error];

            //[UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
            //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }];
}
@end



#endif
