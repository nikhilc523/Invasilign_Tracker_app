import Foundation

#if canImport(ActivityKit)
import ActivityKit

struct AlignerLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startTime: Date
        var trayNumber: Int?
    }

    var sessionID: String
}
#endif
