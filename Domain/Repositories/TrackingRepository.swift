import Foundation

protocol TrackingRepository: AnyObject {
    func load() async throws -> TrackingSnapshot
    func toggleAligner(at now: Date) async throws
    func deleteSession(id: UUID) async throws
    func addTray(number: Int, plannedDays: Int, startDate: Date) async throws
    func deleteTray(id: UUID) async throws
    func setCurrentTray(id: UUID?) async throws
    func incrementTrayPlannedDays(id: UUID, by days: Int) async throws
    func updateSettings(_ settings: TrackerSettings) async throws
    func resetAllData(now: Date) async throws
}

struct TrackingSnapshot: Sendable {
    var sessions: [RemovalSession]
    var trays: [Tray]
    var settings: TrackerSettings
}
