import SwiftUI

struct TimerView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: TimerViewModel
    @State private var sessionToDelete: RemovalSession?

    init(store: TrackingStore) {
        _viewModel = StateObject(wrappedValue: TimerViewModel(store: store))
    }

    var body: some View {
        ZStack {
            // Atmospheric background
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Page title
                    Text("Timer")
                        .font(.largeTitle.bold())
                        .tracking(-0.5)
                        .foregroundStyle(AppTheme.textPrimary)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                    
                    // MARK: - Live Session Hero
                    TimerHeroCard(
                        isAlignerOut: viewModel.isAlignerOut,
                        currentTime: viewModel.isAlignerOut
                            ? Formatters.mmss(seconds: viewModel.currentSessionSeconds)
                            : "00:00",
                        sessionsToday: viewModel.todaySessions.count,
                        totalOutToday: Formatters.durationShort(minutes: viewModel.totalRemovalMinutes)
                    )
                    
                    // MARK: - Primary CTA
                    TimerPrimaryButton(
                        isAlignerOut: viewModel.isAlignerOut,
                        action: viewModel.toggleAligner
                    )
                    
                    // MARK: - Session History
                    SessionHistoryCard(
                        sessions: viewModel.todaySessions,
                        onDeleteSession: { session in
                            sessionToDelete = session
                        },
                        timeRangeFormatter: timeRange,
                        durationFormatter: { session in
                            Formatters.mmss(seconds: duration(for: session))
                        }
                    )
                    
                    // Daily target footer
                    Text("Daily target: \(viewModel.settings.targetHoursPerDay)h wear time")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(pageBackground)
        .confirmationDialog(
            "Delete Session",
            isPresented: Binding<Bool>(
                get: { sessionToDelete != nil },
                set: { newValue in if !newValue { sessionToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    viewModel.deleteSession(id: session.id)
                    sessionToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                sessionToDelete = nil
            }
        } message: {
            Text("Remove this removal session?")
        }
    }
    
    // MARK: - Background
    
    private var pageBackground: some View {
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: colorScheme),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var backgroundGradient: some View {
        RadialGradient(
            colors: TimerVisualTokens.atmosphericGradient(for: colorScheme),
            center: .top,
            startRadius: 1,
            endRadius: 400
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Helpers
    
    private func duration(for session: RemovalSession) -> TimeInterval {
        (session.endTime ?? viewModel.now).timeIntervalSince(session.startTime)
    }

    private func timeRange(for session: RemovalSession) -> String {
        let start = Formatters.timeOfDay.string(from: session.startTime)
        if let end = session.endTime {
            return "\(start) -> \(Formatters.timeOfDay.string(from: end))"
        }
        return "\(start) (ongoing)"
    }
}
// MARK: - Previews

#Preview("Aligners Out (Active Timer) - Light") {
    TimerView(store: PreviewStore.withActiveSession)
}

#Preview("Aligners In - Light") {
    TimerView(store: PreviewStore.withCompletedSessions)
}

#Preview("Multiple Sessions - Light") {
    TimerView(store: PreviewStore.withMultipleSessions)
}

#Preview("Aligners Out - Dark") {
    TimerView(store: PreviewStore.withActiveSession)
        .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    TimerView(store: PreviewStore.empty)
}

// MARK: - Preview Store Helper

@MainActor
private struct PreviewStore {
    static var withActiveSession: TrackingStore {
        let repo = PreviewRepository()
        let store = TrackingStore(repository: repo)
        Task {
            await store.toggleAligner(now: Date().addingTimeInterval(-4500))
        }
        return store
    }
    
    static var withCompletedSessions: TrackingStore {
        let repo = PreviewRepository()
        let store = TrackingStore(repository: repo)
        Task {
            await store.toggleAligner(now: Date().addingTimeInterval(-7200))
            await store.toggleAligner(now: Date().addingTimeInterval(-3600))
        }
        return store
    }
    
    static var withMultipleSessions: TrackingStore {
        let repo = PreviewRepository()
        let store = TrackingStore(repository: repo)
        Task {
            await store.toggleAligner(now: Date().addingTimeInterval(-14400))
            await store.toggleAligner(now: Date().addingTimeInterval(-10800))
            await store.toggleAligner(now: Date().addingTimeInterval(-7200))
            await store.toggleAligner(now: Date().addingTimeInterval(-3600))
            await store.toggleAligner(now: Date().addingTimeInterval(-1800))
        }
        return store
    }
    
    static var empty: TrackingStore {
        let repo = PreviewRepository()
        return TrackingStore(repository: repo)
    }
}

// MARK: - Preview Repository
@MainActor
private final class PreviewRepository: TrackingRepository {
    private var sessions: [RemovalSession] = []
    private var trays: [Tray] = [Tray(id: UUID(), number: 1, startDate: Date(), plannedDays: 14)]
    private var settings: TrackerSettings = .default
    
    func load() async throws -> TrackingSnapshot {
        TrackingSnapshot(sessions: sessions, trays: trays, settings: settings)
    }
    
    func toggleAligner(at now: Date) async throws {
        if let index = sessions.firstIndex(where: { $0.isActive }) {
            sessions[index] = RemovalSession(
                id: sessions[index].id,
                startTime: sessions[index].startTime,
                endTime: now
            )
        } else {
            sessions.append(RemovalSession(id: UUID(), startTime: now, endTime: nil))
        }
    }
    
    func deleteSession(id: UUID) async throws {
        sessions.removeAll { $0.id == id }
    }
    
    func addTray(number: Int, plannedDays: Int, startDate: Date) async throws {
        let tray = Tray(id: UUID(), number: number, startDate: startDate, plannedDays: plannedDays)
        trays.append(tray)
        settings.currentTrayID = tray.id
    }
    
    func deleteTray(id: UUID) async throws {
        trays.removeAll { $0.id == id }
        if settings.currentTrayID == id {
            settings.currentTrayID = trays.first?.id
        }
    }
    
    func setCurrentTray(id: UUID?) async throws {
        settings.currentTrayID = id
    }

    func incrementTrayPlannedDays(id: UUID, by days: Int) async throws {
        guard days > 0, let index = trays.firstIndex(where: { $0.id == id }) else { return }
        trays[index].plannedDays += days
    }
    
    func updateSettings(_ settings: TrackerSettings) async throws {
        self.settings = settings
    }
    
    func resetAllData(now: Date) async throws {
        sessions.removeAll()
        trays.removeAll()
        settings = .default
        let tray = Tray(id: UUID(), number: 1, startDate: now, plannedDays: settings.plannedDaysPerTray)
        trays.append(tray)
        settings.currentTrayID = tray.id
    }
}

