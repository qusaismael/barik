import AppKit
import EventKit
import SwiftUI

struct MenuBarView: View {
    var body: some View {
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

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView().background(.black)
    }
}
