import Foundation
import Combine

#if canImport(INSCameraSDK) && !targetEnvironment(simulator)


@_implementationOnly import INSCameraSDK

public enum Inta360NativeServiceError: Error {
    case missingPhotoInfo
    case emptyPhotoData
}

public struct Insta360Notification {
    let method: String
    let timestamp: TimeInterval
    let data: [NotificationKey: NotificationValue]

}

@objc
public class Insta360NativeService: NSObject {

    var notifications: AnyPublisher<Insta360Notification, Never> {
        _notifications.eraseToAnyPublisher()
    }

    private var _notifications: PassthroughSubject<Insta360Notification, Never> = .init()

    // Communicate Wi-fi
    private var usbManger: INSCameraManager {
        return INSCameraManager.usb()
    }

    private var socketManager: INSCameraManager {
        return INSCameraManager.socket()
    }

    private var sharedManager: INSCameraManager {
        return INSCameraManager.shared()
    }

    private var statusObservation: NSKeyValueObservation?

    public override init() {
        super.init()
    }

    // MARK: - Public methods

    public func connectCamera() {
        if socketManager.cameraState == .connected {
            //            return Just<Void>(()).eraseToAnyPublisher()
        } else {
            socketManager.setup()
        }

        let notifications: [NSNotification.Name] = [
            .INSCameraBatteryStatus,
            .INSCameraBatteryLow,
            .INSCameraTakePictureStateUpdate,
        ]

        notifications.forEach { notification in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(receivedNotification(notification:)),
                name: notification,
                object: nil)
        }

        statusObservation = socketManager
            .observe(\.cameraState, options: .new) { (manager, value) in
                print("Camera state did change \(value)")
            }
    }

    

    public func fetchPhoto(photoURI: String) -> AnyPublisher<Data, Error> {
        return Future<Data, Error> { [weak self] promise in
            self?.sharedManager
                .commandManager
                .fetchPhoto(withURI: photoURI) { (error, data) in
                    if let error = error {
                        return promise(.failure(error))
                    } else if let data = data {
                        return promise(.success(data))
                    }
                    return promise(.failure(Inta360NativeServiceError.emptyPhotoData))
                }
        }
        .eraseToAnyPublisher()
    }

    public func takePicture() ->  AnyPublisher<String, Error> {
        let options = INSTakePictureOptions()
        return setPhotographyOptions()
            .flatMap { [weak self] _ -> AnyPublisher<String, Error> in
                guard let `self` = self else { return Empty().eraseToAnyPublisher() }
                return self.takePicture(manager: self.sharedManager, options: options)
            }
            .eraseToAnyPublisher()
    }


    // MARK: - Private methods
    func disconnectCamera() {
        socketManager.shutdown()
    }


    @objc private func receivedNotification(notification: NSNotification) {
//        let timestamp = Date().timeIntervalSince1970 * 1000000000
//        let data = notification.userInfo
//        let notification = Insta360Notification(method: notification.name.rawValue, timestamp: timestamp, data: data)
//        switch notification.name {
//        case .INSCameraBatteryStatus: break
//        case .INSCameraBatteryLow: break
//        case .INSCameraTakePictureStateUpdate: break
//        }


//        if extractInfo["imageUri"] != nil {
//            var imageUri = extractInfo["imageUri"] as! String

//        if extractInfo["imageTimestamp"] != nil {
//            lastImageTimestamp = extractInfo["imageTimestamp"] as! Double

//        if extractInfo["cameraConnected"] != nil {
//            print("Camera connected notification!")

        let nevim = notification.userInfo as? [NotificationKey: NotificationValue]
        print(nevim)
        print("received notification %@, info: %@)",notification.name, notification.userInfo ?? [:]);
    }


    func setPhotographyOptions() -> AnyPublisher<Void, Error> {

        let iso: UInt = 0
        let exposureProgram: INSCameraExposureProgram = .shutterPriority
        let shutterSpeed: CMTimeScale = .init(0.0)
        let exposureCompensation: Float = -1
        let brightness: Int32 = 0

        let stillExposureOptions = INSCameraExposureOptions()
        stillExposureOptions.program = exposureProgram
        stillExposureOptions.iso = iso
        stillExposureOptions.shutterSpeed = .init(value: 1, timescale: shutterSpeed)

        let options = INSPhotographyOptions()
        options.stillExposure = stillExposureOptions
        options.brightness = brightness
        options.exposureBias = exposureCompensation

        let types: [INSPhotographyOptionsType] = [
            .stillExposureOptions,
            .exposureBias,
            .brightness
        ]

        return Future<Void, Error> { [weak self] promise in
            self?.sharedManager
                .commandManager
                .setPhotographyOptions(options, for: .normalImage, types: types.map { NSNumber(value: $0.rawValue) }) { (error, successTypes) in
                    if let error = error {
                        return promise(.failure(error))
                    } else if types.count == (successTypes?.count ?? 0) {
                        return promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func takePicture(manager: INSCameraManager, options: INSTakePictureOptions) -> AnyPublisher<String, Error> {

        Future<String, Error> { promise in
            manager
                .commandManager
                .takePicture(with: options) { (error, info) in
                    if let error = error {
                        return promise(.failure(error))
                    } else if let info = info {
                        return promise(.success(info.uri))
                    }
                    return promise(.failure(Inta360NativeServiceError.missingPhotoInfo))
                }
        }
        .eraseToAnyPublisher()

    }

    /// USB command
    func setPhotographyOptions(options: INSPhotographyOptions, types: [INSPhotographyOptionsType], mode: INSCameraFunctionMode) -> AnyPublisher<Void, Error> {

        return Future<Void, Error> { [weak self] promise in
            let types: [NSNumber] = types.map { NSNumber(value: $0.rawValue) }
            self?.usbManger
                .commandManager
                .setPhotographyOptions(options, for: mode, types: types) { (error, _) in
                    if let error = error {
                        return promise(.failure(error))
                    } else {
                        return promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()

    }

    /// USB command
    func setOptions(options: INSCameraOptions, types: [INSCameraOptionsType]) -> AnyPublisher<Void, Error> {

        return Future<Void, Error> { [weak self] promise in

            let types = types.map { NSNumber(value: $0.rawValue) }
            self?.usbManger
                .commandManager
                .setOptions(options, forTypes: types) { (error, successTypes) in
                    if let error = error {
                        return promise(.failure(error))
                    } else {
                        return promise(.success(()))
                    }
                }

        }.eraseToAnyPublisher()
    }


}


#else

public class Insta360NativeService {
    public init() {

    }

    public func fetchPhoto(photoURI: String) -> AnyPublisher<Data, Error> {
        Empty().eraseToAnyPublisher()
    }

    public func connectCamera() -> AnyPublisher<Void, Error> {
        return Empty().eraseToAnyPublisher()
    }

    public func takePicture() -> AnyPublisher<String, Error> {
        return Empty().eraseToAnyPublisher()
    }
}

#endif


//    #if targetEnvironment(simulator)
//
//    public class Insta360NativeService {
//        public init() {
//
//        }
//    }
//
//
//    #else
//
//    @_implementationOnly import INSCameraSDK
//
//    public enum Inta360NativeServiceError: Error {
//        case missingPhotoInfo
//        case emptyPhotoData
//    }
//
//    public struct Insta360Notification {
//        let method: String
//        let timestamp: TimeInterval
//        let data: [NotificationKey: NotificationValue]
//
//    }
//
//    @objc
//    public class Insta360NativeService: NSObject {
//
//        var notifications: AnyPublisher<Insta360Notification, Never> {
//            _notifications.eraseToAnyPublisher()
//        }
//
//        private var _notifications: PassthroughSubject<Insta360Notification, Never> = .init()
//
//        // Communicate Wi-fi
//        private var usbManger: INSCameraManager {
//            return INSCameraManager.usb()
//        }
//
//        private var socketManager: INSCameraManager {
//            return INSCameraManager.socket()
//        }
//
//        private var sharedManager: INSCameraManager {
//            return INSCameraManager.shared()
//        }
//
//        public override init() {
//            super.init()
//        }
//
//        // MARK: - Public methods
//
//        public func connectCamera() {
//            if socketManager.cameraState == .connected {
//                //            return Just<Void>(()).eraseToAnyPublisher()
//            } else {
//                socketManager.setup()
//            }
//
//            let notifications: [NSNotification.Name] = [
//                .INSCameraBatteryStatus,
//                .INSCameraBatteryLow,
//                .INSCameraTakePictureStateUpdate,
//            ]
//
//            notifications.forEach { notification in
//                NotificationCenter.default.addObserver(
//                    self,
//                    selector: #selector(receivedNotification(notification:)),
//                    name: notification,
//                    object: nil)
//            }
//
//            socketManager
//                .addObserver(self, forKeyPath: .init("cameraState"), options: .new, context: nil)
//        }
//
//        public func fetchPhoto(photoURI: String) -> AnyPublisher<Data, Error> {
//            return Future<Data, Error> { [weak self] promise in
//                self?.sharedManager
//                    .commandManager
//                    .fetchPhoto(withURI: photoURI) { (error, data) in
//                        if let error = error {
//                            return promise(.failure(error))
//                        } else if let data = data {
//                            return promise(.success(data))
//                        }
//                        return promise(.failure(Inta360NativeServiceError.emptyPhotoData))
//                    }
//            }
//            .eraseToAnyPublisher()
//        }
//
//        public func takePicture() ->  AnyPublisher<String, Error> {
//            let options = INSTakePictureOptions()
//            return setPhotographyOptions()
//                .flatMap { [weak self] _ -> AnyPublisher<String, Error> in
//                    guard let `self` = self else { return Empty().eraseToAnyPublisher() }
//                    return self.takePicture(manager: self.sharedManager, options: options)
//                }
//                .eraseToAnyPublisher()
//        }
//
//
//        // MARK: - Private methods
//        func disconnectCamera() {
//            socketManager.shutdown()
//        }
//
//
//        @objc private func receivedNotification(notification: NSNotification) {
//    //        let timestamp = Date().timeIntervalSince1970 * 1000000000
//    //        let data = notification.userInfo
//    //        let notification = Insta360Notification(method: notification.name.rawValue, timestamp: timestamp, data: data)
//    //        switch notification.name {
//    //        case .INSCameraBatteryStatus: break
//    //        case .INSCameraBatteryLow: break
//    //        case .INSCameraTakePictureStateUpdate: break
//    //        }
//
//
//    //        if extractInfo["imageUri"] != nil {
//    //            var imageUri = extractInfo["imageUri"] as! String
//
//    //        if extractInfo["imageTimestamp"] != nil {
//    //            lastImageTimestamp = extractInfo["imageTimestamp"] as! Double
//
//    //        if extractInfo["cameraConnected"] != nil {
//    //            print("Camera connected notification!")
//
//            let nevim = notification.userInfo as? [NotificationKey: NotificationValue]
//            print(nevim)
//            print("received notification %@, info: %@)",notification.name, notification.userInfo ?? [:]);
//        }
//
//
//        func setPhotographyOptions() -> AnyPublisher<Void, Error> {
//
//            let iso: UInt = 0
//            let exposureProgram: INSCameraExposureProgram = .shutterPriority
//            let shutterSpeed: CMTimeScale = .init(0.0)
//            let exposureCompensation: Float = -1
//            let brightness: Int32 = 0
//
//            let stillExposureOptions = INSCameraExposureOptions()
//            stillExposureOptions.program = exposureProgram
//            stillExposureOptions.iso = iso
//            stillExposureOptions.shutterSpeed = .init(value: 1, timescale: shutterSpeed)
//
//            let options = INSPhotographyOptions()
//            options.stillExposure = stillExposureOptions
//            options.brightness = brightness
//            options.exposureBias = exposureCompensation
//
//            let types: [INSPhotographyOptionsType] = [
//                .stillExposureOptions,
//                .exposureBias,
//                .brightness
//            ]
//
//            return Future<Void, Error> { [weak self] promise in
//                self?.sharedManager
//                    .commandManager
//                    .setPhotographyOptions(options, for: .normalImage, types: types.map { NSNumber(value: $0.rawValue) }) { (error, successTypes) in
//                        if let error = error {
//                            return promise(.failure(error))
//                        } else if types.count == (successTypes?.count ?? 0) {
//                            return promise(.success(()))
//                        }
//                    }
//            }
//            .eraseToAnyPublisher()
//        }
//
//        func takePicture(manager: INSCameraManager, options: INSTakePictureOptions) -> AnyPublisher<String, Error> {
//
//            Future<String, Error> { promise in
//                manager
//                    .commandManager
//                    .takePicture(with: options) { (error, info) in
//                        if let error = error {
//                            return promise(.failure(error))
//                        } else if let info = info {
//                            return promise(.success(info.uri))
//                        }
//                        return promise(.failure(Inta360NativeServiceError.missingPhotoInfo))
//                    }
//            }
//            .eraseToAnyPublisher()
//
//        }
//
//        /// USB command
//        func setPhotographyOptions(options: INSPhotographyOptions, types: [INSPhotographyOptionsType], mode: INSCameraFunctionMode) -> AnyPublisher<Void, Error> {
//
//            return Future<Void, Error> { [weak self] promise in
//                let types: [NSNumber] = types.map { NSNumber(value: $0.rawValue) }
//                self?.usbManger
//                    .commandManager
//                    .setPhotographyOptions(options, for: mode, types: types) { (error, _) in
//                        if let error = error {
//                            return promise(.failure(error))
//                        } else {
//                            return promise(.success(()))
//                        }
//                    }
//            }.eraseToAnyPublisher()
//
//        }
//
//        /// USB command
//        func setOptions(options: INSCameraOptions, types: [INSCameraOptionsType]) -> AnyPublisher<Void, Error> {
//
//            return Future<Void, Error> { [weak self] promise in
//
//                let types = types.map { NSNumber(value: $0.rawValue) }
//                self?.usbManger
//                    .commandManager
//                    .setOptions(options, forTypes: types) { (error, successTypes) in
//                        if let error = error {
//                            return promise(.failure(error))
//                        } else {
//                            return promise(.success(()))
//                        }
//                    }
//
//            }.eraseToAnyPublisher()
//        }
//
//
//    }
//
//
//    #endif
//
//
//
