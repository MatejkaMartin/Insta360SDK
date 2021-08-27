import CoreLocation
import Foundation
import SystemConfiguration.CaptiveNetwork

// Note: Inspired at: https://github.com/HackingGate/iOS13-WiFi-Info
public class SSID: NSObject, CLLocationManagerDelegate {

    public var currentSSID: String? {
        currentNetworkInfos?.first?.ssid
    }

    private var locationManager = CLLocationManager()
    private var currentNetworkInfos: [NetworkInfo]? {
        return fetchNetworkInfo()
    }

    override init() {
        super.init()
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            updateWiFi()
        } else {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func updateWiFi() {
        print("SSID: \(currentNetworkInfos?.first?.ssid ?? "")")
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        if status == .authorizedWhenInUse {
            updateWiFi()
        }
    }

    private func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces() {
            var networkInfos = [NetworkInfo]()
            for interface in interfaces {
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(
                    interface: interfaceName,
                    success: false,
                    ssid: nil,
                    bssid: nil
                )
                if let dict = CNCopyCurrentNetworkInfo(
                    interfaceName as CFString
                ) as NSDictionary? {
                    networkInfo.success = true
                    networkInfo.ssid =
                        dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid =
                        dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append(networkInfo)
            }
            return networkInfos
        }
        return nil
    }

    private struct NetworkInfo {
        var interface: String
        var success: Bool = false
        var ssid: String?
        var bssid: String?
    }
}
