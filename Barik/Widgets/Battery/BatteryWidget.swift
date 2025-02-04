import SwiftUICore

/// This view shows the battery status.
struct BatteryWidget: View {
    @StateObject private var batteryManager = BatteryManager()

    var body: some View {
        let level = batteryManager.batteryLevel
        let isCharging = batteryManager.isCharging

        ZStack(alignment: .leading) {
            BatteryBodyView()
                .opacity(0.3)
            BatteryBodyView()
                .clipShape(
                    Rectangle().path(
                        in: CGRect(
                            x: 0,
                            y: 0,
                            width: 30 * Int(level) / 110,
                            height: .bitWidth
                        )
                    )
                )
                .foregroundStyle(batteryColor)
            BatteryText(level: level, isCharging: isCharging)
                .foregroundStyle(batteryTextColor)
        }
        .frame(width: 30, height: 10)
    }

    private var batteryTextColor: Color {
        let level = batteryManager.batteryLevel
        let isCharging = batteryManager.isCharging

        if isCharging {
            return .foregroundOutsideInvert
        } else {
            return level > 20 ? .foregroundOutsideInvert : .black
        }
    }

    private var batteryColor: Color {
        let level = batteryManager.batteryLevel
        let isCharging = batteryManager.isCharging

        if isCharging {
            return .green
        } else {
            if level <= 10 {
                return .red
            } else if level <= 20 {
                return .yellow
            } else {
                return .icon
            }
        }
    }
}

/// This view shows the battery text and the charging icon.
private struct BatteryText: View {
    let level: Int
    let isCharging: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("\(level)")
                .font(.system(size: 12))
            if isCharging && level != 100 {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 8))
                    .transition(.blurReplace)
            }
        }
        .fontWeight(.semibold)
        .animation(.smooth, value: isCharging)
        .frame(width: 26)
    }
}

/// This view draws the battery body.
private struct BatteryBodyView: View {
    var body: some View {
        ZStack {
            Image(systemName: "battery.0")
                .resizable()
                .scaledToFit()
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.horizontal, 3)
                .padding(.vertical, 2)
                .offset(x: -2)
        }
        .compositingGroup()
    }
}
