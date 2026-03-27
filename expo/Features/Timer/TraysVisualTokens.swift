import SwiftUI

enum TraysVisualTokens {
    // MARK: - Page Background
    static func pageGradient(for scheme: ColorScheme) -> [Color] {
        // Reuse Home gradient for consistency
        HomeVisualTokens.pageGradient(for: scheme)
    }
    
    // MARK: - Tray Card (Premium Glass)
    static let cardCornerRadius: CGFloat = 26
    
    static func cardOuterStroke(for scheme: ColorScheme) -> Color {
        if scheme == .dark {
            return .white.opacity(0.18)
        }
        return Color(red: 1.0, green: 0.98, blue: 0.95).opacity(0.40)
    }
    
    static func cardHighlight(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [.white.opacity(0.12), .clear]
        }
        return [.white.opacity(0.30), .clear]
    }
    
    static func cardShadow(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.50) : .black.opacity(0.11)
    }
    
    // MARK: - Status Badges
    static let currentBadgeGradient = [
        Color(red: 242/255, green: 143/255, blue: 33/255),
        Color(red: 212/255, green: 106/255, blue: 38/255)
    ]
    
    static let doneBadgeBackground = Color(red: 31/255, green: 209/255, blue: 115/255).opacity(0.20)
    static let doneBadgeText = Color(red: 28/255, green: 180/255, blue: 98/255)
    
    // MARK: - Progress Bar
    static let progressTrack = AppTheme.progressTrack
    static let progressFill = AppTheme.textPrimary
    static let progressHeight: CGFloat = 6
    static let progressCornerRadius: CGFloat = 3
    
    // MARK: - Action Buttons
    static func actionButtonBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.08) : .white.opacity(0.32)
    }
    
    static func actionButtonStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.16) : .white.opacity(0.42)
    }
    
    static func actionButtonShadow(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.32) : .black.opacity(0.08)
    }
    
    static let destructiveButtonTint = AppTheme.errorRed
    
    // MARK: - Add Button Pill
    static func addButtonBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.11) : .white.opacity(0.38)
    }
    
    static func addButtonStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.20) : .white.opacity(0.48)
    }
    
    static func addButtonShadow(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.38) : .black.opacity(0.13)
    }
    
    // MARK: - Empty State
    static let emptyIconOpacity: Double = 0.24
    static let emptyCornerRadius: CGFloat = 28
}
