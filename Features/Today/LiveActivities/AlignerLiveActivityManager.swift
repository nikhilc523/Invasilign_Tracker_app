import Foundation

#if canImport(ActivityKit)
import ActivityKit

@MainActor
final class AlignerLiveActivityManager {
    static let shared = AlignerLiveActivityManager()

    private init() {}

    func sync(
        activeSession: RemovalSession?,
        currentTray: Tray?,
        now: Date = Date()
    ) async {
        guard #available(iOS 16.2, *), ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        guard let activeSession else {
            await endAll(now: now)
            return
        }

        let existing = Activity<AlignerLiveActivityAttributes>.activities

        if let current = existing.first(where: { $0.attributes.sessionID == activeSession.id.uuidString }) {
            let updatedState = AlignerLiveActivityAttributes.ContentState(
                startTime: activeSession.startTime,
                trayNumber: currentTray?.number
            )
            await current.update(ActivityContent(state: updatedState, staleDate: nil))

            for activity in existing where activity.id != current.id {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            return
        }

        for activity in existing {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        let attributes = AlignerLiveActivityAttributes(sessionID: activeSession.id.uuidString)
        let state = AlignerLiveActivityAttributes.ContentState(
            startTime: activeSession.startTime,
            trayNumber: currentTray?.number
        )

        do {
            _ = try Activity<AlignerLiveActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("❌ [LiveActivity] Failed to start: \(error)")
        }
    }

    func endAll(now: Date = Date()) async {
        guard #available(iOS 16.2, *), ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let endedState = AlignerLiveActivityAttributes.ContentState(startTime: now, trayNumber: nil)
        for activity in Activity<AlignerLiveActivityAttributes>.activities {
            await activity.end(ActivityContent(state: endedState, staleDate: now), dismissalPolicy: .immediate)
        }
    }
}
#endif
