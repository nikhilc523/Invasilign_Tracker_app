import Foundation

struct Tray: Identifiable, Sendable, Equatable {
    let id: UUID
    var number: Int
    var startDate: Date
    var plannedDays: Int
}
