import SwiftUI

enum TimerVisualTokens {
    // MARK: - Hero Card Material
    
    static func heroCardTint(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return Color(red: 0.18, green: 0.17, blue: 0.16).opacity(0.24)
        }
        return Color(red: 1.0, green: 0.98, blue: 0.95).opacity(0.08)
    }
    
    static func heroCardStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.22) : .white.opacity(0.45)
    }
    
    static func heroCardShadow(for scheme: ColorScheme) -> (color: Color, radius: CGFloat, y: CGFloat) {
        if scheme == .dark {
            return (.black.opacity(0.58), 14, 5)
        }
        return (.black.opacity(0.10), 10, 3)
    }
    
    static func heroTopGloss(for scheme: ColorScheme) -> [Color] {
        scheme == .dark
            ? [.white.opacity(0.24), .clear]
            : [.white.opacity(0.42), .clear]
    }
    
    static func heroDivider(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [.clear, .white.opacity(0.14), .clear]
        }
        return [.clear, .white.opacity(0.22), .clear]
    }
    
    // MARK: - State Indicator Pill
    
    static func statePillBackground(isOut: Bool, scheme: ColorScheme) -> Color {
        if isOut {
            return scheme == .dark
                ? Color.orange.opacity(0.28)
                : Color.orange.opacity(0.18)
        }
        return scheme == .dark
            ? Color.green.opacity(0.24)
            : Color.green.opacity(0.16)
    }
    
    static func statePillGlow(isOut: Bool) -> (color: Color, radius: CGFloat) {
        let color = isOut ? Color.orange : Color.green
        return (color.opacity(0.12), 6)
    }
    
    // MARK: - Timer Colors
    
    static let timerOut = Color(red: 242/255, green: 143/255, blue: 33/255)
    static let timerIn = Color(red: 31/255, green: 209/255, blue: 115/255)
    
    // MARK: - Session History Card
    
    static func historyCardTint(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return Color(red: 0.18, green: 0.17, blue: 0.16).opacity(0.22)
        }
        return Color(red: 1.0, green: 0.98, blue: 0.95).opacity(0.08)
    }
    
    static func historyCardStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.18) : .white.opacity(0.38)
    }
    
    static func historyCardShadow(for scheme: ColorScheme) -> (color: Color, radius: CGFloat, y: CGFloat) {
        if scheme == .dark {
            return (.black.opacity(0.50), 12, 4)
        }
        return (.black.opacity(0.08), 8, 2)
    }
    
    static func sessionRowSeparator(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.10) : .white.opacity(0.16)
    }
    
    // MARK: - Atmospheric Background (optional enhancement)
    
    static func atmosphericGradient(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [.white.opacity(0.06), .clear]
        }
        return [.white.opacity(0.32), .clear]
    }
}
