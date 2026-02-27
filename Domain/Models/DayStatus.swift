import Foundation

enum DayStatus: Sendable, Equatable {
    case future
    case empty
    case pass
    case warn
    case fail
    case today
}
