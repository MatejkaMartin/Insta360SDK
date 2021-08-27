//
//  NSNotification+INSCamera.h
//  INSCameraSDK
//
//  Created by zeng bin on 4/8/17.
//  Copyright © 2017 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  battery status update
 *  userInfo - {"battery_status": INSCameraBatteryStatus}
 */
extern NSString *const INSCameraBatteryStatusNotification;

/*!
 *  battery low
 *  userInfo - {"battery_status": INSCameraBatteryStatus}
 */
extern NSString *const INSCameraBatteryLowNotification;

/*!
 *  storage status update
 *  userInfo - {"card_state": INSCameraCardState}
 */
extern NSString *const INSCameraStorageStatusNotification;

/*!
 *  storage full
 */
extern NSString *const INSCameraStorageFullNotification;

/*!
 *  camera will shutdown.
 *  userInfo - {"error_code": code, "message": message string}
 */
extern NSString *const INSCameraWillShutDownNotification;

/*!
 *  firmware upgrade complete
 */
extern NSString *const INSCameraFWUpgradeDoneNotification;

/*!
 *  capture stopped
 *  userInfo - {"error_code": code, "video": INSCameraVideoInfo}
 */
extern NSString *const INSCameraCaptureStoppedNotification;

/*!
 *  capture auto split
 *  userInfo - {"video": INSCameraVideoInfo}
 */
extern NSString *const INSCameraCaptureSplitNotification;

/*!
 *  take picture state update
 *  userInfo - {"state": INSCameraTakePictureState}
 */
extern NSString *const INSCameraTakePictureStateUpdateNotification;

/*!
 *  for bluetooth, sent when the camera is connected through usb
 */
extern NSString *const INSCameraUSBConnectedNotification;

/*!
 *  for bluetooth, sent when the camera has discovered peripherals
 *  userInfo - {"peripherals": [INSCameraBTPeripheral]}
 */
extern NSString *const INSCameraDiscoverBTPeripheralsNotification;

/*!
 *  for bluetooth, sent when the camera has connected to a peripheral
 *  userInfo - {"peripheral": INSCameraBTPeripheral}
 */
extern NSString *const INSCameraConnectedToBTPeripheralNotification;

/*!
 *  for bluetooth, sent when the camera has disconnected with a peripheral
 *  userInfo - {"peripheral": INSCameraBTPeripheral}
 */
extern NSString *const INSCameraDisconnectedBTPeripheralNotification;

/*!
 *  for one x, sent when in preview and the camera capture status change, such as HDR and Bullet shooting
 *  for evo, sent when the camera capture status change or evoStatusMode change
 *  userInfo - {"status": INSCameraCaptureStatus}
 */
extern NSString *const INSCameraCurrentCaptureStatusNotification;

/*!
 *  for evo, sent when in preview and the camera capture mode change, synchronize the UI of camera and app
 */
extern NSString *const INSCameraSyncCaptureModeUpdateNotification;

/*!
 *  for evo, sent when the camera capture mode button triggered
 */
extern NSString *const INSCameraSyncCaptureButtonTriggerNotification;

/*!
 *  for one x, sent when the camera has gotten the bluetooth peripheral version
 */
extern NSString *const INSCameraBtRemoteVerUpdatedNotification;

/*!
 *  for one x bluetooth, sent before fetch wifi ssid via bluetooth
 *  userInfo - {"result": INSPhoneAuthorizationResult}
 */
extern NSString *const INSCameraAuthorizationResultNotification;

/*!
 *  for one x , sent when timelapse status update
 *  userInfo - {"timelapse_status": INSCameraTimelapseStatus}
 */
extern NSString *const INSCameraTimelapseStatusUpdateNotification;

/*!
 *  for go , sent when camera temperature reaching the limit value
 */
extern NSString *const INSCameraTemperatureStatusNotification;

/*!
 *  for go2 , sent when wifi status changed
 */
extern NSString *const INSCameraWifiStatusUpdateNotification;

/*!
 *  for go2 , sent when camera was rotated in the live broadcast
 */
extern NSString *const INSCameraRotatedNotification;


typedef NS_ENUM(NSUInteger, INSCaptureStoppedError) {
    INSCaptureStoppedErrorOverTimeLimit,
    INSCaptureStoppedErrorStorageFull,
    INSCaptureStoppedErrorOther,
    INSCaptureStoppedErrorOverFileNumberLimit,
    INSCaptureStoppedErrorLowCardSpeed,
    INSCaptureStoppedErrorMuxerStreamError,
    INSCaptureStoppedErrorDropFrames,
};

typedef NS_ENUM(NSUInteger,  INSCameraTakePictureState) {
    INSCameraTakePictureStatePrepare,
    INSCameraTakePictureStateShutter,
    INSCameraTakePictureStateCompress,
    INSCameraTakePictureStateWriteToFile,
};

typedef NS_ENUM(NSUInteger, INSPhoneAuthorizationResult) {
    INSPhoneAuthorizationResultUnknown,
    INSPhoneAuthorizationResultSuccess,
    INSPhoneAuthorizationResultReject,
    INSPhoneAuthorizationResultTimeout,
};

typedef NS_ENUM(NSUInteger, INSCameraShutdownErrorCode) {
    INSCameraShutdownErrorCodeBatteryRunout = 0,
    INSCameraShutdownErrorCodeTemperatureOverLimit,
};

@class INSUSBDevice;

@interface NSNotification (INSCamera)

+ (nullable instancetype)ins_notificationWithCode:(NSUInteger)code
                                      contentType:(NSInteger)contentType
                                             data:(NSData *)data;


+ (nullable instancetype)ins_notificationWithCode:(NSUInteger)code
                                      contentType:(NSInteger)contentType
                                             data:(NSData *)data
                                    extraUserInfo:(nullable NSDictionary *)extraUserInfo;

@end

NS_ASSUME_NONNULL_END
