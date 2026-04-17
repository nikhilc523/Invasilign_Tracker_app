import Foundation
import Combine

struct TrayDailyLog: Identifiable, Equatable {
    let id = UUID()
    let dayNumber: Int
    let date: Date
    let wearMinutes: Double
    let status: DayStatus
}

struct TrayCardMetrics: Identifiable, Equatable {
    let id: UUID
    let tray: Tray
    let isCurrent: Bool
    let endDate: Date
    let daysPassed: Int
    let daysRemaining: Int
    let passCount: Int
    let avgWear: Double
    let compliance: Int
    let progress: Double
    let isComplete: Bool
    let isDataUnavailable: Bool
    let lifeDebtMinutes: Double
    let canAddExtraDay: Bool
    let dailyLogs: [TrayDailyLog]
}

@MainActor
final class TraysViewModel: ObservableObject {
    @Published private(set) var sessions: [RemovalSession] = []
    @Published private(set) var settings: TrackerSettings = .default
    @Published private(set) var trays: [Tray] = []
    @Published private(set) var now = Date()

    private let store: TrackingStore
    private var timer: AnyCancellable?
    private let extensionThresholdMinutes = 5.0 * 60.0

    init(store: TrackingStore) {
        self.store = store
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

    var sortedTrays: [Tray] {
        trays.sorted { $0.number < $1.number }
    }

    var targetMinutes: Double { Double(settings.targetHoursPerDay * 60) }

    func reload() async {
        await store.load()
    }

    func cardMetrics(for tray: Tray) -> TrayCardMetrics {
        let exactPassedSeconds = now.timeIntervalSince(tray.startDate)
        let exactDaysPassed = max(0, Int(exactPassedSeconds / 86400.0) + 1)
        
        let endDate = tray.startDate.addingTimeInterval(TimeInterval(tray.plannedDays) * 86400.0)
        let exactRemainingSeconds = endDate.timeIntervalSince(now)
        let daysRemaining = exactRemainingSeconds > 0 ? Int(ceil(exactRemainingSeconds / 86400.0)) : 0
        
        let daysPassed = max(0, min(exactDaysPassed, tray.plannedDays))
        // Only mark as unavailable if it's a very old tray with no data
        // New trays should show 0 hours, not "unavailable"
        let isDataUnavailable = false  // Always show data, even if 0

        var passCount = 0
        var totalWear = 0.0
        var dailyLogs: [TrayDailyLog] = []
        
        for index in 0..<tray.plannedDays {
            let day = DateService.addDays(index, to: tray.startDate)
            let dayNumber = index + 1
            
            let isFuture = DateService.isFutureDay(day, now: now)
            let wear = isFuture ? 0 : TrackerCalculator.wearMinutes(
                on: day,
                sessions: sessions,
                now: now,
                trayStartDate: tray.startDate
            )
            
            let dayStatus = TrackerCalculator.status(
                for: day,
                sessions: sessions,
                targetMinutes: targetMinutes,
                graceMinutes: Double(settings.graceMinutes),
                appStartDate: trays.first?.startDate,
                now: now,
                trayStartDate: tray.startDate
            )
            
            dailyLogs.append(TrayDailyLog(
                dayNumber: dayNumber,
                date: day,
                wearMinutes: wear,
                status: dayStatus
            ))
            
            if !isFuture && index < min(daysPassed, tray.plannedDays) {
                totalWear += wear
                if wear >= targetMinutes - Double(settings.graceMinutes) {
                    passCount += 1
                }
            }
        }

        let denominator = max(1, min(daysPassed, tray.plannedDays))
        let avgWear = totalWear / Double(denominator)
        let compliance = daysPassed > 0 ? Int(round(Double(passCount) / Double(min(daysPassed, tray.plannedDays)) * 100)) : 0
        let lifeDebtMinutes = isDataUnavailable
            ? 0
            : TrackerCalculator.trayLifeShortfallMinutes(
                for: tray,
                sessions: sessions,
                targetMinutes: targetMinutes,
                now: now
            )
        let canAddExtraDay = !isDataUnavailable
            && TrackerCalculator.isEligibleForOneDayExtension(
                tray: tray,
                sessions: sessions,
                targetMinutes: targetMinutes,
                thresholdMinutes: extensionThresholdMinutes,
                now: now
            )
        
        // Progress defaults to 0 if startDate is in future
        let rawProgress = exactPassedSeconds > 0 ? (exactPassedSeconds / (Double(tray.plannedDays) * 86400.0)) : 0.0

        return TrayCardMetrics(
            id: tray.id,
            tray: tray,
            isCurrent: settings.currentTrayID == tray.id,
            endDate: endDate,
            daysPassed: exactPassedSeconds < 0 ? 0 : daysPassed,
            daysRemaining: daysRemaining,
            passCount: passCount,
            avgWear: avgWear,
            compliance: compliance,
            progress: min(max(0, rawProgress), 1),
            isComplete: daysRemaining == 0,
            isDataUnavailable: isDataUnavailable,
            lifeDebtMinutes: lifeDebtMinutes,
            canAddExtraDay: canAddExtraDay,
            dailyLogs: dailyLogs
        )
    }

    func addTray(number: Int, plannedDays: Int, startDate: Date) {
        Task { await store.addTray(number: number, plannedDays: plannedDays, startDate: startDate) }
    }

    func deleteTray(id: UUID) {
        Task { await store.deleteTray(id: id) }
    }

    func setCurrentTray(id: UUID?) {
        Task { await store.setCurrentTray(id: id) }
    }

    func extendTrayByOneDay(id: UUID) {
        Task { await store.incrementTrayPlannedDays(id: id, by: 1) }
    }
}
