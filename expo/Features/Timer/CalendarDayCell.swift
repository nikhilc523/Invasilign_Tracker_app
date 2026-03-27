import SwiftUI
import UIKit

struct CalendarDayCell: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let date: Date
    let status: DayStatus
    let isToday: Bool
    let isFuture: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if !reduceMotion {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            onTap()
        }) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.day()))
                    .font(.subheadline.weight(isToday || isSelected ? .bold : .medium))
                    .foregroundStyle(textColor)
                
                if status == .today {
                    Circle().fill(.white.opacity(0.85)).frame(width: 5, height: 5)
                } else if status == .pass || status == .warn || status == .fail {
                    Circle().fill(dotColor(status)).frame(width: 5, height: 5)
                } else {
                    Spacer().frame(height: 5)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 38)
            .padding(.vertical, 5)
            .background(
                CalendarVisualTokens.dayCellBackground(
                    isSelected: isSelected,
                    isToday: isToday,
                    scheme: colorScheme
                ),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(
                        CalendarVisualTokens.dayCellStroke(isSelected: isSelected, scheme: colorScheme),
                        lineWidth: 1.5
                    )
                    .allowsHitTesting(false)
            }
            .shadow(
                color: CalendarVisualTokens.dayCellGlow(isSelected: isSelected).color,
                radius: CalendarVisualTokens.dayCellGlow(isSelected: isSelected).radius
            )
            .scaleEffect(isSelected && !reduceMotion ? 1.05 : 1.0)
            .animation(.spring(response: 0.30, dampingFraction: 0.75), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    private var textColor: Color {
        if isToday && !isSelected {
            return .white
        }
        if isFuture {
            return AppTheme.textTertiary
        }
        return AppTheme.textPrimary
    }
    
    private func dotColor(_ status: DayStatus) -> Color {
        switch status {
        case .pass: return AppTheme.successGreen
        case .warn: return AppTheme.warningOrange
        case .fail: return AppTheme.errorRed
        default: return .clear
        }
    }
    
    private var accessibilityLabel: String {
        let dateStr = date.formatted(.dateTime.weekday(.wide).month(.wide).day())
        let statusStr: String
        switch status {
        case .pass: statusStr = "Target met"
        case .warn: statusStr = "Partial"
        case .fail: statusStr = "Missed"
        case .today: statusStr = "Today"
        case .future: statusStr = "Future"
        case .empty: statusStr = "No data"
        }
        return "\(dateStr), \(statusStr)"
    }
}
