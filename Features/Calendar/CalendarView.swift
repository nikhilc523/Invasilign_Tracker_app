import SwiftUI

struct CalendarView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: CalendarViewModel

    init(store: TrackingStore) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(store: store))
    }

    private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Page title
                Text("Calendar")
                    .font(.largeTitle.bold())
                    .tracking(-0.5)
                    .foregroundStyle(AppTheme.textPrimary)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)

                // Stats summary card
                CalendarMonthCard {
                    HStack(spacing: 16) {
                        stat(
                            value: "\(viewModel.monthStats.activeDays)",
                            label: "active day\(viewModel.monthStats.activeDays == 1 ? "" : "s")",
                            icon: "checkmark.circle.fill"
                        )
                        
                        Divider()
                            .frame(height: 32)
                            .background(CalendarVisualTokens.timelineDivider(for: colorScheme))
                        
                        stat(
                            value: "\(viewModel.monthStats.compliancePercentage)%",
                            label: "compliance",
                            icon: "chart.bar.fill"
                        )
                        
                        Divider()
                            .frame(height: 32)
                            .background(CalendarVisualTokens.timelineDivider(for: colorScheme))
                        
                        stat(
                            value: viewModel.monthStats.avgWear > 0 ? Formatters.durationShort(minutes: viewModel.monthStats.avgWear) : "-",
                            label: "avg wear/day",
                            icon: "clock.fill"
                        )
                    }
                }

                // Calendar month card
                CalendarMonthCard {
                    // Month navigation
                    HStack {
                        Button(action: viewModel.goBack) {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                                .frame(width: 36, height: 36)
                                .contentShape(Rectangle())
                                .background(
                                    Circle()
                                        .fill(.white.opacity(colorScheme == .dark ? 0.12 : 0.55))
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text(viewModel.monthTitle)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Button(action: viewModel.goForward) {
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                                .frame(width: 36, height: 36)
                                .contentShape(Rectangle())
                                .background(
                                    Circle()
                                        .fill(.white.opacity(colorScheme == .dark ? 0.12 : 0.55))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Month: \(viewModel.monthTitle)")

                    // Weekday headers
                    HStack(spacing: 0) {
                        ForEach(dayLabels, id: \.self) { label in
                            Text(label)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, 4)

                    // Calendar grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                        ForEach(Array(viewModel.calendarDays.enumerated()), id: \.offset) { _, day in
                            if let day {
                                CalendarDayCell(
                                    date: day,
                                    status: viewModel.status(for: day),
                                    isToday: DateService.isToday(day, now: viewModel.now),
                                    isFuture: DateService.isFutureDay(day, now: viewModel.now),
                                    isSelected: viewModel.selectedDate == day,
                                    onTap: { viewModel.selectDate(day) }
                                )
                            } else {
                                Color.clear
                                    .frame(height: 38)
                            }
                        }
                    }
                    .padding(.top, 2)

                    // Legend
                    HStack(spacing: 12) {
                        legend(color: AppTheme.successGreen, label: "Met")
                        legend(color: AppTheme.warningOrange, label: "Partial")
                        legend(color: AppTheme.errorRed, label: "Missed")
                    }
                    .font(.caption.weight(.medium))
                    .padding(.top, 8)
                }
                
                // Selected day details
                if let metrics = viewModel.selectedDayMetrics {
                    SelectedDayDetailCard(metrics: metrics)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 0.98).combined(with: .opacity)
                        ))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .animation(.spring(response: 0.35, dampingFraction: 0.82), value: viewModel.selectedDate)
        }
        .background(pageBackground)
    }
    
    private var pageBackground: some View {
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: colorScheme),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func stat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textSecondary)
                
                Text(value)
                    .font(.system(.body, design: .rounded).weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.textPrimary)
            }
            
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }

    private func legend(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

// MARK: - Previews

#Preview("Normal Month") {
    let store = PreviewCalendarStore.normalMonth
    return CalendarView(store: store)
}

#Preview("With Selection") {
    let store = PreviewCalendarStore.withSelection
    return CalendarView(store: store)
}

#Preview("Dark Mode") {
    let store = PreviewCalendarStore.normalMonth
    return CalendarView(store: store)
        .preferredColorScheme(.dark)
}

// MARK: - Preview Store

@MainActor
private struct PreviewCalendarStore {
    static var normalMonth: TrackingStore {
        let repo = PreviewCalendarRepository()
        let store = TrackingStore(repository: repo)
        
        // Add some past sessions
        Task {
            let date1 = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
            await store.toggleAligner(now: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: date1)!)
            await store.toggleAligner(now: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: date1)!)
            
            let date2 = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            await store.toggleAligner(now: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: date2)!)
            await store.toggleAligner(now: Calendar.current.date(bySettingHour: 13, minute: 45, second: 0, of: date2)!)
        }
        
        return store
    }
    
    static var withSelection: TrackingStore {
        let repo = PreviewCalendarRepository()
        let store = TrackingStore(repository: repo)
        
        // Add sessions for selected day
        Task {
            let targetDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
            
            await store.toggleAligner(now: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: targetDate)!)
            await store.toggleAligner(now: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: targetDate)!)
            
            await store.toggleAligner(now: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: targetDate)!)
            await store.toggleAligner(now: Calendar.current.date(bySettingHour: 15, minute: 15, second: 0, of: targetDate)!)
        }
        
        return store
    }
}

@MainActor
private final class PreviewCalendarRepository: TrackingRepository {
    private var sessions: [RemovalSession] = []
    private var trays: [Tray] = [Tray(id: UUID(), number: 5, startDate: Date().addingTimeInterval(-14 * 24 * 3600), plannedDays: 14)]
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



