import AppKit
import EventKit
import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            menuBar
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .font(.headline)
        .background(.ultraThinMaterial)
    }

    // MARK: - Menu Bar
    private var menuBar: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer().frame(width: 25)
                SpaceIndicatorWidget()
                Spacer()
            }

            HStack(spacing: 0) {
                Spacer()
                HStack(spacing: 15) {
                    NetworkWidget()
                    BatteryWidget()
                }
                .shadow(color: .shadow, radius: 3)
                .font(.system(size: 16))

                Spacer().frame(width: 15)
                Rectangle()
                    .fill(Color.active)
                    .frame(width: 2, height: 15)
                    .clipShape(Capsule())

                Spacer().frame(width: 15)
                TimeWidget()
                Spacer().frame(width: 25)
            }
            .foregroundStyle(Color.foregroundOutside)

        }
        .frame(height: 55)
    }
}
