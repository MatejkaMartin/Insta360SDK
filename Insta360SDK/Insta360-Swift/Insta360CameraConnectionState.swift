import Foundation

/// an insta360 camera is found, but not connected, will not response
// 0. INSCameraStateFound,

/// the nano device is connected, app is able to send requests
// 1. INSCameraStateConnected,

/// connect failed
// 2. INSCameraStateConnectFailed,

/// default state, no insta360 camera is found
// 3. INSCameraStateNoConnection,

public enum Insta360CameraConnectionState: UInt {
    case found = 0
    case connected = 1
    case connectFailed
    case noConnection

    public var description: String {
        switch self {
        case .found: return "Camera found"
        case .connected: return "Connected"
        case .connectFailed: return "Connection failed"
        case .noConnection: return "No connection"
        }
    }
}
