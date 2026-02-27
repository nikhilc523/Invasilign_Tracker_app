import SwiftUI

enum HomeVisualTokens {
    // MARK: - Page Background
    static func pageGradient(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [Color(red: 0.11, green: 0.11, blue: 0.13), Color(red: 0.08, green: 0.08, blue: 0.09)]
        }
        return [Color(red: 0.99, green: 0.95, blue: 0.90), Color(red: 0.96, green: 0.89, blue: 0.82)]
    }

    // MARK: - Premium Glass Card System (QA Polished)
    static func panelOuterStroke(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return .white.opacity(0.18)
        }
        // Warm-tinted stroke to reduce milky appearance
        return Color(red: 1.0, green: 0.98, blue: 0.95).opacity(0.38)
    }

    static func panelHighlight(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [.white.opacity(0.12), .clear]
        }
        // Reduced from 0.55 to eliminate washed-out haze
        return [.white.opacity(0.28), .clear]
    }

    static func cardShadow(for scheme: ColorScheme) -> Color {
        // Single clean shadow (ambient + contact merged)
        scheme == .dark ? .black.opacity(0.48) : .black.opacity(0.08)
    }

    // MARK: - KPI Tile Tokens (QA Polished)
    static func tileStroke(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return .white.opacity(0.14)
        }
        return Color(red: 1.0, green: 0.98, blue: 0.95).opacity(0.32)
    }

    static func tileShadow(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.36) : .black.opacity(0.06)
    }

    // MARK: - CTA Button (QA Corrected - No Green Glow)
    static let ctaOutGradient = [
        Color(red: 242/255, green: 143/255, blue: 33/255),
        Color(red: 212/255, green: 106/255, blue: 38/255)
    ]
    
    static let ctaInGradient = [
        Color(red: 31/255, green: 209/255, blue: 115/255),
        Color(red: 28/255, green: 180/255, blue: 98/255)
    ]

    // Warm neutral shadow (no colored glow)
    static let ctaShadow = Color(red: 0.45, green: 0.32, blue: 0.22).opacity(0.24)

    // MARK: - Activity Rings (Enhanced)
    static let ringEmerald = Color(red: 0.12, green: 0.82, blue: 0.45)
    static let ringAmber = Color(red: 0.95, green: 0.56, blue: 0.13)
    static let ringGraphite = Color(red: 0.27, green: 0.23, blue: 0.21)
    static let ringCrimson = Color(red: 0.89, green: 0.29, blue: 0.28)

    // MARK: - Status Pill
    static func statusPillTint(isOut: Bool, scheme: ColorScheme) -> Color {
        if isOut {
            return scheme == .dark ? Color.orange.opacity(0.26) : Color(red: 1.0, green: 0.76, blue: 0.52).opacity(0.40)
        }
        return scheme == .dark ? Color.green.opacity(0.24) : Color(red: 0.72, green: 0.94, blue: 0.80).opacity(0.38)
    }

    // MARK: - Week Strip (QA Polished)
    static func weekDayBackground(isToday: Bool, scheme: ColorScheme) -> Color {
        if isToday {
            return scheme == .dark ? .white.opacity(0.14) : .white.opacity(0.45)
        }
        return scheme == .dark ? .white.opacity(0.05) : .white.opacity(0.22)
    }

    static func weekDayStroke(isToday: Bool, scheme: ColorScheme) -> Color {
        if isToday {
            return scheme == .dark ? .white.opacity(0.24) : Color(red: 1.0, green: 0.98, blue: 0.95).opacity(0.40)
        }
        return scheme == .dark ? .white.opacity(0.10) : Color(red: 1.0, green: 0.98, blue: 0.95).opacity(0.18)
    }
    
    // MARK: - Bottom Container (QA Cleanup)
    static func bottomContainer(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return Color(red: 0.10, green: 0.10, blue: 0.11).opacity(0.92)
        }
        return Color(red: 0.98, green: 0.93, blue: 0.88).opacity(0.85)
    }
    
    static func bottomSeparator(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.12) : .white.opacity(0.20)
    }
}
