import Foundation

/// Lightweight payload for syncing state between iPhone and Apple Watch
struct WatchStatePayload: Codable, Sendable {
    let isAlignerOut: Bool
    let wornTodayMinutes: Int
    let outTodayMinutes: Int
    let targetMinutes: Int
    let cumulativeDeficitMinutes: Int
    let sessionStart: Date?
    let currentTrayNumber: Int?
    let todaySessions: [SessionSummary]
    
    struct SessionSummary: Codable, Sendable {
        let startTime: Date
        let endTime: Date?
        let durationMinutes: Int
    }
    
    init(
        isAlignerOut: Bool,
        wornTodayMinutes: Int,
        outTodayMinutes: Int,
        targetMinutes: Int,
        cumulativeDeficitMinutes: Int,
        sessionStart: Date?,
        currentTrayNumber: Int?,
        todaySessions: [SessionSummary]
    ) {
        self.isAlignerOut = isAlignerOut
        self.wornTodayMinutes = wornTodayMinutes
        self.outTodayMinutes = outTodayMinutes
        self.targetMinutes = targetMinutes
        self.cumulativeDeficitMinutes = cumulativeDeficitMinutes
        self.sessionStart = sessionStart
        self.currentTrayNumber = currentTrayNumber
        self.todaySessions = todaySessions
    }
}

/// Commands that can be sent from Watch to iPhone
enum WatchCommand: String, Codable {
    case startSession = "start"
    case stopSession = "stop"
    case requestSync = "sync"
}
