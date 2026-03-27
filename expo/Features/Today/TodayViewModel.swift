import Foundation
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var sessions: [RemovalSession] = []
    @Published private(set) var settings: TrackerSettings = .default
    @Published private(set) var trays: [Tray] = []
    @Published private(set) var isAlignerOut = false
    @Published private(set) var now = Date()

    private let store: TrackingStore
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    private let extensionThresholdMinutes = 5.0 * 60.0

    init(store: TrackingStore) {
        self.store = store

        store.$sessions.assign(to: &$sessions)
        store.$settings.assign(to: &$settings)
        store.$trays.assign(to: &$trays)
        store.$isLoaded
            .combineLatest(store.$sessions)
            .map { _, sessions in sessions.contains(where: { $0.isActive }) }
            .assign(to: &$isAlignerOut)

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] value in
                self?.now = value
            }
    }

    deinit { timer?.cancel() }

    var today: Date { DateService.startOfDay(for: now) }

    var wearMinutes: Double {
        TrackerCalculator.wearMinutes(
            on: today,
            sessions: sessions,
            now: now,
            trayStartDate: currentTray?.startDate
        )
    }

    var targetMinutes: Double { Double(settings.targetHoursPerDay * 60) }

    var remainingMinutes: Double {
        max(0, targetMinutes - Double(settings.graceMinutes) - wearMinutes)
    }

    var progress: Double {
        targetMinutes > 0 ? wearMinutes / targetMinutes : 0
    }

    var isOnTrack: Bool {
        wearMinutes >= targetMinutes - Double(settings.graceMinutes) || remainingMinutes <= 0
    }

    var currentTray: Tray? {
        if let id = settings.currentTrayID { return trays.first(where: { $0.id == id }) }
        return trays.first
    }

    var trayDayNumber: Int {
        guard let currentTray else { return 1 }
        return DateService.daysBetween(currentTray.startDate, today) + 1
    }

    var trayDaysRemaining: Int {
        guard let currentTray else { return 0 }
        let end = DateService.addDays(currentTray.plannedDays - 1, to: currentTray.startDate)
        return max(0, DateService.daysBetween(today, end))
    }
    
    /// Total time aligners were removed (out) today - only active removal sessions
    var removedMinutesToday: Double {
        let todaySessions = sessions.filter { session in
            DateService.calendar.isDate(session.startTime, inSameDayAs: today)
        }
        
        var totalRemoved = 0.0
        for session in todaySessions {
            let end = session.endTime ?? now
            let duration = end.timeIntervalSince(session.startTime) / 60.0
            totalRemoved += duration
        }
        
        return max(0, totalRemoved)
    }

    var isTrayComplete: Bool {
        guard let currentTray else { return false }
        let end = DateService.addDays(currentTray.plannedDays - 1, to: currentTray.startDate)
        return trayDaysRemaining == 0 && !DateService.isFutureDay(end, now: now)
    }

    var trayLifeDebtMinutes: Double {
        guard let currentTray else { return 0 }
        // For backward compatibility - calculates total shortfall
        return TrackerCalculator.trayLifeShortfallMinutes(
            for: currentTray,
            sessions: sessions,
            targetMinutes: targetMinutes,
            now: now
        )
    }
    
    var trayLifeRemainingMinutes: Double {
        guard let currentTray else { return 0 }
        
        // Total tray capacity: plannedDays × targetMinutes
        let totalCapacityMinutes = Double(currentTray.plannedDays) * targetMinutes
        
        // Calculate total actual worn minutes across all tray days so far
        let trackedDays = min(trayDayNumber, currentTray.plannedDays)
        var totalWornMinutes = 0.0
        for dayOffset in 0..<trackedDays {
            let day = DateService.addDays(dayOffset, to: currentTray.startDate)
            totalWornMinutes += TrackerCalculator.wearMinutes(
                on: day,
                sessions: sessions,
                now: now,
                trayStartDate: currentTray.startDate
            )
        }
        
        // Remaining = capacity - worn
        return max(0, totalCapacityMinutes - totalWornMinutes)
    }

    var trayLifeDebtProgress: Double {
        guard let currentTray else { return 0 }
        
        // Total tray capacity: plannedDays × targetMinutes (e.g., 15 × 22 × 60 = 19,800 minutes)
        let totalCapacityMinutes = Double(currentTray.plannedDays) * targetMinutes
        
        // Calculate total actual worn minutes across all tray days
        let trackedDays = min(trayDayNumber, currentTray.plannedDays)
        var totalWornMinutes = 0.0
        for dayOffset in 0..<trackedDays {
            let day = DateService.addDays(dayOffset, to: currentTray.startDate)
            totalWornMinutes += TrackerCalculator.wearMinutes(
                on: day,
                sessions: sessions,
                now: now,
                trayStartDate: currentTray.startDate
            )
        }
        
        // Progress = worn / capacity
        // As you wear more, the ring fills up (showing you're using the tray's life)
        return totalCapacityMinutes > 0 ? min(max(totalWornMinutes / totalCapacityMinutes, 0), 1) : 0
    }

    var isTrayEligibleForExtension: Bool {
        guard let currentTray else { return false }
        
        // Check if we're at or past day 15
        let trayEndDate = DateService.addDays(currentTray.plannedDays - 1, to: currentTray.startDate)
        guard DateService.startOfDay(for: now) >= trayEndDate else { return false }
        
        // Check if there's more than 5 hours (300 minutes) remaining
        return trayLifeRemainingMinutes > extensionThresholdMinutes
    }
    
    var shouldPromptExtension: Bool {
        // Only prompt once at the end of the planned days
        guard let currentTray else { return false }
        let trayEndDate = DateService.addDays(currentTray.plannedDays - 1, to: currentTray.startDate)
        let today = DateService.startOfDay(for: now)
        return today == trayEndDate && isTrayEligibleForExtension
    }
    
    var extensionPromptMessage: String? {
        guard shouldPromptExtension else { return nil }
        let hours = Int(trayLifeRemainingMinutes / 60)
        return "You have \(hours)h remaining on this tray. Extend for one more day?"
    }

    var currentStreak: Int {
        guard let appStart = trays.first?.startDate else { return 0 }
        
        let today = DateService.startOfDay(for: now)
        let passMark = targetMinutes - Double(settings.graceMinutes)
        
        var streak = 0
        var checkDate = today
        
        // Count backwards from today to find consecutive passing days
        while checkDate >= DateService.startOfDay(for: appStart) {
            let wear = TrackerCalculator.wearMinutes(
                on: checkDate,
                sessions: sessions,
                now: now,
                trayStartDate: currentTray?.startDate
            )
            
            // Skip today if it's not complete yet
            if DateService.calendar.isDate(checkDate, inSameDayAs: today) {
                // Only count today if we've already met the goal
                if wear >= passMark {
                    streak += 1
                }
                // Move to yesterday regardless
                guard let yesterday = DateService.calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = yesterday
                continue
            }
            
            // For past days, check if they met the goal
            if wear >= passMark {
                streak += 1
            } else {
                // Streak broken
                break
            }
            
            guard let yesterday = DateService.calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = yesterday
        }
        
        return streak
    }
    
    var streakProgress: Double {
        // Show progress towards a 7-day streak milestone
        let milestone = 7.0
        return min(Double(currentStreak) / milestone, 1.0)
    }

    var weekDates: [Date] { DateService.weekDates(containing: now) }

    func dayDotColor(for date: Date) -> DayStatus {
        if let appStart = trays.first?.startDate, DateService.startOfDay(for: date) < DateService.startOfDay(for: appStart) {
            return .future // Using .future renders as an empty dot for days without data
        }
        if DateService.isFutureDay(date, now: now) { return .future }
        let wear = TrackerCalculator.wearMinutes(
            on: date,
            sessions: sessions,
            now: now,
            trayStartDate: currentTray?.startDate
        )
        let passMark = targetMinutes - Double(settings.graceMinutes)
        if wear >= passMark { return .pass }
        if wear >= passMark * 0.7 { return .warn }
        return .fail
    }

    func toggleAligner() {
        Task { await store.toggleAligner(now: now) }
    }
    
    func extendCurrentTray() {
        guard let currentTray else { return }
        Task { await store.incrementTrayPlannedDays(id: currentTray.id, by: 1) }
    }
}
