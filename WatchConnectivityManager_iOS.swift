import Foundation
import WatchConnectivity

/// iOS-side WatchConnectivity Manager
/// Handles bidirectional communication with Apple Watch
@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private var trackingStore: TrackingStore?
    private let session: WCSession? = WCSession.isSupported() ? .default : nil
    
    private override init() {
        super.init()
        session?.delegate = self
        session?.activate()
        print("📱 [WatchConnectivity] iOS manager initialized")
    }
    
    /// Call this once from AppContext to link the tracking store
    func configure(with store: TrackingStore) {
        self.trackingStore = store
        print("📱 [WatchConnectivity] Configured with TrackingStore")
    }
    
    /// Send current state to watch
    func syncToWatch() {
        guard let session = session else {
            print("📱 [WatchConnectivity] Session not available")
            return
        }
        
        guard let store = trackingStore else {
            print("📱 [WatchConnectivity] TrackingStore not configured")
            return
        }
        
        let payload = buildPayload(from: store)
        
        do {
            let data = try JSONEncoder().encode(payload)
            let message: [String: Any] = ["state": data]
            
            if session.isReachable {
                // Watch is reachable - send immediately
                session.sendMessage(message, replyHandler: nil) { error in
                    print("📱 [WatchConnectivity] Failed to send state: \(error.localizedDescription)")
                }
                print("📱 [WatchConnectivity] Sent state to watch (interactive)")
            } else {
                // Watch not reachable - use application context for background delivery
                do {
                    try session.updateApplicationContext(message)
                    print("📱 [WatchConnectivity] Queued state in application context")
                } catch {
                    print("📱 [WatchConnectivity] Failed to update application context: \(error)")
                }
            }
        } catch {
            print("📱 [WatchConnectivity] Failed to encode payload: \(error)")
        }
    }
    
    /// Build payload from current store state
    private func buildPayload(from store: TrackingStore) -> WatchStatePayload {
        let now = Date()
        let today = DateService.startOfDay(for: now)
        let dayStart = today
        let dayEnd = DateService.addDays(1, to: dayStart)

        let todaysSessions = TrackerCalculator.sessionsOverlapping(
            store.sessions,
            date: today,
            now: now
        )

        let wornTodayMinutes = Int(
            TrackerCalculator.wearMinutes(
                on: today,
                sessions: store.sessions,
                now: now,
                trayStartDate: store.currentTray?.startDate
            )
        )

        let outTodayMinutes = Int(
            TrackerCalculator.removalMinutes(
                on: today,
                sessions: store.sessions,
                now: now
            )
        )

        let targetMinutes = store.settings.targetHoursPerDay * 60
        
        var cumulativeDeficitMinutes = 0
        if let currentTray = store.currentTray {
            cumulativeDeficitMinutes = Int(
                TrackerCalculator.trayLifeShortfallMinutes(
                    for: currentTray,
                    sessions: store.sessions,
                    targetMinutes: Double(targetMinutes),
                    now: now
                )
            )
        }
        
        let sessionSummaries = todaysSessions.map { session in
            let clampedStart = max(session.startTime, dayStart)
            let clampedEnd = min(session.endTime ?? now, dayEnd)
            let clampedDuration = max(0, Int(clampedEnd.timeIntervalSince(clampedStart) / 60))

            let duration: Int
            if let endTime = session.endTime {
                duration = min(clampedDuration, Int(endTime.timeIntervalSince(session.startTime) / 60))
            } else {
                duration = clampedDuration
            }
            
            return WatchStatePayload.SessionSummary(
                startTime: clampedStart,
                endTime: session.endTime,
                durationMinutes: duration
            )
        }
        
        return WatchStatePayload(
            isAlignerOut: store.isAlignerOut,
            wornTodayMinutes: wornTodayMinutes,
            outTodayMinutes: outTodayMinutes,
            targetMinutes: targetMinutes,
            cumulativeDeficitMinutes: cumulativeDeficitMinutes,
            sessionStart: store.activeSession?.startTime,
            currentTrayNumber: store.currentTray?.number,
            todaySessions: sessionSummaries
        )
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("📱 [WatchConnectivity] Activation failed: \(error.localizedDescription)")
        } else {
            print("📱 [WatchConnectivity] Session activated: \(activationState.rawValue)")
        }
    }
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("📱 [WatchConnectivity] Session became inactive")
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        print("📱 [WatchConnectivity] Session deactivated")
        session.activate()
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("📱 [WatchConnectivity] Received message from watch")
        
        guard let commandString = message["command"] as? String,
              let command = WatchCommand(rawValue: commandString) else {
            print("📱 [WatchConnectivity] Invalid command")
            return
        }
        
        Task { @MainActor in
            await handleCommand(command)
        }
    }
    
    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        print("📱 [WatchConnectivity] Received message with reply handler")
        
        guard let commandString = message["command"] as? String,
              let command = WatchCommand(rawValue: commandString) else {
            replyHandler(["error": "Invalid command"])
            return
        }
        
        Task { @MainActor in
            await handleCommand(command)
            
            // Send updated state back
            guard let store = trackingStore else {
                replyHandler(["error": "Store not configured"])
                return
            }
            
            let payload = buildPayload(from: store)
            do {
                let data = try JSONEncoder().encode(payload)
                replyHandler(["state": data])
            } catch {
                replyHandler(["error": "Failed to encode state"])
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        print("📱 [WatchConnectivity] Received application context from watch")

        guard let commandString = applicationContext["command"] as? String,
              let command = WatchCommand(rawValue: commandString) else {
            print("📱 [WatchConnectivity] Invalid application context command")
            return
        }

        Task { @MainActor in
            await handleCommand(command)
            syncToWatch()
        }
    }
    
    private func handleCommand(_ command: WatchCommand) async {
        guard let store = trackingStore else {
            print("📱 [WatchConnectivity] TrackingStore not configured")
            return
        }
        
        switch command {
        case .startSession:
            print("📱 [WatchConnectivity] Starting session from watch command")
            if !store.isAlignerOut {
                await store.toggleAligner()
                syncToWatch()
            }
            
        case .stopSession:
            print("📱 [WatchConnectivity] Stopping session from watch command")
            if store.isAlignerOut {
                await store.toggleAligner()
#if canImport(ActivityKit)
                // Hard stop to avoid stale Dynamic Island/Live Activity after watch-origin stop.
                await AlignerLiveActivityManager.shared.endAll()
#endif
                syncToWatch()
            }
            
        case .requestSync:
            print("📱 [WatchConnectivity] Sync requested from watch")
            syncToWatch()
        }
    }
}
