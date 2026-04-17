import Foundation
import Combine

struct SelectedDayMetrics {
    let date: Date
    let wearMinutes: Double
    let removalMinutes: Double
    let sessionsCount: Int
    let goalDelta: Double
    let complianceStatus: DayComplianceStatus
    let sessions: [DaySession]
}

struct DaySession: Identifiable {
    let id: UUID
    let removedAt: Date
    let putBackAt: Date?
    let durationMinutes: Double
}

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published private(set) var sessions: [RemovalSession] = []
    @Published private(set) var settings: TrackerSettings = .default
    @Published private(set) var trays: [Tray] = []
    @Published var viewYear: Int
    @Published var viewMonth: Int
    @Published private(set) var now = Date()
    @Published var selectedDate: Date?

    private let store: TrackingStore
    private var timer: AnyCancellable?

    init(store: TrackingStore) {
        self.store = store
        let comps = DateService.calendar.dateComponents([.year, .month], from: Date())
        self.viewYear = comps.year ?? 2026
        self.viewMonth = comps.month ?? 1

        store.$sessions.assign(to: &$sessions)
        store.$settings.assign(to: &$settings)
        store.$trays.assign(to: &$trays)

        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] value in
                self?.now = value
            }
    }

    deinit { timer?.cancel() }

    var targetMinutes: Double { Double(settings.targetHoursPerDay * 60) }
    var graceMinutes: Double { Double(settings.graceMinutes) }
    
    var currentTray: Tray? {
        if let id = settings.currentTrayID {
            return trays.first(where: { $0.id == id })
        }
        return trays.first
    }

    var monthDate: Date {
        DateService.calendar.date(from: DateComponents(year: viewYear, month: viewMonth, day: 1)) ?? Date()
    }

    var monthTitle: String { Formatters.monthTitle.string(from: monthDate) }

    var calendarDays: [Date?] {
        DateService.monthGrid(year: viewYear, month: viewMonth)
    }

    var monthStats: (activeDays: Int, compliancePercentage: Int, avgWear: Double) {
        let today = DateService.startOfDay(for: now)
        
        // We filter out future days and days before the app started.
        let hasAppStarted = trays.first != nil
        let validDays = calendarDays.compactMap { $0 }.filter { date in
            let isFuture = DateService.isFutureDay(date, now: now)
            let isBeforeAppStart = hasAppStarted ? DateService.startOfDay(for: date) < DateService.startOfDay(for: trays.first!.startDate) : true
            return !isFuture && !isBeforeAppStart
        }

        let totalWear = validDays.reduce(0.0) {
            $0 + TrackerCalculator.wearMinutes(
                on: $1,
                sessions: sessions,
                now: now,
                trayStartDate: currentTray?.startDate
            )
        }

        let activeDays = validDays.count
        let avgWear = activeDays == 0 ? 0 : totalWear / Double(activeDays)
        
        // Compliance ratio based on average wear time vs target hours.
        let compliancePercentage = targetMinutes > 0 ? Int(min(1.0, avgWear / targetMinutes) * 100) : 0
        
        return (activeDays, compliancePercentage, avgWear)
    }
    
    var selectedDayMetrics: SelectedDayMetrics? {
        guard let date = selectedDate else { return nil }
        
        // Don't show metrics for days before the app started
        if let appStartDate = trays.first?.startDate,
           DateService.startOfDay(for: date) < DateService.startOfDay(for: appStartDate) {
            return nil
        }
        
        let wearMinutes = TrackerCalculator.wearMinutes(
            on: date,
            sessions: sessions,
            now: now,
            trayStartDate: currentTray?.startDate
        )
        let removalMinutes = TrackerCalculator.removalMinutes(on: date, sessions: sessions, now: now)
        let goalDelta = wearMinutes - targetMinutes
        
        let daySessions = sessionsForDate(date)
        
        let isFuture = DateService.isFutureDay(date, now: now)
        let isToday = DateService.isToday(date, now: now)
        
        let complianceStatus: DayComplianceStatus
        if isFuture {
            complianceStatus = .future
        } else if wearMinutes >= targetMinutes - graceMinutes {
            complianceStatus = .targetMet
        } else if isToday {
            // For the current day, show "In Progress" since they still have time to hit it
            complianceStatus = wearMinutes >= targetMinutes * 0.7 ? .partial : .inProgress
        } else if wearMinutes >= targetMinutes * 0.7 {
            complianceStatus = .partial
        } else {
            complianceStatus = .missed
        }
        
        return SelectedDayMetrics(
            date: date,
            wearMinutes: wearMinutes,
            removalMinutes: removalMinutes,
            sessionsCount: daySessions.count,
            goalDelta: goalDelta,
            complianceStatus: complianceStatus,
            sessions: daySessions
        )
    }
    
    private func sessionsForDate(_ date: Date) -> [DaySession] {
        let dayStart = DateService.startOfDay(for: date)
        let dayEnd = DateService.calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        
        return sessions
            .filter { session in
                let sessionEnd = session.endTime ?? now
                return session.startTime < dayEnd && sessionEnd > dayStart
            }
            .map { session in
                let sessionEnd = session.endTime ?? now
                let clippedStart = max(session.startTime, dayStart)
                let clippedEnd = min(sessionEnd, dayEnd)
                let durationMinutes = clippedEnd.timeIntervalSince(clippedStart) / 60.0
                
                return DaySession(
                    id: session.id,
                    removedAt: session.startTime,
                    putBackAt: session.endTime,
                    durationMinutes: max(0, durationMinutes)
                )
            }
            .filter { $0.durationMinutes > 0 }
            .sorted { $0.removedAt < $1.removedAt }
    }

    func status(for date: Date?) -> DayStatus {
        TrackerCalculator.status(
            for: date,
            sessions: sessions,
            targetMinutes: targetMinutes,
            graceMinutes: graceMinutes,
            appStartDate: trays.first?.startDate,
            now: now,
            trayStartDate: currentTray?.startDate
        )
    }
    
    func selectDate(_ date: Date) {
        if selectedDate == date {
            selectedDate = nil
        } else {
            selectedDate = date
        }
    }

    func goBack() {
        if viewMonth == 1 {
            viewMonth = 12
            viewYear -= 1
        } else {
            viewMonth -= 1
        }
        selectedDate = nil
    }

    func goForward() {
        if viewMonth == 12 {
            viewMonth = 1
            viewYear += 1
        } else {
            viewMonth += 1
        }
        selectedDate = nil
    }
}

