import Network
import SwiftUI

/// Shows current network interface status.
class NetworkManager: ObservableObject {
    @Published var wifiStatus: NetworkState = .disconnected
    @Published var ethernetStatus: NetworkState = .disconnected

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            DispatchQueue.main.async {
                // MARK: - Wi-Fi

                if path.availableInterfaces.contains(where: { $0.type == .wifi }
                ) {
                    if path.usesInterfaceType(.wifi) {
                        switch path.status {
                        case .satisfied:
                            self.wifiStatus = .connected
                        case .requiresConnection:
                            self.wifiStatus = .connecting
                        default:
                            self.wifiStatus = .connectedWithoutInternet
                        }
                    } else {
                        self.wifiStatus = .connectedWithoutInternet
                    }
                } else {
                    // Wi-Fi interface not found
                    self.wifiStatus = .notSupported
                }

                // MARK: - Ethernet

                if path.availableInterfaces.contains(where: {
                    $0.type == .wiredEthernet
                }) {
                    if path.usesInterfaceType(.wiredEthernet) {
                        switch path.status {
                        case .satisfied:
                            self.ethernetStatus = .connected
                        case .requiresConnection:
                            self.ethernetStatus = .connecting
                        default:
                            self.ethernetStatus = .disconnected
                        }
                    } else {
                        // Ethernet is physically present but not the current interface
                        self.ethernetStatus = .disconnected
                    }
                } else {
                    // Ethernet not found
                    self.ethernetStatus = .notSupported
                }
            }
        }

        monitor.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor.cancel()
    }
}

enum NetworkState {
    case connected
    case connectedWithoutInternet
    case connecting
    case disconnected
    case notSupported
}
