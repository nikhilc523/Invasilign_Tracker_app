import SwiftUI

struct SessionHistoryCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let sessions: [RemovalSession]
    let onDeleteSession: (RemovalSession) -> Void
    let timeRangeFormatter: (RemovalSession) -> String
    let durationFormatter: (RemovalSession) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header
            Text("Today's Removals")
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
            
            if sessions.isEmpty {
                emptyState
            } else {
                sessionList
            }
        }
        .padding(20)
        .background {
            ZStack {
                // Base material
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Warm tint overlay
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(TimerVisualTokens.historyCardTint(for: colorScheme))
            }
        }
        .overlay {
            // Stroke
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(TimerVisualTokens.historyCardStroke(for: colorScheme), lineWidth: 1)
        }
        .shadow(
            color: TimerVisualTokens.historyCardShadow(for: colorScheme).color,
            radius: TimerVisualTokens.historyCardShadow(for: colorScheme).radius,
            y: TimerVisualTokens.historyCardShadow(for: colorScheme).y
        )
    }
    
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No removals yet")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("Tap the button above when you take your aligners out")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.vertical, 4)
    }
    
    private var sessionList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                if index > 0 {
                    Rectangle()
                        .fill(TimerVisualTokens.sessionRowSeparator(for: colorScheme))
                        .frame(height: 0.5)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                }
                
                SessionRowView(
                    session: session,
                    timeRange: timeRangeFormatter(session),
                    duration: durationFormatter(session),
                    onDelete: { onDeleteSession(session) }
                )
            }
            
            Text("Tap a session to delete")
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textTertiary)
                .opacity(0.7)
                .padding(.top, 14)
        }
    }
}

struct SessionRowView: View {
    let session: RemovalSession
    let timeRange: String
    let duration: String
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onDelete) {
            HStack(spacing: 12) {
                // Status indicator dot
                Circle()
                    .fill(session.isActive ? AppTheme.warningOrange : AppTheme.textSecondary.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .shadow(
                        color: session.isActive ? AppTheme.warningOrange.opacity(0.5) : .clear,
                        radius: 3
                    )
                
                // Time and duration
                VStack(alignment: .leading, spacing: 3) {
                    Text(timeRange)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text(duration)
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Spacer()
                
                // LIVE badge
                if session.isActive {
                    Text("LIVE")
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background {
                            Capsule()
                                .fill(AppTheme.warningOrange)
                        }
                        .shadow(color: AppTheme.warningOrange.opacity(0.32), radius: 4)
                        .alignmentGuide(VerticalAlignment.center) { d in d[VerticalAlignment.center] }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(timeRange), duration \(duration)")
        .accessibilityHint(session.isActive ? "Live session. Double tap to delete." : "Double tap to delete.")
    }
}

#Preview("With Sessions - Light") {
    SessionHistoryCard(
        sessions: [
            RemovalSession(id: UUID(), startTime: Date().addingTimeInterval(-7200), endTime: Date().addingTimeInterval(-3600)),
            RemovalSession(id: UUID(), startTime: Date().addingTimeInterval(-1800), endTime: nil)
        ],
        onDeleteSession: { _ in },
        timeRangeFormatter: { _ in "2:30 PM -> 3:45 PM" },
        durationFormatter: { _ in "01:15:00" }
    )
    .padding()
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}

#Preview("Empty State - Dark") {
    SessionHistoryCard(
        sessions: [],
        onDeleteSession: { _ in },
        timeRangeFormatter: { _ in "" },
        durationFormatter: { _ in "" }
    )
    .padding()
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .dark),
            startPoint: .top,
            endPoint: .bottom
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("Multiple Sessions") {
    SessionHistoryCard(
        sessions: [
            RemovalSession(id: UUID(), startTime: Date().addingTimeInterval(-14400), endTime: Date().addingTimeInterval(-10800)),
            RemovalSession(id: UUID(), startTime: Date().addingTimeInterval(-7200), endTime: Date().addingTimeInterval(-3600)),
            RemovalSession(id: UUID(), startTime: Date().addingTimeInterval(-1800), endTime: nil)
        ],
        onDeleteSession: { _ in },
        timeRangeFormatter: { session in
            if session.isActive {
                return "3:00 PM (ongoing)"
            }
            return "12:00 PM -> 1:15 PM"
        },
        durationFormatter: { _ in "01:15:00" }
    )
    .padding()
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
