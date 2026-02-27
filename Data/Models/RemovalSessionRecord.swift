import Foundation
import SwiftData

@Model
final class RemovalSessionRecord {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?

    init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
}
