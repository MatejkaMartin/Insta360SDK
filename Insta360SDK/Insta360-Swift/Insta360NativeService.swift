import Combine
import Foundation
import NetworkExtension
import INSCameraSDK

public protocol Insta360NativeServicing {

    var isConnected: AnyPublisher<Bool, Never> { get }

    var connectionState: AnyPublisher<Insta360CameraConnectionState, Never> {
        get
    }
    var cameraDevice: AnyPublisher<Insta360CameraDevice?, Never> { get }
    var notifications: AnyPublisher<Insta360Notification, Never> { get }

    func tryConnect() -> AnyPublisher<Bool, Never>
    func connect(ssid: String, password: String) -> AnyPublisher<Void, Error>
    func takePicture() -> AnyPublisher<(String, Double), Error>
    func takePictureFetchImageAndDeleteFromCamera() -> AnyPublisher<
        (Data, Double), Error
    >
    func fetchPhoto(photoURI: String) -> AnyPublisher<Data, Error>
    func takePictureWithoutStoring() -> AnyPublisher<(Data, Double), Error>
    func disconnectCamera()

    init(wifiService: Insta360WifiService)

}

#if targetEnvironment(simulator)

    public class Insta360NativeService: Insta360NativeServicing {

        public var isConnected: AnyPublisher<Bool, Never> {
            return Empty().eraseToAnyPublisher()
        }

        public var connectionState:
            AnyPublisher<Insta360CameraConnectionState, Never>
        {
            return Empty().eraseToAnyPublisher()
        }

        public var cameraDevice: AnyPublisher<Insta360CameraDevice?, Never> {
            return Empty().eraseToAnyPublisher()
        }

        public var notifications: AnyPublisher<Insta360Notification, Never> {
            return Empty().eraseToAnyPublisher()
        }

        public func tryConnect() -> AnyPublisher<Bool, Never> {
            return Empty().eraseToAnyPublisher()
        }

        public func connect(ssid: String, password: String) -> AnyPublisher<
            Void, Error
        > {
            return Empty().eraseToAnyPublisher()
        }

        public func takePicture() -> AnyPublisher<(String, Double), Error> {
            return Empty().eraseToAnyPublisher()
        }

        public func takePictureFetchImageAndDeleteFromCamera() -> AnyPublisher<
            (Data, Double), Error
        > {
            return Empty().eraseToAnyPublisher()
        }

        public func fetchPhoto(photoURI: String) -> AnyPublisher<Data, Error> {
            return Empty().eraseToAnyPublisher()
        }

        public func takePictureWithoutStoring() -> AnyPublisher<
            (Data, Double), Error
        > {
            return Empty().eraseToAnyPublisher()
        }

        public func disconnectCamera() {

        }

        required public init(wifiService: Insta360WifiService) {

        }

    }

#else

    @_implementationOnly import INSCameraSDK

    public class Insta360NativeService: Insta360NativeServicing {

        // MARK: - Public properties

        public var isConnected: AnyPublisher<Bool, Never> {
            return connectionState.filter {
                $0 == .connected || $0 == .noConnection
            }.map { $0 == .connected }.eraseToAnyPublisher()
        }

        public var connectionState:
            AnyPublisher<Insta360CameraConnectionState, Never>
        {
            _connectionState.eraseToAnyPublisher()
        }

        public var cameraDevice: AnyPublisher<Insta360CameraDevice?, Never> {
            _cameraDevice.eraseToAnyPublisher()
        }

        public var notifications: AnyPublisher<Insta360Notification, Never> {
            _receivedNotifications.eraseToAnyPublisher()
        }

        // MARK: - Private properties

        private var socketManager: INSCameraManager {
            return INSCameraManager.socket()
        }

        private let wifiService: Insta360WifiService

        // Combine
        private let _receivedNotifications:
            PassthroughSubject<Insta360Notification, Never> = .init()
        private let _connectionState:
            CurrentValueSubject<Insta360CameraConnectionState, Never> = .init(
                .noConnection
            )
        private let _cameraDevice:
            CurrentValueSubject<Insta360CameraDevice?, Never> = .init(nil)
        private var cancelables: Set<AnyCancellable> = Set()

        // Camera
        private var heartbeatTimer: Cancellable?
        private var heartbeatCancelabe: Cancellable?
        private var cameraCancelables: Set<AnyCancellable> = Set()

        required public init(wifiService: Insta360WifiService) {
            self.wifiService = wifiService
            setupSubscriptions()
        }

        // MARK: - Setup methods

        private func setupSubscriptions() {

            _connectionState
                .sink { [weak self] state in
                    switch state {
                    case .found: break
                    case .connected:
                        self?.startSendingHeartbeats()
                        self?.setupCameraNotifications()
                    case .connectFailed:
                        self?.stopSendingHeartbeats()
                        self?.cancelCameraNotifications()
                    case .noConnection:
                        self?.stopSendingHeartbeats()
                        self?.cancelCameraNotifications()
                    }
                }
                .store(in: &cancelables)

            _connectionState
                .sink { [weak self] state in
                    switch state {
                    case .connected:
                        guard let camera = self?.socketManager.currentCamera
                        else {
                            return
                        }
                        let cameraDevice = Insta360CameraDevice(
                            type: camera.cameraType,
                            serialNumber: camera.serialNumber,
                            firmware: camera.firmwareRevision
                        )
                        self?._cameraDevice.send(cameraDevice)
                    default: break
                    }
                }
                .store(in: &cancelables)

            socketManager
                .publisher(for: \.cameraState)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in

                    let state =
                        Insta360CameraConnectionState(rawValue: state.rawValue)
                        ?? .noConnection
                    self?._connectionState.send(state)
                }
                .store(in: &cancelables)

        }

        // MARK: - Public methods

        public func tryConnect() -> AnyPublisher<Bool, Never> {

            Just(wifiService.isConnectedToWifiConnected)
                .handleEvents(receiveOutput: { [weak self] isConnectedToWifi in
                    isConnectedToWifi ? self?.setupCamera() : {}()
                })
                .flatMap {
                    [weak self] isConnectedToWifi -> AnyPublisher<Bool, Never>
                    in
                    guard isConnectedToWifi else {
                        return Just(false).eraseToAnyPublisher()
                    }
                    guard let `self` = self else {
                        return Empty().eraseToAnyPublisher()
                    }
                    return self.isConnected.first(where: { $0 })
                        .eraseToAnyPublisher()
                }
                .delay(for: 1.5, scheduler: DispatchQueue.main)
                .timeout(3, scheduler: DispatchQueue.main)
                .replaceError(with: false)
                .eraseToAnyPublisher()
        }

        public func connect(
            ssid: String,
            password: String
        ) -> AnyPublisher<Void, Error> {

            return
                wifiService
                .connectToWifi(ssid: ssid, password: password)
                .handleEvents(receiveOutput: { [weak self] _ in
                    self?.setupCamera()
                })
                .eraseToAnyPublisher()
        }

        public func takePictureFetchImageAndDeleteFromCamera() -> AnyPublisher<
            (Data, Double), Error
        > {

            let timeStampPublisher =
                _receivedNotifications
                .first(where: {
                    $0 is NotificationTakePictureUpdate
                })
                .map { $0.timestamp }
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()

            let takePictureOptions = INSTakePictureOptions()
            let takePicturePublisher = takePicture(with: takePictureOptions)
                .flatMap {
                    [weak self] photoURI -> AnyPublisher<(Data, String), Error>
                    in
                    guard let `self` = self else {
                        return Empty().setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    return self.fetchPhoto(photoURI: photoURI)
                        .map { ($0, photoURI) }
                        .eraseToAnyPublisher()
                }
                .flatMap {
                    [weak self] data, photoURI -> AnyPublisher<Data, Error> in
                    guard let `self` = self else {
                        return Empty().setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    return self.delete(fileURI: photoURI)
                        .map { _ in return data }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()

            let takePictureWithTimestampPublisher =
                Publishers.Zip(takePicturePublisher, timeStampPublisher)
                .timeout(10, scheduler: DispatchQueue.main) {
                    return Insta360NativeServiceError.takePictureTakeTooLong
                }
                .first()
                .eraseToAnyPublisher()

            return setPhotographyOptions()
                .flatMap { _ -> AnyPublisher<(Data, Double), Error> in
                    return takePictureWithTimestampPublisher

                }
                .eraseToAnyPublisher()
        }

        public func takePicture() -> AnyPublisher<(String, Double), Error> {

            let timeStampPublisher =
                _receivedNotifications
                .first(where: {
                    $0 is NotificationTakePictureUpdate
                })
                .map { $0.timestamp }
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()

            let options = INSTakePictureOptions()
            let takePicturePublisher = self.takePicture(
                with: options
            ).eraseToAnyPublisher()

            let takePictureWithTimestampPublisher =
                Publishers.Zip(takePicturePublisher, timeStampPublisher)
                .timeout(10, scheduler: DispatchQueue.main) {
                    return Insta360NativeServiceError.takePictureTakeTooLong
                }
                .first()
                .eraseToAnyPublisher()

            return setPhotographyOptions()
                .flatMap { _ -> AnyPublisher<(String, Double), Error> in
                    return takePictureWithTimestampPublisher
                }
                .eraseToAnyPublisher()
        }

        public func takePictureWithoutStoring() -> AnyPublisher<
            (Data, Double), Error
        > {

            let timeStampPublisher =
                _receivedNotifications
                .first(where: {
                    $0 is NotificationTakePictureUpdate
                })
                .map { $0.timestamp }
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()

            let takePictureOptions = INSTakePictureOptions()

            let takePictureWithTimestampPublisher =
                Publishers.Zip(
                    takePictureWithoutStoring(with: takePictureOptions),
                    timeStampPublisher
                )
                .timeout(10, scheduler: DispatchQueue.main) {
                    return Insta360NativeServiceError.takePictureTakeTooLong
                }
                .first()
                .eraseToAnyPublisher()

            return setPhotographyOptions()
                .flatMap { _ -> AnyPublisher<(Data, Double), Error> in
                    return takePictureWithTimestampPublisher

                }
                .eraseToAnyPublisher()
        }

        public func fetchPhoto(photoURI: String) -> AnyPublisher<Data, Error> {
            return Future<Data, Error> { [weak self] promise in
                self?.socketManager
                    .commandManager
                    .fetchPhoto(withURI: photoURI) { (error, data) in
                        if let error = error {
                            return promise(.failure(error))
                        } else if let data = data {
                            return promise(.success(data))
                        }
                        return promise(
                            .failure(Insta360NativeServiceError.emptyPhotoData)
                        )
                    }
            }
            .eraseToAnyPublisher()
        }

        public func disconnectCamera() {
            socketManager.shutdown()
            stopSendingHeartbeats()
            cancelCameraNotifications()
        }

        // MARK: - Private methods

        private func setupCamera() {
            if socketManager.cameraState == .connected {
            } else {
                socketManager.setup()
            }
        }

        private func setupCameraNotifications() {

            let notifications: [NSNotification.Name] = [
                .INSCameraBatteryStatus,
                .INSCameraBatteryLow,
                .INSCameraTakePictureStateUpdate,
                .INSCameraAuthorizationResult,
                .INSCameraTemperatureStatus,
                .INSCameraStorageStatus,
                .INSCameraStorageFull,
            ]

            notifications.forEach { notification in
                NotificationCenter
                    .default
                    .publisher(for: notification)
                    .sink { [weak self] notification in
                        self?.receivedNotification(notification: notification)
                    }
                    .store(in: &cameraCancelables)
            }
        }

        private func cancelCameraNotifications() {
            cameraCancelables.removeAll()
        }

        private func startSendingHeartbeats() {
            stopSendingHeartbeats()
            print("[Heartbeat] Start")
            let timer = Timer.TimerPublisher(
                interval: 2.0,
                tolerance: 0.5,
                runLoop: .current,
                mode: .default
            )

            heartbeatCancelabe =
                timer
                .sink { [weak self] _ in
                    print("[Heartbeat] Beat")
                    self?.socketManager
                        .commandManager
                        .sendHeartbeats(with: nil)
                }

            heartbeatTimer = timer.connect()
        }

        private func stopSendingHeartbeats() {
            print("[Heartbeat] Stop")
            heartbeatTimer?.cancel()
            heartbeatCancelabe?.cancel()
            heartbeatTimer = nil
        }

        @objc private func receivedNotification(notification: Notification) {

            let timestamp = Date().timeIntervalSince1970 * 1_000_000_000

            switch notification.name {
            case .INSCameraTakePictureStateUpdate:
                guard let info = notification.userInfo as? [String: Int],
                    let stateValue = info.first?.value,
                    let state = NotificationTakePictureUpdate.TakePictureState(
                        rawValue: stateValue
                    )
                else { return }
                let knownNotification = NotificationTakePictureUpdate(
                    timestamp: timestamp,
                    state: state
                )
                _receivedNotifications.send(knownNotification)

            //            .INSCameraBatteryStatus,
            //            .INSCameraBatteryLow,
            //            .INSCameraTakePictureStateUpdate,
            //            .INSCameraAuthorizationResult,
            //            .INSCameraTemperatureStatus,
            //            .INSCameraStorageStatus,
            //            .INSCameraStorageFull

            default:
                print(
                    "received not handled notification \(notification.name), info: \(notification.userInfo ?? [:])"
                )
                break
            }
        }

        private func delete(fileURI: String) -> AnyPublisher<Void, Error> {
            Future<Void, Error> { [weak self] promise in
                self?.socketManager
                    .commandManager
                    .deleteFiles([fileURI]) { maybeError in
                        if let error = maybeError {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
            }
            .eraseToAnyPublisher()

        }

        private func setPhotographyOptions() -> AnyPublisher<Void, Error> {

            let iso: UInt = 0
            let exposureProgram: INSCameraExposureProgram = .auto
            let shutterSpeed: CMTimeScale = .init(0.0)
            let exposureCompensation: Float = 0
            let brightness: Int32 = 0

            let stillExposureOptions = INSCameraExposureOptions()
            stillExposureOptions.program = exposureProgram
            stillExposureOptions.iso = iso
            stillExposureOptions.shutterSpeed = .init(
                value: 1,
                timescale: shutterSpeed
            )

            let options = INSPhotographyOptions()
            options.stillExposure = stillExposureOptions
            options.brightness = brightness
            options.exposureBias = exposureCompensation
            options.rawCaptureType = .OFF

            let types: [INSPhotographyOptionsType] = [
                .stillExposureOptions,
                .exposureBias,
                .brightness,
                .rawCaptureType,
            ]

            return Future<Void, Error> { [weak self] promise in
                self?.socketManager
                    .commandManager
                    .setPhotographyOptions(
                        options,
                        for: .normalImage,
                        types: types.map { NSNumber(value: $0.rawValue) }
                    ) { (error, successTypes) in
                        if let error = error {
                            return promise(.failure(error))
                        } else if types.count == (successTypes?.count ?? 0) {
                            return promise(.success(()))
                        }
                    }
            }
            .eraseToAnyPublisher()
        }

        private func takePicture(with options: INSTakePictureOptions)
            -> AnyPublisher<String, Error>
        {

            Future<String, Error> { [weak self] promise in
                self?.socketManager
                    .commandManager
                    .takePicture(with: options) { (error, info) in
                        if let error = error {
                            return promise(.failure(error))
                        } else if let info = info {
                            return promise(.success(info.uri))
                        }
                        return promise(
                            .failure(
                                Insta360NativeServiceError.missingPhotoInfo
                            )
                        )
                    }
            }
            .eraseToAnyPublisher()
        }

        private func takePictureWithoutStoring(
            with options: INSTakePictureOptions
        )
            -> AnyPublisher<Data, Error>
        {

            Future<Data, Error> { [weak self] promise in
                self?.socketManager
                    .commandManager
                    .takePictureWithoutStoring(
                        with: options,
                        completion: { (maybeError, maybeData) in
                            if let error = maybeError {
                                return promise(.failure(error))
                            } else if let data = maybeData {
                                return promise(.success(data))
                            } else {
                                return promise(
                                    .failure(
                                        Insta360NativeServiceError
                                            .missingPhotoInfo
                                    )
                                )
                            }
                        }
                    )
            }
            .eraseToAnyPublisher()
        }

        private func setPhotographyOptions(
            options: INSPhotographyOptions,
            types: [INSPhotographyOptionsType],
            mode: INSCameraFunctionMode
        ) -> AnyPublisher<Void, Error> {

            return Future<Void, Error> { [weak self] promise in
                let types: [NSNumber] = types.map {
                    NSNumber(value: $0.rawValue)
                }
                self?.socketManager
                    .commandManager
                    .setPhotographyOptions(options, for: mode, types: types) {
                        (error, _) in
                        if let error = error {
                            return promise(.failure(error))
                        } else {
                            return promise(.success(()))
                        }
                    }
            }.eraseToAnyPublisher()

        }

        private func setOptions(
            options: INSCameraOptions,
            types: [INSCameraOptionsType]
        )
            -> AnyPublisher<Void, Error>
        {

            return Future<Void, Error> { [weak self] promise in

                let types = types.map { NSNumber(value: $0.rawValue) }
                self?.socketManager
                    .commandManager
                    .setOptions(options, forTypes: types) {
                        (error, successTypes) in
                        if let error = error {
                            return promise(.failure(error))
                        } else {
                            return promise(.success(()))
                        }
                    }
            }.eraseToAnyPublisher()
        }

    }

#endif

extension Insta360NativeService {

    public enum Insta360NativeServiceError: LocalizedError {
        case missingPhotoInfo
        case emptyPhotoData
        case takePictureTakeTooLong

        public var errorDescription: String? {
            switch self {
            case .missingPhotoInfo:
                return
                    "Take picture was successfully but we did not received the URL of the picture to download it. Please try it again."
            case .emptyPhotoData:
                return
                    "Take picture was successfully but we received the empty data. Please try it again."
            case .takePictureTakeTooLong:
                return
                    "Take picture take too long. Please try it again or try restart the camera."

            }
        }
    }

}
