import Foundation
import SwiftData

@Model
final class TrayRecord {
    @Attribute(.unique) var id: UUID
    var number: Int
    var startDate: Date
    var plannedDays: Int

    init(id: UUID = UUID(), number: Int, startDate: Date, plannedDays: Int) {
        self.id = id
        self.number = number
        self.startDate = startDate
        self.plannedDays = plannedDays
    }
}
