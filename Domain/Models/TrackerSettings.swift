import Foundation

struct TrackerSettings: Sendable, Equatable {
    var targetHoursPerDay: Int
    var plannedDaysPerTray: Int
    var graceMinutes: Int
    var complianceMode: ComplianceMode
    var currentTrayID: UUID?
    var totalTrays: Int
    var remindersEnabled: Bool
    var firstReminderMinutes: Int
    var followUpReminderMinutes: Int

    static let `default` = TrackerSettings(
        targetHoursPerDay: 22,
        plannedDaysPerTray: 15,
        graceMinutes: 5,
        complianceMode: .dailyPassFail,
        currentTrayID: nil,
        totalTrays: 14,
        remindersEnabled: true,
        firstReminderMinutes: 2,  // 2 minutes for testing
        followUpReminderMinutes: 2  // 2 minutes for testing
    )
}
