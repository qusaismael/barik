import AppKit
import EventKit
import SwiftUI

/// This is the main view of the app.
struct MainView: View {
    @State private var currentTime = Date()
    @ObservedObject var viewModel = SpaceViewModel()
    @StateObject private var calendarManager = CalendarManager()
    @StateObject private var batteryManager = BatteryManager()

    // Timers for updating events, battery, and spaces.
    private let timer60 = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    private let timer1 = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let timer01 = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            menuBar
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            calendarManager.fetchNextEvent()
            batteryManager.updateBatteryStatus()
        }
        .onReceive(timer60) { _ in
            calendarManager.fetchNextEvent()
        }
        .onReceive(timer1) { date in
            currentTime = date
            batteryManager.updateBatteryStatus()
        }
        .onReceive(timer01) { _ in
            viewModel.loadSpaces()
        }
        .font(.headline)
        .background(.ultraThinMaterial)
    }

    // MARK: - Menu Bar
    private var menuBar: some View {
        ZStack {
            HStack {
                Spacer()
                HStack(spacing: 0) {
                    BatteryView(
                        level: batteryManager.batteryLevel,
                        isCharging: batteryManager.isCharging
                    )
                    .onAppear {
                        batteryManager.updateBatteryStatus()
                    }
                    
                    Spacer().frame(width: 15)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 2, height: 15)
                        .clipShape(Capsule())
                    
                    Spacer().frame(width: 15)
                }
                .font(.system(size: 15))

                HStack {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(formattedTime)
                            .fontWeight(.semibold)
                        if let event = calendarManager.nextEvent {
                            Text(eventText(for: event))
                                .foregroundStyle(Color.white.opacity(0.4))
                                .font(.subheadline)
                        }
                    }
                }
                Spacer().frame(width: 25)
            }

            HStack(spacing: 8) {
                Spacer().frame(width: 17)
                ForEach(viewModel.spaces) { space in
                    SpaceView(space: space)
                }
                Spacer()
            }
            .animation(.smooth(duration: 0.3), value: viewModel.spaces)
        }
        .frame(height: 55)
    }

    // Format the current time.
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d, h:mm"
        return formatter.string(from: currentTime)
    }

    // Create text for the calendar event.
    private func eventText(for event: EKEvent) -> String {
        var text = event.title ?? ""
        if !event.isAllDay {
            text += " ("
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm"
            text += formatter.string(from: event.startDate)
            text += ")"
        }
        return text
    }
}

/// This view shows the battery status.
struct BatteryView: View {
    let level: Int
    let isCharging: Bool

    var body: some View {
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
        if isCharging {
            return level > 60 ? .primary : .black
        } else {
            return level > 20 ? .black.opacity(0.6) : .black
        }
    }

    private var batteryColor: Color {
        if isCharging {
            return .green
        } else {
            if level <= 10 {
                return .red
            } else if level <= 20 {
                return .yellow
            } else {
                return .white.opacity(0.8)
            }
        }
    }
}

/// This view shows the battery text and the charging icon.
struct BatteryText: View {
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
struct BatteryBodyView: View {
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

/// This view shows a space with its windows.
struct SpaceView: View {
    let space: SpaceEntity

    var body: some View {
        let isFocused = space.windows.contains { $0.isFocused }
        HStack(spacing: 8) {
            Spacer().frame(width: 2)
            Text("\(space.id)")
                .font(.headline)
                .frame(minWidth: 15)
                .fixedSize(horizontal: true, vertical: false)
            ForEach(space.windows) { window in
                WindowView(window: window, space: space)
            }
            Spacer().frame(width: 2)
        }
        .frame(height: 30)
        .background(isFocused ? Color.white.opacity(0.4) : Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(radius: 2)
        .transition(.blurReplace)
    }
}

/// This view shows a window and its icon.
struct WindowView: View {
    let window: WindowEntity
    let space: SpaceEntity

    var body: some View {
        let size: CGFloat = 21
        // Use the window title if there are more than one window of the same app.
        let title =
            space.windows.filter { $0.appName == window.appName }.count > 1
            ? window.title : (window.appName ?? "")
        let spaceIsFocused = space.windows.contains { $0.isFocused }
        HStack {
            ZStack {
                if let icon = window.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: size, height: size)
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 2)
                } else {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: size, height: size)
                }
            }
            .opacity(spaceIsFocused && !window.isFocused ? 0.5 : 1)
            .transition(.blurReplace)

            if window.isFocused, !title.isEmpty {
                HStack {
                    Text(title)
                        .fixedSize(horizontal: true, vertical: false)
                        .shadow(radius: 3)
                    Spacer().frame(width: 5)
                }
                .transition(.blurReplace)
            }
        }
    }
}
