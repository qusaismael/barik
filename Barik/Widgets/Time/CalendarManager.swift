import Combine
import EventKit
import Foundation

/// This class fetches the next calendar event.
class CalendarManager: ObservableObject {
    @Published var nextEvent: EKEvent? = nil
    private let eventStore = EKEventStore()
    private var timer: Timer?

    init() {
        requestAccess()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
            [weak self] _ in
            self?.fetchNextEvent()
        }
        fetchNextEvent()
    }

    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func requestAccess() {
        eventStore.requestFullAccessToEvents { [weak self] granted, error in
            if granted && error == nil {
                self?.fetchNextEvent()
            } else {
                print(
                    "Calendar access not granted: \(String(describing: error))")
            }
        }
    }

    func fetchNextEvent() {
        let calendars = eventStore.calendars(for: .event)
        let now = Date()
        let calendar = Calendar.current

        guard
            let endOfDay = calendar.date(
                bySettingHour: 23,
                minute: 59,
                second: 59,
                of: now)
        else {
            print("Failed to determine end of day.")
            return
        }

        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: endOfDay,
            calendars: calendars)

        let events = eventStore.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }

        let regularEvents = events.filter { !$0.isAllDay }

        let nextEvent =
            regularEvents.isEmpty
                ? events.first
                : regularEvents.first

        DispatchQueue.main.async {
            self.nextEvent = nextEvent
        }
    }
}
