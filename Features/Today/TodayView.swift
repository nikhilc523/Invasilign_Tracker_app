import SwiftUI
import UIKit

private struct TodayHomeModel {
    let greeting: String
    let dateText: String
    let isAlignerOut: Bool
    let onTrack: Bool

    let wearProgress: Double
    let wearText: String

    let streakProgress: Double
    let streakText: String

    let lifeProgress: Double
    let lifeText: String

    let wornTodayText: String
    let remainingText: String
    let trayInfoText: String  // Combined: "Day 1 · 14d left"
    let removedTodayText: String  // New: time removed today

    let statusText: String
    let weekIndicators: [WeekDayIndicator]
}

struct TodayView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @StateObject private var viewModel: TodayViewModel

    init(store: TrackingStore) {
        _viewModel = StateObject(wrappedValue: TodayViewModel(store: store))
    }

    var body: some View {
        let model = makeModel()

        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header(model)

                HomeGlassCard {
                    HStack {
                        Label(model.statusText, systemImage: model.onTrack ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(model.onTrack ? AppTheme.successGreen : AppTheme.warningOrange)
                        Spacer()
                        Text(viewModel.currentTray.map { "Tray \($0.number) · Day \(viewModel.trayDayNumber)" } ?? "No Tray")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }

                    RingClusterView(items: [
                        .init(title: "Wear", subtitle: model.wearText, progress: model.wearProgress, tint: HomeVisualTokens.ringEmerald),
                        .init(title: "Streak", subtitle: model.streakText, progress: model.streakProgress, tint: HomeVisualTokens.ringAmber),
                        .init(title: "Life", subtitle: model.lifeText, progress: model.lifeProgress, tint: HomeVisualTokens.ringCrimson)
                    ])
                    .padding(.top, 2)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        KPIStatTile(title: "Worn today", value: model.wornTodayText)
                        KPIStatTile(title: "Remaining", value: model.remainingText, valueColor: model.onTrack ? AppTheme.textPrimary : AppTheme.warningOrange)
                        KPIStatTile(title: "Tray progress", value: model.trayInfoText)
                        KPIStatTile(title: "Removed today", value: model.removedTodayText, valueColor: AppTheme.textSecondary)
                    }
                    .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.88), value: model.wornTodayText)
                }

                HomeGlassCard {
                    Text("THIS WEEK")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.textSecondary)

                    WeekStripView(days: model.weekIndicators)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .background(backgroundLayer.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            BottomActionDock {
                PrimaryToggleButton(isAlignerOut: viewModel.isAlignerOut) {
                    viewModel.toggleAligner()
                }
            }
        }
        .alert("Extend Tray?", isPresented: .constant(viewModel.shouldPromptExtension)) {
            Button("Extend +1 Day", role: nil) {
                viewModel.extendCurrentTray()
            }
            Button("No Thanks", role: .cancel) {}
        } message: {
            if let message = viewModel.extensionPromptMessage {
                Text(message)
            }
        }
    }

    private func header(_ model: TodayHomeModel) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(model.greeting)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                Text(model.dateText)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            }
            Spacer(minLength: 8)
            StatusPill(isAlignerOut: model.isAlignerOut)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: HomeVisualTokens.pageGradient(for: colorScheme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.08 : 0.28),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 14,
                endRadius: 420
            )
        }
    }

    private func makeModel() -> TodayHomeModel {
        let wornTodayText = Formatters.durationShort(minutes: viewModel.wearMinutes)
        let remainingMinutes = max(0, viewModel.remainingMinutes)
        let remainingText = remainingMinutes > 0 ? Formatters.durationShort(minutes: remainingMinutes) : "0m"

        // Calculate time removed today (only active removal sessions)
        let removedMinutes = viewModel.removedMinutesToday
        let removedTodayText = Formatters.durationShort(minutes: removedMinutes)
        
        // Combined tray info: "Day 1 · 14d left"
        let trayInfoText = "Day \(viewModel.trayDayNumber) · \(viewModel.trayDaysRemaining)d left"

        // Streak: consecutive days meeting the goal
        let currentStreak = viewModel.currentStreak
        let streakText = currentStreak == 1 ? "1 day" : "\(currentStreak) days"
        
        // Tray life: remaining capacity
        let trayLifeText: String
        if viewModel.isTrayEligibleForExtension {
            trayLifeText = "extend +1d"
        } else {
            trayLifeText = Formatters.durationShort(minutes: viewModel.trayLifeRemainingMinutes)
        }

        let weekIndicators = viewModel.weekDates.map { date in
            WeekDayIndicator(
                weekday: date.formatted(.dateTime.weekday(.narrow)),
                dayNumber: date.formatted(.dateTime.day()),
                isToday: DateService.isToday(date),
                status: viewModel.dayDotColor(for: date)
            )
        }

        return TodayHomeModel(
            greeting: Formatters.greeting(),
            dateText: Formatters.longDate.string(from: viewModel.today),
            isAlignerOut: viewModel.isAlignerOut,
            onTrack: viewModel.isOnTrack,
            wearProgress: min(max(viewModel.progress, 0), 1),
            wearText: wornTodayText,
            streakProgress: viewModel.streakProgress,
            streakText: streakText,
            lifeProgress: viewModel.trayLifeDebtProgress,
            lifeText: trayLifeText,
            wornTodayText: wornTodayText,
            remainingText: remainingText,
            trayInfoText: trayInfoText,
            removedTodayText: removedTodayText,
            statusText: viewModel.isOnTrack ? "On Track" : "Behind Schedule",
            weekIndicators: weekIndicators
        )
    }
}

#Preview("Home Screen") {
    let preview = TodayHomeModel(
        greeting: "Good afternoon",
        dateText: "Tuesday, February 24",
        isAlignerOut: true,
        onTrack: false,
        wearProgress: 0.82,
        wearText: "13h 9m",
        streakProgress: 0.0,
        streakText: "0 days",
        lifeProgress: 0.95,
        lifeText: "316h 50m",
        wornTodayText: "13h 9m",
        remainingText: "8h 45m",
        trayInfoText: "Day 1 · 14d left",
        removedTodayText: "10h 51m",
        statusText: "Behind Schedule",
        weekIndicators: [
            .init(weekday: "S", dayNumber: "22", isToday: false, status: .pass),
            .init(weekday: "M", dayNumber: "23", isToday: false, status: .pass),
            .init(weekday: "T", dayNumber: "24", isToday: true, status: .today),
            .init(weekday: "W", dayNumber: "25", isToday: false, status: .future),
            .init(weekday: "T", dayNumber: "26", isToday: false, status: .future),
            .init(weekday: "F", dayNumber: "27", isToday: false, status: .future),
            .init(weekday: "S", dayNumber: "28", isToday: false, status: .future)
        ]
    )

    ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(preview.greeting)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(preview.dateText)
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                Spacer()
                StatusPill(isAlignerOut: preview.isAlignerOut)
            }
            .padding(.vertical, 6)

            HomeGlassCard {
                HStack {
                    Label(preview.statusText, systemImage: "exclamationmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.warningOrange)
                    Spacer()
                    Text("Tray 1 · Day 1")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                RingClusterView(items: [
                    .init(title: "Wear", subtitle: preview.wearText, progress: preview.wearProgress, tint: HomeVisualTokens.ringEmerald),
                    .init(title: "Streak", subtitle: preview.streakText, progress: preview.streakProgress, tint: HomeVisualTokens.ringAmber),
                    .init(title: "Life", subtitle: preview.lifeText, progress: preview.lifeProgress, tint: HomeVisualTokens.ringCrimson)
                ])

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    KPIStatTile(title: "Worn today", value: preview.wornTodayText)
                    KPIStatTile(title: "Remaining", value: preview.remainingText, valueColor: AppTheme.warningOrange)
                    KPIStatTile(title: "Tray progress", value: preview.trayInfoText)
                    KPIStatTile(title: "Removed today", value: preview.removedTodayText, valueColor: AppTheme.textSecondary)
                }
            }

            HomeGlassCard {
                Text("THIS WEEK")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textSecondary)
                WeekStripView(days: preview.weekIndicators)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    .background(
        ZStack {
            LinearGradient(
                colors: HomeVisualTokens.pageGradient(for: .light),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                colors: [
                    Color.white.opacity(0.28),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 14,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    )
    .safeAreaInset(edge: .bottom) {
        BottomActionDock {
            PrimaryToggleButton(isAlignerOut: preview.isAlignerOut, action: {})
        }
    }
}
