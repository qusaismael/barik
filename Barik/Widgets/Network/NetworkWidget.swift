import SwiftUI

/// A widget that shows network status icons for Wi-Fi and Ethernet.
struct NetworkWidget: View {
    @StateObject private var networkManager = NetworkManager()

    var body: some View {
        HStack(spacing: 15) {
            if networkManager.wifiStatus != .notSupported {
                wifiIcon
            }

            if networkManager.ethernetStatus != .notSupported {
                ethernetIcon
            }
        }.font(.system(size: 15))
    }

    /// View for Wi-Fi icon based on current state.
    private var wifiIcon: some View {
        switch networkManager.wifiStatus {
        case .connected:
            Image(systemName: "wifi")
                .foregroundColor(.foregroundOutside)
        case .connectedWithoutInternet:
            Image(systemName: "wifi.exclamationmark")
                .foregroundColor(.yellow)
        case .connecting:
            Image(systemName: "wifi")
                .foregroundColor(.yellow)
        case .disconnected:
            Image(systemName: "wifi.slash")
                .foregroundColor(.red)
        case .notSupported:
            Image(systemName: "wifi.exclamationmark")
                .foregroundColor(.gray)
        }
    }

    /// View for Ethernet icon based on current state.
    private var ethernetIcon: some View {
        switch networkManager.ethernetStatus {
        case .connected:
            Image(systemName: "network")
                .foregroundColor(.foregroundOutside)
        case .connectedWithoutInternet:
            Image(systemName: "network")
                .foregroundColor(.yellow)
        case .connecting:
            Image(systemName: "network.slash")
                .foregroundColor(.yellow)
        case .disconnected:
            Image(systemName: "network.slash")
                .foregroundColor(.red)
        case .notSupported:
            Image(systemName: "questionmark.circle")
                .foregroundColor(.gray)
        }
    }
}

struct NetworkWidget_Previews: PreviewProvider {
    static var previews: some View {
        NetworkWidget()
            .frame(width: 200, height: 100)
            .background(.black)
            .environmentObject(ConfigProvider(config: [:]))
    }
}
