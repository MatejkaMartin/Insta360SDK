import Foundation

public protocol Insta360Notification {
    var method: String { get }
    var timestamp: TimeInterval { get }
}

#if targetEnvironment(simulator)

    public struct NotificationTakePictureUpdate: Insta360Notification {
        public let method: String = "SimulatorPlaceholder"
        public var timestamp: TimeInterval
        public var state: TakePictureState

        public enum TakePictureState: Int {
            case prepare
            case shutter
            case compress
            case writeToFile
        }
    }

#else

    public struct NotificationTakePictureUpdate: Insta360Notification {
        public let method: String = Notification.Name
            .INSCameraTakePictureStateUpdate.rawValue
        public var timestamp: TimeInterval
        public var state: TakePictureState

        public enum TakePictureState: Int {
            case prepare
            case shutter
            case compress
            case writeToFile
        }
    }

#endif
