import SwiftUI

enum CalendarVisualTokens {
    // MARK: - Premium Glass Cards
    
    static func cardTint(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return Color(red: 0.18, green: 0.17, blue: 0.16).opacity(0.22)
        }
        return Color(red: 1.0, green: 0.98, blue: 0.95).opacity(0.08)
    }
    
    static func cardStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.18) : .white.opacity(0.40)
    }
    
    static func cardShadow(for scheme: ColorScheme) -> (color: Color, radius: CGFloat, y: CGFloat) {
        if scheme == .dark {
            return (.black.opacity(0.52), 12, 4)
        }
        return (.black.opacity(0.08), 10, 3)
    }
    
    static func cardTopGloss(for scheme: ColorScheme) -> [Color] {
        scheme == .dark
            ? [.white.opacity(0.20), .clear]
            : [.white.opacity(0.38), .clear]
    }
    
    // MARK: - Day Cell States
    
    static func dayCellBackground(isSelected: Bool, isToday: Bool, scheme: ColorScheme) -> Color {
        if isToday && !isSelected {
            return AppTheme.textPrimary
        }
        if isSelected {
            return scheme == .dark
                ? .white.opacity(0.18)
                : Color(red: 0.95, green: 0.88, blue: 0.75).opacity(0.85)
        }
        return .clear
    }
    
    static func dayCellStroke(isSelected: Bool, scheme: ColorScheme) -> Color {
        if isSelected {
            return scheme == .dark ? .white.opacity(0.28) : .white.opacity(0.50)
        }
        return .clear
    }
    
    static func dayCellGlow(isSelected: Bool) -> (color: Color, radius: CGFloat) {
        if isSelected {
            return (Color(red: 0.95, green: 0.88, blue: 0.75).opacity(0.35), 6)
        }
        return (.clear, 0)
    }
    
    // MARK: - Session Timeline
    
    static func timelineRowBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? .white.opacity(0.06)
            : .white.opacity(0.35)
    }
    
    static func timelineRowStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.12) : .white.opacity(0.22)
    }
    
    static func timelineDivider(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.08) : .white.opacity(0.14)
    }
    
    // MARK: - Status Badge
    
    static func statusBadgeColors(for status: DayComplianceStatus) -> (bg: Color, text: Color) {
        switch status {
        case .targetMet:
            return (AppTheme.successGreen.opacity(0.18), AppTheme.successGreen)
        case .partial:
            return (AppTheme.warningOrange.opacity(0.18), AppTheme.warningOrange)
        case .missed:
            return (AppTheme.errorRed.opacity(0.18), AppTheme.errorRed)
        case .future:
            return (AppTheme.textSecondary.opacity(0.12), AppTheme.textSecondary)
        case .inProgress:
            return (AppTheme.textSecondary.opacity(0.12), AppTheme.textPrimary)
        }
    }
}

enum DayComplianceStatus {
    case targetMet
    case partial
    case missed
    case future
    case inProgress
}
