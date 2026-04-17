import Foundation
import WatchConnectivity
import Combine
import WidgetKit

/// watchOS-side WatchConnectivity Manager
/// Handles bidirectional communication with iPhone
@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published private(set) var currentState: WatchStatePayload?
    @Published private(set) var isConnected = false
    @Published private(set) var lastSyncDate: Date?
    
    private let session: WCSession? = WCSession.isSupported() ? .default : nil
    
    private override init() {
        super.init()
        session?.delegate = self
        session?.activate()
        print("⌚️ [WatchConnectivity] Watch manager initialized")
    }
    
    /// Request sync from iPhone
    func requestSync() {
        sendCommand(.requestSync)
    }
    
    /// Tell iPhone to start a session
    func startSession() {
        print("⌚️ [WatchConnectivity] Sending start command")
        sendCommand(.startSession)
    }
    
    /// Tell iPhone to stop a session
    func stopSession() {
        print("⌚️ [WatchConnectivity] Sending stop command")
        sendCommand(.stopSession)
    }
    
    private func sendCommand(_ command: WatchCommand) {
        guard let session = session else {
            print("⌚️ [WatchConnectivity] Session not available")
            return
        }
        
        let message: [String: Any] = ["command": command.rawValue]
        
        if session.isReachable {
            // Phone is reachable - use interactive messaging
            session.sendMessage(message, replyHandler: { [weak self] reply in
                Task { @MainActor in
                    self?.handleReply(reply)
                }
            }) { error in
                print("⌚️ [WatchConnectivity] Failed to send command: \(error.localizedDescription)")
            }
        } else {
            // Phone not reachable - queue it
            do {
                try session.updateApplicationContext(message)
                print("⌚️ [WatchConnectivity] Command queued in application context")
            } catch {
                print("⌚️ [WatchConnectivity] Failed to queue command: \(error)")
            }
        }
    }
    
    private func handleReply(_ reply: [String: Any]) {
        if let stateData = reply["state"] as? Data {
            decodeAndUpdateState(stateData)
        }
    }
    
    private func decodeAndUpdateState(_ data: Data) {
        do {
            let payload = try JSONDecoder().decode(WatchStatePayload.self, from: data)
            currentState = payload
            lastSyncDate = Date()
            
            // Save to app-group storage so widget/complications can read it.
            saveStateForWidget(payload)
            
            // Reload widget timelines
            #if canImport(WidgetKit)
            WidgetKit.WidgetCenter.shared.reloadAllTimelines()
            #endif
            
            print("⌚️ [WatchConnectivity] State updated - Aligner out: \(payload.isAlignerOut)")
        } catch {
            print("⌚️ [WatchConnectivity] Failed to decode state: \(error)")
        }
    }

    private func saveStateForWidget(_ payload: WatchStatePayload) {
        let groupIdentifier = "group.com.example.invisaligntracker"
        guard let defaults = UserDefaults(suiteName: groupIdentifier) else {
            print("⌚️ [WatchConnectivity] App Group not configured")
            return
        }

        defaults.set(payload.isAlignerOut, forKey: "widget_isAlignerOut")
        defaults.set(payload.wornTodayMinutes, forKey: "widget_wornMinutes")
        defaults.set(payload.outTodayMinutes, forKey: "widget_outMinutes")
        defaults.set(payload.targetMinutes, forKey: "widget_targetMinutes")
        defaults.set(payload.cumulativeDeficitMinutes, forKey: "widget_deficitMinutes")
        defaults.set(payload.sessionStart, forKey: "widget_sessionStart")

        if let trayNumber = payload.currentTrayNumber {
            defaults.set(trayNumber, forKey: "widget_trayNumber")
        } else {
            defaults.removeObject(forKey: "widget_trayNumber")
        }

        defaults.set(Date(), forKey: "widget_lastUpdate")
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            if let error = error {
                print("⌚️ [WatchConnectivity] Activation failed: \(error.localizedDescription)")
                isConnected = false
            } else {
                print("⌚️ [WatchConnectivity] Session activated: \(activationState.rawValue)")
                isConnected = activationState == .activated
                
                if isConnected {
                    requestSync()
                }
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("⌚️ [WatchConnectivity] Received message from iPhone")
        
        if let stateData = message["state"] as? Data {
            Task { @MainActor in
                decodeAndUpdateState(stateData)
            }
        }
    }
    
    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        print("⌚️ [WatchConnectivity] Received application context")
        
        if let stateData = applicationContext["state"] as? Data {
            Task { @MainActor in
                decodeAndUpdateState(stateData)
            }
        }
    }
}
