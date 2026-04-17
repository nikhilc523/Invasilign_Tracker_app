import Foundation

@MainActor
final class TrackingStore: ObservableObject {
    @Published private(set) var sessions: [RemovalSession] = []
    @Published private(set) var trays: [Tray] = []
    @Published private(set) var settings: TrackerSettings = .default
    @Published private(set) var isLoaded = false

    private let repository: TrackingRepository

    init(repository: TrackingRepository) {
        self.repository = repository
    }

    var activeSession: RemovalSession? {
        sessions.first(where: { $0.isActive })
    }

    var isAlignerOut: Bool {
        activeSession != nil
    }

    var currentTray: Tray? {
        guard let id = settings.currentTrayID else { return trays.first }
        return trays.first(where: { $0.id == id })
    }

    func load() async {
        do {
            let snapshot = try await repository.load()
            sessions = snapshot.sessions
            trays = snapshot.trays
            settings = snapshot.settings
            isLoaded = true
            
            if settings.remindersEnabled {
                await ReminderNotificationManager.shared.refreshInsightNotifications(
                    sessions: sessions,
                    trays: trays,
                    settings: settings,
                    now: Date()
                )
            } else {
                await ReminderNotificationManager.shared.cancelInsightNotifications()
            }

#if canImport(ActivityKit)
            await AlignerLiveActivityManager.shared.sync(
                activeSession: activeSession,
                currentTray: currentTray,
                now: Date()
            )
#endif
        } catch {
            assertionFailure("Failed to load tracker data: \(error)")
        }
    }

    func toggleAligner(now: Date = Date()) async {
        do {
            try await repository.toggleAligner(at: now)
            await load()
            WatchConnectivityManager.shared.syncToWatch()
            
            // Handle reminder notifications
            if settings.remindersEnabled {
                if isAlignerOut {
                    // Aligners just removed - schedule reminders
                    print("📱 [TrackingStore] Aligners removed - scheduling reminders")
                    await ReminderNotificationManager.shared.scheduleReminders(
                        firstReminderMinutes: settings.firstReminderMinutes,
                        followUpReminderMinutes: settings.followUpReminderMinutes,
                        removalTime: now
                    )
                } else {
                    // Aligners put back - cancel all reminders
                    print("📱 [TrackingStore] Aligners put back - cancelling reminders")
                    await ReminderNotificationManager.shared.cancelAllReminders()
                }
            } else {
                print("📱 [TrackingStore] Reminders are disabled in settings")
            }
        } catch {
            assertionFailure("Failed to toggle aligner: \(error)")
        }
    }

    func deleteSession(id: UUID) async {
        do {
            try await repository.deleteSession(id: id)
            await load()
            WatchConnectivityManager.shared.syncToWatch()
        } catch {
            assertionFailure("Failed to delete session: \(error)")
        }
    }

    func addTray(number: Int, plannedDays: Int, startDate: Date = Date()) async {
        do {
            try await repository.addTray(number: number, plannedDays: plannedDays, startDate: startDate)
            await load()
            WatchConnectivityManager.shared.syncToWatch()
        } catch {
            assertionFailure("Failed to add tray: \(error)")
        }
    }

    func deleteTray(id: UUID) async {
        do {
            try await repository.deleteTray(id: id)
            await load()
            WatchConnectivityManager.shared.syncToWatch()
        } catch {
            assertionFailure("Failed to delete tray: \(error)")
        }
    }

    func setCurrentTray(id: UUID?) async {
        do {
            try await repository.setCurrentTray(id: id)
            await load()
            WatchConnectivityManager.shared.syncToWatch()
        } catch {
            assertionFailure("Failed to switch tray: \(error)")
        }
    }

    func incrementTrayPlannedDays(id: UUID, by days: Int) async {
        do {
            try await repository.incrementTrayPlannedDays(id: id, by: days)
            await load()
            WatchConnectivityManager.shared.syncToWatch()
        } catch {
            assertionFailure("Failed to extend tray days: \(error)")
        }
    }

    func updateSettings(_ newSettings: TrackerSettings) async {
        do {
            try await repository.updateSettings(newSettings)
            await load()
            WatchConnectivityManager.shared.syncToWatch()
        } catch {
            assertionFailure("Failed to update settings: \(error)")
        }
    }

    func resetAllData(now: Date = Date()) async {
        do {
            try await repository.resetAllData(now: now)
            await load()
            WatchConnectivityManager.shared.syncToWatch()
        } catch {
            assertionFailure("Failed to reset data: \(error)")
        }
    }
}
