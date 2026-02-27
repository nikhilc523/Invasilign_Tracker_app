import Foundation

struct RemovalSession: Identifiable, Sendable, Equatable {
    let id: UUID
    var startTime: Date
    var endTime: Date?

    var isActive: Bool { endTime == nil }
}
