import SwiftUI

enum TrayStatus {
    case current
    case completed
    case inactive
}

struct TrayStatusBadge: View {
    let status: TrayStatus
    
    var body: some View {
        switch status {
        case .current:
            currentBadge
        case .completed:
            completedBadge
        case .inactive:
            EmptyView()
        }
    }
    
    private var currentBadge: some View {
        Text("CURRENT")
            .font(.caption2.weight(.bold))
            .tracking(0.3)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                LinearGradient(
                    colors: TraysVisualTokens.currentBadgeGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 2)
            .accessibilityLabel("Current tray")
    }
    
    private var completedBadge: some View {
        Text("DONE")
            .font(.caption2.weight(.bold))
            .tracking(0.3)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(TraysVisualTokens.doneBadgeBackground, in: Capsule())
            .foregroundStyle(TraysVisualTokens.doneBadgeText)
            .overlay {
                Capsule()
                    .strokeBorder(TraysVisualTokens.doneBadgeText.opacity(0.30), lineWidth: 1.0)
            }
            .accessibilityLabel("Completed tray")
    }
}

#Preview("Tray Status Badges") {
    VStack(spacing: 16) {
        TrayStatusBadge(status: .current)
        TrayStatusBadge(status: .completed)
        TrayStatusBadge(status: .inactive)
    }
    .padding()
    .background(AppTheme.canvas)
}
