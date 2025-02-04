import EventKit
import SwiftUI

struct TimeWidget: View {
    @State private var currentTime = Date()
    @StateObject private var calendarManager = CalendarManager()

    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(formattedTime)
                .fontWeight(.semibold)
            if let event = calendarManager.nextEvent {
                Text(eventText(for: event))
                    .foregroundStyle(Color.noActive)
                    .font(.subheadline)
            }
        }
        .shadow(color: .foregroundShadowOutside, radius: 3)
        .onReceive(timer) { date in
            currentTime = date
        }
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

struct TimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            TimeWidget()
        }.frame(width: 500, height: 100)
    }
}
