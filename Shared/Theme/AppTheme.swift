import SwiftUI

enum AppTheme {
    static let canvas = Color(red: 250/255, green: 240/255, blue: 232/255)
    static let cardTop = Color(red: 254/255, green: 244/255, blue: 232/255)
    static let cardMid = Color(red: 249/255, green: 232/255, blue: 212/255)
    static let cardBottom = Color(red: 237/255, green: 216/255, blue: 184/255)

    // Enhanced contrast for readability
    static let textPrimary = Color(red: 38/255, green: 26/255, blue: 20/255)
    static let textSecondary = Color(red: 118/255, green: 103/255, blue: 94/255)
    static let textTertiary = Color(red: 168/255, green: 149/255, blue: 136/255)

    // Vibrant accent colors
    static let successGreen = Color(red: 31/255, green: 209/255, blue: 115/255)
    static let warningOrange = Color(red: 242/255, green: 143/255, blue: 33/255)
    static let errorRed = Color(red: 220/255, green: 82/255, blue: 82/255)

    static let hairline = Color(red: 180/255, green: 148/255, blue: 118/255).opacity(0.2)
    static let progressTrack = Color(red: 217/255, green: 133/255, blue: 58/255).opacity(0.14)
}
