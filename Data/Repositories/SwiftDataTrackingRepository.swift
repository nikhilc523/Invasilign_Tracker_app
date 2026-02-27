import Foundation
import SwiftData

@MainActor
final class SwiftDataTrackingRepository: TrackingRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func load() async throws -> TrackingSnapshot {
        let settingsRecord = try ensureSettingsRecord()
        let trays = try fetchTrays().map(mapTray)
        let sessions = try fetchSessions().map(mapSession)

        var settings = mapSettings(settingsRecord)
        if settings.currentTrayID == nil, let first = trays.first?.id {
            settings.currentTrayID = first
            settingsRecord.currentTrayID = first
            try context.save()
        }

        return TrackingSnapshot(sessions: sessions, trays: trays, settings: settings)
    }

    func toggleAligner(at now: Date) async throws {
        let activeSessions = try fetchActiveSessions()
        if !activeSessions.isEmpty {
            // Defensive close: if multiple active sessions exist from race/simulator state,
            // close all of them so app/watch/live-activity state converges immediately.
            for active in activeSessions {
                active.endTime = max(now, active.startTime)
            }
        } else {
            context.insert(RemovalSessionRecord(startTime: now, endTime: nil))
        }
        try context.save()
    }

    func deleteSession(id: UUID) async throws {
        let descriptor = FetchDescriptor<RemovalSessionRecord>(predicate: #Predicate { $0.id == id })
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }

    func addTray(number: Int, plannedDays: Int, startDate: Date) async throws {
        let tray = TrayRecord(number: number, startDate: startDate, plannedDays: plannedDays)
        context.insert(tray)

        let settings = try ensureSettingsRecord()
        settings.currentTrayID = tray.id
        try context.save()
    }

    func deleteTray(id: UUID) async throws {
        let descriptor = FetchDescriptor<TrayRecord>(predicate: #Predicate { $0.id == id })
        guard let tray = try context.fetch(descriptor).first else { return }

        context.delete(tray)

        let settings = try ensureSettingsRecord()
        if settings.currentTrayID == id {
            let remaining = try fetchTrays().filter { $0.id != id }.sorted { $0.number < $1.number }
            settings.currentTrayID = remaining.first?.id
        }
        try context.save()
    }

    func setCurrentTray(id: UUID?) async throws {
        let settings = try ensureSettingsRecord()
        settings.currentTrayID = id
        try context.save()
    }

    func incrementTrayPlannedDays(id: UUID, by days: Int) async throws {
        guard days > 0 else { return }
        let descriptor = FetchDescriptor<TrayRecord>(predicate: #Predicate { $0.id == id })
        guard let tray = try context.fetch(descriptor).first else { return }
        tray.plannedDays += days
        try context.save()
    }

    func updateSettings(_ settings: TrackerSettings) async throws {
        let record = try ensureSettingsRecord()
        record.targetHoursPerDay = settings.targetHoursPerDay
        record.plannedDaysPerTray = settings.plannedDaysPerTray
        record.graceMinutes = settings.graceMinutes
        record.complianceModeRaw = settings.complianceMode.rawValue
        record.currentTrayID = settings.currentTrayID
        record.totalTrays = settings.totalTrays
        record.remindersEnabled = settings.remindersEnabled
        record.firstReminderMinutes = settings.firstReminderMinutes
        record.followUpReminderMinutes = settings.followUpReminderMinutes
        try context.save()
    }

    func resetAllData(now: Date) async throws {
        try fetchSessions().forEach(context.delete)
        try fetchTrays().forEach(context.delete)

        let settings = try ensureSettingsRecord()
        settings.targetHoursPerDay = TrackerSettings.default.targetHoursPerDay
        settings.plannedDaysPerTray = TrackerSettings.default.plannedDaysPerTray
        settings.graceMinutes = TrackerSettings.default.graceMinutes
        settings.complianceModeRaw = TrackerSettings.default.complianceMode.rawValue
        settings.totalTrays = TrackerSettings.default.totalTrays
        settings.remindersEnabled = TrackerSettings.default.remindersEnabled
        settings.firstReminderMinutes = TrackerSettings.default.firstReminderMinutes
        settings.followUpReminderMinutes = TrackerSettings.default.followUpReminderMinutes

        let tray1 = TrayRecord(number: 1, startDate: now, plannedDays: TrackerSettings.default.plannedDaysPerTray)
        
        context.insert(tray1)
        settings.currentTrayID = tray1.id

        try context.save()
    }

    private func ensureSettingsRecord() throws -> SettingsRecord {
        if let existing = try context.fetch(FetchDescriptor<SettingsRecord>()).first {
            return existing
        }

        let record = SettingsRecord(
            targetHoursPerDay: TrackerSettings.default.targetHoursPerDay,
            plannedDaysPerTray: TrackerSettings.default.plannedDaysPerTray,
            graceMinutes: TrackerSettings.default.graceMinutes,
            complianceModeRaw: TrackerSettings.default.complianceMode.rawValue,
            currentTrayID: nil,
            totalTrays: TrackerSettings.default.totalTrays,
            remindersEnabled: TrackerSettings.default.remindersEnabled,
            firstReminderMinutes: TrackerSettings.default.firstReminderMinutes,
            followUpReminderMinutes: TrackerSettings.default.followUpReminderMinutes
        )
        context.insert(record)

        if try context.fetch(FetchDescriptor<TrayRecord>()).isEmpty {
            let now = Date()
            let tray1 = TrayRecord(number: 1, startDate: now, plannedDays: TrackerSettings.default.plannedDaysPerTray)
            
            context.insert(tray1)
            record.currentTrayID = tray1.id
        }

        try context.save()
        return record
    }

    private func fetchActiveSessions() throws -> [RemovalSessionRecord] {
        let predicate = #Predicate<RemovalSessionRecord> { $0.endTime == nil }
        let sort = SortDescriptor(\RemovalSessionRecord.startTime, order: .forward)
        return try context.fetch(FetchDescriptor(predicate: predicate, sortBy: [sort]))
    }

    private func fetchSessions() throws -> [RemovalSessionRecord] {
        let sort = SortDescriptor(\RemovalSessionRecord.startTime, order: .forward)
        return try context.fetch(FetchDescriptor(sortBy: [sort]))
    }

    private func fetchTrays() throws -> [TrayRecord] {
        let sort = SortDescriptor(\TrayRecord.number, order: .forward)
        return try context.fetch(FetchDescriptor(sortBy: [sort]))
    }

    private func mapSession(_ record: RemovalSessionRecord) -> RemovalSession {
        RemovalSession(id: record.id, startTime: record.startTime, endTime: record.endTime)
    }

    private func mapTray(_ record: TrayRecord) -> Tray {
        Tray(id: record.id, number: record.number, startDate: record.startDate, plannedDays: record.plannedDays)
    }

    private func mapSettings(_ record: SettingsRecord) -> TrackerSettings {
        TrackerSettings(
            targetHoursPerDay: record.targetHoursPerDay,
            plannedDaysPerTray: record.plannedDaysPerTray,
            graceMinutes: record.graceMinutes,
            complianceMode: ComplianceMode(rawValue: record.complianceModeRaw) ?? .dailyPassFail,
            currentTrayID: record.currentTrayID,
            totalTrays: record.totalTrays,
            remindersEnabled: record.remindersEnabled,
            firstReminderMinutes: record.firstReminderMinutes,
            followUpReminderMinutes: record.followUpReminderMinutes
        )
    }
}
