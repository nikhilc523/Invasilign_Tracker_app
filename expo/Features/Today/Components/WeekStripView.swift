import SwiftUI

struct WeekDayIndicator: Identifiable {
    let id = UUID()
    let weekday: String
    let dayNumber: String
    let isToday: Bool
    let status: DayStatus
}

struct WeekStripView: View {
    @Environment(\.colorScheme) private var colorScheme
    let days: [WeekDayIndicator]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days) { day in
                VStack(spacing: 6) {
                    Text(day.weekday)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(day.dayNumber)
                        .font(.footnote.weight(day.isToday ? .bold : .semibold))
                        .foregroundStyle(day.isToday ? .white : AppTheme.textPrimary)
                        .frame(width: 30, height: 30)
                        .background(day.isToday ? AppTheme.textPrimary : .clear, in: Circle())

                    Circle()
                        .fill(dotColor(for: day.status))
                        .frame(width: 7, height: 7)
                        .shadow(color: dotColor(for: day.status).opacity(0.35), radius: 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(
                    HomeVisualTokens.weekDayBackground(isToday: day.isToday, scheme: colorScheme),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            HomeVisualTokens.weekDayStroke(isToday: day.isToday, scheme: colorScheme),
                            lineWidth: 1.0
                        )
                }
                .shadow(
                    color: day.isToday ? .black.opacity(0.06) : .clear,
                    radius: 5,
                    x: 0,
                    y: 2
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(day.weekday) \(day.dayNumber), \(statusLabel(day.status))")
            }
        }
    }

    private func dotColor(for status: DayStatus) -> Color {
        switch status {
        case .pass: return AppTheme.successGreen
        case .warn: return AppTheme.warningOrange
        case .fail: return AppTheme.errorRed
        case .today: return AppTheme.textSecondary
        case .future, .empty: return AppTheme.progressTrack
        }
    }

    private func statusLabel(_ status: DayStatus) -> String {
        switch status {
        case .pass: return "target met"
        case .warn: return "partial"
        case .fail: return "behind"
        case .today: return "today"
        case .future: return "future"
        case .empty: return "no data"
        }
    }
}

#Preview {
    WeekStripView(days: [
        .init(weekday: "S", dayNumber: "23", isToday: false, status: .pass),
        .init(weekday: "M", dayNumber: "24", isToday: true, status: .today),
        .init(weekday: "T", dayNumber: "25", isToday: false, status: .warn),
        .init(weekday: "W", dayNumber: "26", isToday: false, status: .fail),
        .init(weekday: "T", dayNumber: "27", isToday: false, status: .future),
        .init(weekday: "F", dayNumber: "28", isToday: false, status: .future),
        .init(weekday: "S", dayNumber: "29", isToday: false, status: .future)
    ])
    .padding()
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
