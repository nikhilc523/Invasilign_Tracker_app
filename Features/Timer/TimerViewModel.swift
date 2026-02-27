import Foundation
import Combine

@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var sessions: [RemovalSession] = []
    @Published private(set) var settings: TrackerSettings = .default
    @Published private(set) var isAlignerOut = false
    @Published private(set) var activeSession: RemovalSession?
    @Published private(set) var now = Date()

    private let store: TrackingStore
    private var timer: AnyCancellable?

    init(store: TrackingStore) {
        self.store = store
        store.$sessions.assign(to: &$sessions)
        store.$settings.assign(to: &$settings)
        store.$sessions
            .map { $0.first(where: { $0.isActive }) }
            .assign(to: &$activeSession)
        store.$sessions
            .map { $0.contains(where: { $0.isActive }) }
            .assign(to: &$isAlignerOut)

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] value in
                self?.now = value
            }
    }

    deinit { timer?.cancel() }

    var today: Date { DateService.startOfDay(for: now) }

    var currentSessionSeconds: TimeInterval {
        guard let activeSession else { return 0 }
        return max(0, now.timeIntervalSince(activeSession.startTime))
    }

    var todaySessions: [RemovalSession] {
        TrackerCalculator.sessionsOverlapping(sessions, date: today, now: now)
            .sorted { $0.startTime > $1.startTime }
    }

    var totalRemovalMinutes: Double {
        TrackerCalculator.removalMinutes(on: today, sessions: sessions, now: now)
    }

    func toggleAligner() {
        Task { await store.toggleAligner(now: now) }
    }

    func deleteSession(id: UUID) {
        Task { await store.deleteSession(id: id) }
    }
}
