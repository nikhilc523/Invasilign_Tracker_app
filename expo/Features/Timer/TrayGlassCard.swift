import SwiftUI

/// Premium glass card for individual trays with layered depth
struct TrayGlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: TraysVisualTokens.cardCornerRadius, style: .continuous)
        
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 17)
        .background(.regularMaterial, in: shape)
        .overlay {
            // Top highlight for depth
            shape
                .fill(
                    LinearGradient(
                        colors: TraysVisualTokens.cardHighlight(for: colorScheme),
                        startPoint: .topLeading,
                        endPoint: .bottom
                    )
                )
                .blendMode(.overlay)
        }
        .overlay {
            // Warm outer stroke
            shape.strokeBorder(TraysVisualTokens.cardOuterStroke(for: colorScheme), lineWidth: 1.0)
        }
        .shadow(color: TraysVisualTokens.cardShadow(for: colorScheme), radius: 18, x: 0, y: 9)
    }
}

#Preview("Tray Glass Card") {
    ZStack {
        LinearGradient(
            colors: TraysVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            TrayGlassCard {
                Text("Tray 14")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Premium glass treatment")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            TrayGlassCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tray 15")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Feb 10 → Feb 24")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    Text("CURRENT")
                        .font(.caption2.weight(.bold))
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
                        .shadow(color: .black.opacity(0.16), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding()
    }
}
