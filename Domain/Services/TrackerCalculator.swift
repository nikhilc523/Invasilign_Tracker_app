import Foundation

enum TrackerCalculator {
    static func sessionsOverlapping(_ sessions: [RemovalSession], date: Date, now: Date = Date()) -> [RemovalSession] {
        let dayStart = DateService.startOfDay(for: date)
        guard let dayEnd = DateService.calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }

        return sessions.filter { session in
            let start = session.startTime
            let end = session.endTime ?? now
            return start < dayEnd && end > dayStart
        }
    }

    static func removalMinutes(on date: Date, sessions: [RemovalSession], now: Date = Date()) -> Double {
        let dayStart = DateService.startOfDay(for: date)
        guard let dayEnd = DateService.calendar.date(byAdding: .day, value: 1, to: dayStart) else { return 0 }

        return sessionsOverlapping(sessions, date: date, now: now).reduce(0) { total, session in
            let start = max(session.startTime, dayStart)
            let end = min(session.endTime ?? now, dayEnd)
            let minutes = max(0, end.timeIntervalSince(start) / 60)
            return total + minutes
        }
    }

    static func wearMinutes(on date: Date, sessions: [RemovalSession], now: Date = Date(), trayStartDate: Date? = nil) -> Double {
        let dayStart = DateService.startOfDay(for: date)
        guard let dayEnd = DateService.calendar.date(byAdding: .day, value: 1, to: dayStart) else { return 0 }

        // If tray started today and after midnight, use tray start time instead of midnight
        let effectiveStart: Date
        if let trayStart = trayStartDate,
           DateService.calendar.isDate(trayStart, inSameDayAs: date),
           trayStart > dayStart {
            effectiveStart = trayStart
        } else {
            effectiveStart = dayStart
        }

        let elapsedMinutes = max(0, min(now, dayEnd).timeIntervalSince(effectiveStart) / 60)
        let outMinutes = removalMinutes(on: date, sessions: sessions, now: now)
        return max(0, elapsedMinutes - outMinutes)
    }

    static func status(
        for date: Date?,
        sessions: [RemovalSession],
        targetMinutes: Double,
        graceMinutes: Double,
        appStartDate: Date? = nil,
        now: Date = Date(),
        trayStartDate: Date? = nil
    ) -> DayStatus {
        guard let date else { return .empty }
        if let appStartDate = appStartDate, DateService.startOfDay(for: date) < DateService.startOfDay(for: appStartDate) {
            return .empty
        }
        if DateService.isFutureDay(date, now: now) { return .future }

        let wear = wearMinutes(on: date, sessions: sessions, now: now, trayStartDate: trayStartDate)
        if wear >= targetMinutes - graceMinutes { return .pass }
        if DateService.isToday(date, now: now) { return .today }
        
        if wear >= (targetMinutes - graceMinutes) * 0.75 { return .warn }
        return .fail
    }

    static func trayLifeShortfallMinutes(
        for tray: Tray,
        sessions: [RemovalSession],
        targetMinutes: Double,
        now: Date = Date()
    ) -> Double {
        guard targetMinutes > 0 else { return 0 }
        let trackedDays = trayTrackedDays(for: tray, now: now)
        guard trackedDays > 0 else { return 0 }

        var totalShortfall = 0.0
        for dayOffset in 0..<trackedDays {
            let day = DateService.addDays(dayOffset, to: tray.startDate)
            let wear = wearMinutes(on: day, sessions: sessions, now: now)
            totalShortfall += max(0, targetMinutes - wear)
        }

        return totalShortfall
    }

    static func isEligibleForOneDayExtension(
        tray: Tray,
        sessions: [RemovalSession],
        targetMinutes: Double,
        thresholdMinutes: Double,
        now: Date = Date()
    ) -> Bool {
        guard thresholdMinutes > 0 else { return false }
        let trayEndDate = DateService.addDays(tray.plannedDays - 1, to: tray.startDate)
        guard DateService.startOfDay(for: now) >= trayEndDate else { return false }

        let shortfall = trayLifeShortfallMinutes(
            for: tray,
            sessions: sessions,
            targetMinutes: targetMinutes,
            now: now
        )
        return shortfall > thresholdMinutes
    }

    private static func trayTrackedDays(for tray: Tray, now: Date) -> Int {
        let today = DateService.startOfDay(for: now)
        let trayEndDate = DateService.addDays(tray.plannedDays - 1, to: tray.startDate)
        let lastTrackedDay = min(today, trayEndDate)
        guard lastTrackedDay >= tray.startDate else { return 0 }
        return DateService.daysBetween(tray.startDate, lastTrackedDay) + 1
    }
}
