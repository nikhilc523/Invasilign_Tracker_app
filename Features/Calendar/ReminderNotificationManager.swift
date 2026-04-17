import Foundation
import UserNotifications

@MainActor
final class ReminderNotificationManager {
    static let shared = ReminderNotificationManager()
    
    private let firstReminderID = "aligner-reminder-first"
    private let followUpReminderIDPrefix = "aligner-reminder-followup"
    private let insightIDPrefix = "insight"
    
    private init() {}
    
    /// Request notification permissions from the user
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print("🔐 [Notifications] Permission granted: \(granted)")
            
            // Also check current settings
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            print("🔐 [Notifications] Current authorization status: \(settings.authorizationStatus.rawValue)")
            print("   - Alert setting: \(settings.alertSetting.rawValue)")
            print("   - Sound setting: \(settings.soundSetting.rawValue)")
            print("   - Badge setting: \(settings.badgeSetting.rawValue)")
            
            return granted
        } catch {
            print("❌ [Notifications] Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    /// Schedule reminders when aligners are removed
    func scheduleReminders(firstReminderMinutes: Int, followUpReminderMinutes: Int, removalTime: Date = Date()) async {
        print("🔔 [Notifications] Scheduling reminders:")
        print("   - First reminder in \(firstReminderMinutes) minutes")
        print("   - Follow-ups every \(followUpReminderMinutes) minutes")
        print("   - Removal time: \(removalTime)")
        
        // Check permissions first
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        print("🔐 [Notifications] Authorization status: \(settings.authorizationStatus.rawValue)")
        if settings.authorizationStatus != .authorized {
            print("⚠️ [Notifications] WARNING: Notifications not authorized! Status: \(settings.authorizationStatus.rawValue)")
            print("   0 = notDetermined, 1 = denied, 2 = authorized, 3 = provisional, 4 = ephemeral")
        }
        
        // Cancel any existing reminders first
        await cancelAllReminders()
        
        // Schedule first reminder (e.g., 2 minutes for testing)
        let firstReminderDate = removalTime.addingTimeInterval(TimeInterval(firstReminderMinutes * 60))
        print("   - First notification scheduled for: \(firstReminderDate)")
        
        await scheduleNotification(
            id: firstReminderID,
            title: "Aligner Reminder",
            body: "It's been \(firstReminderMinutes) minutes. Are you still eating? If not, put your aligners back in.",
            date: firstReminderDate
        )
        
        // Schedule follow-up reminders (every X minutes after the first)
        // Schedule 6 follow-ups
        for i in 1...6 {
            let followUpDate = firstReminderDate.addingTimeInterval(TimeInterval(followUpReminderMinutes * 60 * i))
            print("   - Follow-up #\(i) scheduled for: \(followUpDate)")
            
            await scheduleNotification(
                id: "\(followUpReminderIDPrefix)-\(i)",
                title: "Aligner Reminder",
                body: "Don't forget to put your aligners back in!",
                date: followUpDate
            )
        }
        
        // Verify notifications were actually scheduled
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let ourNotifications = pending.filter { $0.identifier.hasPrefix(firstReminderID) || $0.identifier.hasPrefix(followUpReminderIDPrefix) }
        print("✅ [Notifications] Successfully scheduled \(ourNotifications.count) notifications")
    }
    
    /// Cancel all scheduled reminders
    func cancelAllReminders() async {
        print("🔕 [Notifications] Cancelling all reminders...")
        
        let center = UNUserNotificationCenter.current()
        
        // Get all pending notifications
        let pendingRequests = await center.pendingNotificationRequests()
        
        // Filter for our reminder notifications
        let reminderIDs = pendingRequests
            .map { $0.identifier }
            .filter { $0.hasPrefix(firstReminderID) || $0.hasPrefix(followUpReminderIDPrefix) }
        
        print("   - Found \(reminderIDs.count) pending reminders to cancel")
        
        // Cancel them
        center.removePendingNotificationRequests(withIdentifiers: reminderIDs)
        center.removeDeliveredNotifications(withIdentifiers: reminderIDs)
        
        print("✅ [Notifications] All reminders cancelled")
    }
    
    /// Rebuild all non-reminder insight notifications.
    /// This keeps at most 2 notifications/day (morning plan + evening summary/weekly insight).
    func refreshInsightNotifications(
        sessions: [RemovalSession],
        trays: [Tray],
        settings: TrackerSettings,
        now: Date = Date()
    ) async {
        let notificationSettings = await UNUserNotificationCenter.current().notificationSettings()
        guard notificationSettings.authorizationStatus == .authorized || notificationSettings.authorizationStatus == .provisional else {
            return
        }
        
        await cancelInsightNotifications()
        
        guard settings.remindersEnabled else { return }
        guard let currentTray = resolveCurrentTray(from: trays, currentTrayID: settings.currentTrayID) else { return }
        
        let calendar = DateService.calendar
        let today = DateService.startOfDay(for: now)
        
        for offset in 0...1 {
            let day = DateService.addDays(offset, to: today)
            let weekday = calendar.component(.weekday, from: day)
            
            if let morningDate = date(on: day, hour: 8, minute: 30), morningDate > now {
                let planBody = morningPlanBody(
                    for: day,
                    tray: currentTray,
                    sessions: sessions,
                    settings: settings,
                    now: now
                )
                await scheduleNotification(
                    id: "\(insightIDPrefix)-morning-\(day.timeIntervalSince1970)",
                    title: "Today's Wear Plan",
                    body: planBody,
                    date: morningDate
                )
            }
            
            // Only schedule summary/weekly for today; these depend on current-day stats.
            guard offset == 0 else { continue }
            
            if weekday == 1 {
                if let weeklyDate = date(on: day, hour: 20, minute: 0), weeklyDate > now {
                    let weeklyBody = weeklyInsightBody(
                        endingOn: day,
                        sessions: sessions,
                        trays: trays,
                        settings: settings
                    )
                    await scheduleNotification(
                        id: "\(insightIDPrefix)-weekly-\(day.timeIntervalSince1970)",
                        title: "Weekly Smile Insight",
                        body: weeklyBody,
                        date: weeklyDate
                    )
                }
            } else if let summaryDate = date(on: day, hour: 21, minute: 0), summaryDate > now {
                let summaryBody = dailySummaryBody(
                    for: day,
                    tray: currentTray,
                    sessions: sessions,
                    trays: trays,
                    settings: settings,
                    now: now
                )
                await scheduleNotification(
                    id: "\(insightIDPrefix)-summary-\(day.timeIntervalSince1970)",
                    title: "Daily Wear Summary",
                    body: summaryBody,
                    date: summaryDate
                )
            }
        }
    }
    
    func cancelInsightNotifications() async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        let insightIDs = pendingRequests
            .map(\.identifier)
            .filter { $0.hasPrefix(insightIDPrefix) }
        
        center.removePendingNotificationRequests(withIdentifiers: insightIDs)
        center.removeDeliveredNotifications(withIdentifiers: insightIDs)
    }
    
    /// Schedule a single notification
    private func scheduleNotification(id: String, title: String, body: String, date: Date) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "ALIGNER_REMINDER"
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    private func resolveCurrentTray(from trays: [Tray], currentTrayID: UUID?) -> Tray? {
        if let id = currentTrayID, let tray = trays.first(where: { $0.id == id }) {
            return tray
        }
        return trays.sorted(by: { $0.number < $1.number }).first
    }
    
    private func date(on day: Date, hour: Int, minute: Int) -> Date? {
        var components = DateService.calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return DateService.calendar.date(from: components)
    }
    
    private func morningPlanBody(
        for day: Date,
        tray: Tray,
        sessions: [RemovalSession],
        settings: TrackerSettings,
        now: Date
    ) -> String {
        let targetHours = settings.targetHoursPerDay
        let outBudgetHours = max(0, 24 - targetHours)
        let trayEndDate = DateService.addDays(tray.plannedDays - 1, to: tray.startDate)
        let dayBeforeEnd = DateService.addDays(-1, to: trayEndDate)
        
        var lines: [String] = [
            "Target today: \(targetHours)h. Max out-time budget: \(outBudgetHours)h."
        ]
        
        if DateService.startOfDay(for: day) == DateService.startOfDay(for: dayBeforeEnd) {
            lines.append("Tomorrow is Day \(tray.plannedDays) (planned last day).")
        }
        
        if DateService.startOfDay(for: day) == DateService.startOfDay(for: trayEndDate) {
            lines.append("Final planned tray day. Stay on target today.")
        }
        
        let remainingLife = trayLifeRemainingMinutes(for: tray, sessions: sessions, targetMinutes: Double(targetHours * 60), now: now)
        if remainingLife > 0, remainingLife <= (8 * 60) {
            lines.append("Only \(Formatters.durationShort(minutes: remainingLife)) tray life remains.")
        }
        
        return lines.joined(separator: " ")
    }
    
    private func dailySummaryBody(
        for day: Date,
        tray: Tray,
        sessions: [RemovalSession],
        trays: [Tray],
        settings: TrackerSettings,
        now: Date
    ) -> String {
        let targetMinutes = Double(settings.targetHoursPerDay * 60)
        let passMark = targetMinutes - Double(settings.graceMinutes)
        
        let wear = TrackerCalculator.wearMinutes(
            on: day,
            sessions: sessions,
            now: now,
            trayStartDate: tray.startDate
        )
        let remaining = max(0, passMark - wear)
        let streak = currentStreak(
            asOf: day,
            sessions: sessions,
            trays: trays,
            targetMinutes: targetMinutes,
            graceMinutes: Double(settings.graceMinutes),
            now: now
        )
        
        var lines = [
            "Today: worn \(Formatters.durationShort(minutes: wear)), remaining \(Formatters.durationShort(minutes: remaining)), streak \(streak) day\(streak == 1 ? "" : "s")."
        ]
        
        if remaining <= 0 {
            lines.append("Great job. You are on track today.")
        } else {
            lines.append("Need \(Formatters.durationShort(minutes: remaining)) more before sleep.")
        }
        
        let trayEndDate = DateService.addDays(tray.plannedDays - 1, to: tray.startDate)
        if DateService.startOfDay(for: day) == DateService.startOfDay(for: trayEndDate) {
            let remainingLife = trayLifeRemainingMinutes(for: tray, sessions: sessions, targetMinutes: targetMinutes, now: now)
            if remainingLife > 5 * 60 {
                lines.append("Tray period finished, but \(Formatters.durationShort(minutes: remainingLife)) tray life remains. Extend +1 day.")
            } else {
                lines.append("Tray complete. You can switch to next tray.")
            }
        }
        
        if streak == 7 {
            lines.append("Milestone: 7-day streak completed.")
        }
        
        return lines.joined(separator: " ")
    }
    
    private func weeklyInsightBody(
        endingOn day: Date,
        sessions: [RemovalSession],
        trays: [Tray],
        settings: TrackerSettings
    ) -> String {
        let targetMinutes = Double(settings.targetHoursPerDay * 60)
        let grace = Double(settings.graceMinutes)
        let sortedTrays = trays.sorted { $0.startDate < $1.startDate }
        
        var totalWear = 0.0
        var passDays = 0
        var bestDay = day
        var bestWear = -1.0
        
        for offset in 0..<7 {
            let d = DateService.addDays(-offset, to: day)
            let trayStart = sortedTrays.last(where: { DateService.startOfDay(for: $0.startDate) <= DateService.startOfDay(for: d) })?.startDate
            let wear = TrackerCalculator.wearMinutes(on: d, sessions: sessions, now: day, trayStartDate: trayStart)
            totalWear += wear
            if wear >= targetMinutes - grace { passDays += 1 }
            if wear > bestWear {
                bestWear = wear
                bestDay = d
            }
        }
        
        let avgWear = totalWear / 7.0
        let bestDayName = bestDay.formatted(.dateTime.weekday(.abbreviated))
        let tip: String
        if avgWear + 30 < targetMinutes {
            tip = "Tip: reduce evening out-time by ~30m."
        } else if passDays < 5 {
            tip = "Tip: keep out-time sessions shorter and more planned."
        } else {
            tip = "Tip: maintain this rhythm for an easier next tray."
        }
        
        return "This week: avg wear \(Formatters.durationShort(minutes: avgWear)), \(passDays)/7 pass days, best day \(bestDayName) (\(Formatters.durationShort(minutes: bestWear))). \(tip)"
    }
    
    private func trayLifeRemainingMinutes(
        for tray: Tray,
        sessions: [RemovalSession],
        targetMinutes: Double,
        now: Date
    ) -> Double {
        guard targetMinutes > 0 else { return 0 }
        let trackedDays = min(max(0, DateService.daysBetween(tray.startDate, now) + 1), tray.plannedDays)
        guard trackedDays > 0 else { return Double(tray.plannedDays) * targetMinutes }
        
        var totalWorn = 0.0
        for dayOffset in 0..<trackedDays {
            let day = DateService.addDays(dayOffset, to: tray.startDate)
            totalWorn += TrackerCalculator.wearMinutes(on: day, sessions: sessions, now: now, trayStartDate: tray.startDate)
        }
        
        return max(0, Double(tray.plannedDays) * targetMinutes - totalWorn)
    }
    
    private func currentStreak(
        asOf day: Date,
        sessions: [RemovalSession],
        trays: [Tray],
        targetMinutes: Double,
        graceMinutes: Double,
        now: Date
    ) -> Int {
        guard let appStart = trays.sorted(by: { $0.startDate < $1.startDate }).first?.startDate else { return 0 }
        let passMark = targetMinutes - graceMinutes
        
        var streak = 0
        var check = DateService.startOfDay(for: day)
        let minDay = DateService.startOfDay(for: appStart)
        
        while check >= minDay {
            let trayStart = trays
                .filter { DateService.startOfDay(for: $0.startDate) <= check }
                .sorted(by: { $0.startDate < $1.startDate })
                .last?
                .startDate
            
            let wear = TrackerCalculator.wearMinutes(on: check, sessions: sessions, now: now, trayStartDate: trayStart)
            if wear >= passMark {
                streak += 1
            } else {
                break
            }
            guard let yesterday = DateService.calendar.date(byAdding: .day, value: -1, to: check) else { break }
            check = DateService.startOfDay(for: yesterday)
        }
        
        return streak
    }
}
