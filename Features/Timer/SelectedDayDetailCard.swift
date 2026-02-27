import SwiftUI

struct SelectedDayDetailCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let metrics: SelectedDayMetrics
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(metrics.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                    
                    ComplianceStatusBadge(status: metrics.complianceStatus)
                }
                
                Spacer()
            }
            
            Divider()
                .background(CalendarVisualTokens.timelineDivider(for: colorScheme))
            
            // Core Metrics
            if metrics.complianceStatus == .future {
                futureStateView
            } else {
                metricsView
                
                if !metrics.sessions.isEmpty {
                    Divider()
                        .background(CalendarVisualTokens.timelineDivider(for: colorScheme))
                    
                    sessionTimelineView
                } else {
                    emptySessionsView
                }
            }
        }
        .padding(20)
        .background {
            ZStack {
                shape.fill(.thinMaterial)
                shape
                    .fill(CalendarVisualTokens.cardTint(for: colorScheme))
                    .allowsHitTesting(false)
                shape
                    .fill(
                        LinearGradient(
                            colors: CalendarVisualTokens.cardTopGloss(for: colorScheme),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 22)
                    .clipShape(shape)
                    .allowsHitTesting(false)
            }
        }
        .overlay {
            shape
                .strokeBorder(CalendarVisualTokens.cardStroke(for: colorScheme), lineWidth: 1.0)
                .allowsHitTesting(false)
        }
        .shadow(
            color: CalendarVisualTokens.cardShadow(for: colorScheme).color,
            radius: CalendarVisualTokens.cardShadow(for: colorScheme).radius,
            y: CalendarVisualTokens.cardShadow(for: colorScheme).y
        )
    }
    
    private var metricsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Summary")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricPair(
                    value: Formatters.durationShort(minutes: metrics.wearMinutes),
                    label: "Worn",
                    icon: "checkmark.circle.fill",
                    color: AppTheme.successGreen
                )
                
                MetricPair(
                    value: Formatters.durationShort(minutes: metrics.removalMinutes),
                    label: "Out",
                    icon: "clock.fill",
                    color: AppTheme.warningOrange
                )
                
                MetricPair(
                    value: "\(metrics.sessionsCount)",
                    label: "Sessions",
                    icon: "list.bullet",
                    color: AppTheme.textPrimary
                )
                
                MetricPair(
                    value: goalDeltaText,
                    label: "vs Target",
                    icon: goalDeltaIcon,
                    color: goalDeltaColor
                )
            }
        }
    }
    
    private var sessionTimelineView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Removal Sessions")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            VStack(spacing: 8) {
                ForEach(metrics.sessions) { session in
                    SessionTimelineRow(session: session)
                }
            }
        }
    }
    
    private var emptySessionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No Removals")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("No removal sessions logged for this day")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.vertical, 8)
    }
    
    private var futureStateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Future Date")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text("No tracking data available yet")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var goalDeltaText: String {
        if metrics.goalDelta >= 0 {
            return "Met"
        }
        let deficit = abs(metrics.goalDelta)
        return "-\(Formatters.durationShort(minutes: deficit))"
    }
    
    private var goalDeltaIcon: String {
        metrics.goalDelta >= 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }
    
    private var goalDeltaColor: Color {
        if metrics.goalDelta >= 0 {
            return AppTheme.successGreen
        } else if metrics.goalDelta >= -60 {
            return AppTheme.warningOrange
        } else {
            return AppTheme.errorRed
        }
    }
}

struct MetricPair: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct ComplianceStatusBadge: View {
    let status: DayComplianceStatus
    
    var body: some View {
        let colors = CalendarVisualTokens.statusBadgeColors(for: status)
        
        HStack(spacing: 6) {
            Circle()
                .fill(colors.text)
                .frame(width: 6, height: 6)
            
            Text(statusText)
                .font(.caption.weight(.bold))
                .foregroundStyle(colors.text)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(colors.bg, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Status: \(statusText)")
    }
    
    private var statusText: String {
        switch status {
        case .targetMet: return "Target Met"
        case .partial: return "Partial"
        case .missed: return "Missed"
        case .future: return "Future"
        case .inProgress: return "In Progress"
        }
    }
}

struct SessionTimelineRow: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let session: DaySession
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(session.putBackAt == nil ? AppTheme.warningOrange : AppTheme.textSecondary.opacity(0.5))
                .frame(width: 8, height: 8)
            
            // Time range
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(Formatters.timeOfDay.string(from: session.removedAt))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                    
                    if let putBack = session.putBackAt {
                        Text(Formatters.timeOfDay.string(from: putBack))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                    } else {
                        Text("ongoing")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.warningOrange)
                    }
                }
                
                Text(Formatters.durationShort(minutes: session.durationMinutes))
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            Spacer()
            
            // LIVE badge if ongoing
            if session.putBackAt == nil {
                Text("LIVE")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.warningOrange, in: Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            CalendarVisualTokens.timelineRowBackground(for: colorScheme),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(CalendarVisualTokens.timelineRowStroke(for: colorScheme), lineWidth: 0.5)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        let startTime = Formatters.timeOfDay.string(from: session.removedAt)
        if let endTime = session.putBackAt {
            return "Removed at \(startTime), put back at \(Formatters.timeOfDay.string(from: endTime)), duration \(Formatters.durationShort(minutes: session.durationMinutes))"
        }
        return "Removed at \(startTime), ongoing session, duration \(Formatters.durationShort(minutes: session.durationMinutes))"
    }
}
