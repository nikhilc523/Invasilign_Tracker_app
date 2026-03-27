import Foundation

enum ComplianceMode: String, Codable, CaseIterable, Sendable {
    case totalHours = "A"
    case dailyPassFail = "B"

    var title: String {
        switch self {
        case .dailyPassFail: return "Daily Pass/Fail"
        case .totalHours: return "Total Hours"
        }
    }

    var subtitle: String {
        switch self {
        case .dailyPassFail: return "Each day must meet target independently"
        case .totalHours: return "Missed hours carry forward to next days"
        }
    }
}
