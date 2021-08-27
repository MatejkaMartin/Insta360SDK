import Combine
import Foundation
import Network
import NetworkExtension

public class Insta360WifiService {

    public var isConnectedToWifiConnected: Bool {
        return ssid.currentSSID?.hasSuffix(cameraWifiSuffix) ?? false
    }

    /// This property returns correct value after cc. 1.5 sec after is called startAccessibilityGatewayObservation()
    public var isAcessibleCameraGateway: Bool {
        isAcessibleCameraGateway(for: monitor.currentPath)
    }

    public var isAcessibleCameraGatewayPublisher: AnyPublisher<Bool, Never> {
        _isAccessibleCameraGatewaySubject.eraseToAnyPublisher()
    }

    public var isRunningGatewayObservation: Bool = false

    private let ssid: SSID = .init()
    private let _isAccessibleCameraGatewaySubject = CurrentValueSubject<
        Bool, Never
    >(false)
    private var monitor: NWPathMonitor = NWPathMonitor(
        requiredInterfaceType: .wifi
    )
    private let cameraGateway: String = "192.168.42.1"
    private let monitorQueue: DispatchQueue = .init(
        label: "rc.sphericalCamera.wifiObservervation.monitor"
    )

    private let cameraWifiSuffix: String = ".OSC"

    public init() {

    }

    // MARK: - Public methods

    public func connectToWifi(
        ssid: String,
        password: String
    ) -> AnyPublisher<Void, Error> {

        let ssidWithSuffix =
            ssid.hasSuffix(cameraWifiSuffix) ? ssid : ssid + cameraWifiSuffix
        let configuration = NEHotspotConfiguration.init(
            ssid: ssidWithSuffix.uppercased(),
            passphrase: password,
            isWEP: false
        )
        configuration.joinOnce = true

        // NOTE: Apple has a bug. It can has no error but it failed.
        // https://stackoverflow.com/questions/36303123/ios-how-to-programmatically-connect-to-a-wifi-network-given-the-ssid-and-passw
        NEHotspotConfigurationManager.shared.removeConfiguration(
            forSSID: ssidWithSuffix
        )

        NEHotspotConfigurationManager.shared.getConfiguredSSIDs { ssids in
            ssids.forEach {
                NEHotspotConfigurationManager.shared.removeConfiguration(
                    forSSID: $0
                )
            }
        }

        return Future { promise in
            NEHotspotConfigurationManager.shared.apply(configuration) {
                [weak self] (error) in
                guard let `self` = self else { return }
                let ssid = self.ssid.currentSSID
                print("[WIFI] Current SSID: \(ssid ?? "Unknown")")
                if let currentSSID = ssid,
                    ssidWithSuffix == currentSSID
                {
                    promise(.success(()))
                } else {
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(
                            .failure(
                                Insta360WifiServiceError
                                    .unknownReasonIfTryToConnectCameraWifi
                            )
                        )
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    public func startAccessibilityGatewayObservation() {
        setupAccessibilityGatewayObservation()
    }

    // MARK: - Private methods

    private func setupAccessibilityGatewayObservation() {
        guard !isRunningGatewayObservation else { return }
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.schedule {
                self._isAccessibleCameraGatewaySubject.send(
                    self.isAcessibleCameraGateway(for: path)
                )
            }
        }

        monitor.start(queue: monitorQueue)
        isRunningGatewayObservation = true
    }

    private func isAcessibleCameraGateway(for path: Network.NWPath) -> Bool {
        if path.status == .satisfied {
            switch path.status {
            case .satisfied:
                return path.gateways.first { endpoint in
                    switch endpoint {
                    case .hostPort(let host, port: _):
                        switch host {
                        case .ipv4(let address):
                            return cameraGateway
                                == address.debugDescription
                        default:
                            return false
                        }
                    default:
                        return false
                    }
                } != nil
            case .unsatisfied:
                return false
            case .requiresConnection:
                return false
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }

}

extension Insta360WifiService {

    public enum Insta360WifiServiceError: LocalizedError {
        case unknownReasonIfTryToConnectCameraWifi

        public var errorDescription: String? {
            switch self {
            case .unknownReasonIfTryToConnectCameraWifi:
                return
                    "Something goes wrong with connection to the camera Wifi. Please try it again or try turn on/off the camera."
            }
        }
    }

}
