import Foundation
import SwiftData

@Model
final class SettingsRecord {
    @Attribute(.unique) var id: String
    var targetHoursPerDay: Int
    var plannedDaysPerTray: Int
    var graceMinutes: Int
    var complianceModeRaw: String
    var currentTrayID: UUID?
    var totalTrays: Int
    var remindersEnabled: Bool = true
    var firstReminderMinutes: Int = 2
    var followUpReminderMinutes: Int = 2

    init(
        id: String = "singleton",
        targetHoursPerDay: Int,
        plannedDaysPerTray: Int,
        graceMinutes: Int,
        complianceModeRaw: String,
        currentTrayID: UUID?,
        totalTrays: Int,
        remindersEnabled: Bool = true,
        firstReminderMinutes: Int = 2,
        followUpReminderMinutes: Int = 2
    ) {
        self.id = id
        self.targetHoursPerDay = targetHoursPerDay
        self.plannedDaysPerTray = plannedDaysPerTray
        self.graceMinutes = graceMinutes
        self.complianceModeRaw = complianceModeRaw
        self.currentTrayID = currentTrayID
        self.totalTrays = totalTrays
        self.remindersEnabled = remindersEnabled
        self.firstReminderMinutes = firstReminderMinutes
        self.followUpReminderMinutes = followUpReminderMinutes
    }
}
