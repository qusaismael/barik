import Combine
import EventKit
import Foundation
import SwiftUICore

/// This class fetches the next calendar event.
class CalendarManager: ObservableObject {
    let configProvider: ConfigProvider
    var config: ConfigData? {
        configProvider.config["calendar"]?.dictionaryValue
    }
    var allowList: [String] {
        Array(
            (config?["allow-list"]?.arrayValue?.map { $0.stringValue ?? "" }
                .drop(while: { $0 == "" })) ?? [])
    }
    var denyList: [String] {
        Array(
            (config?["deny-list"]?.arrayValue?.map { $0.stringValue ?? "" }
                .drop(while: { $0 == "" })) ?? [])
    }

    @Published var nextEvent: EKEvent? = nil
    private let eventStore = EKEventStore()
    private var timer: Timer?

    init(configProvider: ConfigProvider) {
        self.configProvider = configProvider
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
        let currentCalendar = Calendar.current

        guard
            let endOfDay = currentCalendar.date(
                bySettingHour: 23, minute: 59, second: 59, of: now)
        else {
            print("Failed to determine end of day.")
            return
        }

        let predicate = eventStore.predicateForEvents(
            withStart: now, end: endOfDay, calendars: calendars)
        let events = eventStore.events(matching: predicate).sorted {
            $0.startDate < $1.startDate
        }

        var filteredEvents = events
        if !allowList.isEmpty {
            let allowed = events.filter {
                allowList.contains($0.calendar.title)
            }
            filteredEvents = allowed
        }
        if !denyList.isEmpty {
            filteredEvents = filteredEvents.filter {
                !denyList.contains($0.calendar.title)
            }
        }

        let regularEvents = filteredEvents.filter { !$0.isAllDay }
        let nextEvent =
            !regularEvents.isEmpty ? regularEvents.first : filteredEvents.first

        DispatchQueue.main.async {
            self.nextEvent = nextEvent
        }
    }
}
