import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var settings: TrackerSettings = .default
    @Published private(set) var trays: [Tray] = []

    private let store: TrackingStore

    init(store: TrackingStore) {
        self.store = store
        store.$settings.assign(to: &$settings)
        store.$trays.assign(to: &$trays)
    }

    var currentTray: Tray? {
        if let id = settings.currentTrayID {
            return trays.first(where: { $0.id == id })
        }
        return trays.first
    }

    func updateTargetHours(_ value: Int) {
        var next = settings
        next.targetHoursPerDay = value
        Task { await store.updateSettings(next) }
    }

    func updateGraceMinutes(_ value: Int) {
        var next = settings
        next.graceMinutes = value
        Task { await store.updateSettings(next) }
    }

    func updatePlannedDays(_ value: Int) {
        var next = settings
        next.plannedDaysPerTray = value
        Task { await store.updateSettings(next) }
    }

    func updateComplianceMode(_ mode: ComplianceMode) {
        var next = settings
        next.complianceMode = mode
        Task { await store.updateSettings(next) }
    }
    
    func updateRemindersEnabled(_ value: Bool) {
        var next = settings
        next.remindersEnabled = value
        Task { 
            await store.updateSettings(next)
            // Request notification permissions if enabling
            if value {
                _ = await ReminderNotificationManager.shared.requestAuthorization()
            }
        }
    }
    
    func updateFirstReminderMinutes(_ value: Int) {
        var next = settings
        next.firstReminderMinutes = value
        Task { await store.updateSettings(next) }
    }
    
    func updateFollowUpReminderMinutes(_ value: Int) {
        var next = settings
        next.followUpReminderMinutes = value
        Task { await store.updateSettings(next) }
    }

    func resetData() {
        Task { await store.resetAllData(now: Date()) }
    }
}
