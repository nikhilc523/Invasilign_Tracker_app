import SwiftUI

struct TraysEmptyState: View {
    @Environment(\.colorScheme) private var colorScheme
    let onAddTray: () -> Void
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: TraysVisualTokens.emptyCornerRadius, style: .continuous)
        
        VStack(spacing: 18) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.textPrimary.opacity(TraysVisualTokens.emptyIconOpacity))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "tray.full")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary.opacity(0.50))
            }
            .padding(.top, 8)
            
            // Text
            VStack(spacing: 6) {
                Text("No trays yet")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Add your first tray to start tracking your aligner progress")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // CTA
            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                onAddTray()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                    Text("Add First Tray")
                        .font(.subheadline.weight(.bold))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppTheme.textPrimary, in: Capsule())
                .foregroundStyle(Color(red: 250/255, green: 240/255, blue: 232/255))
                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 36)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: shape)
        .overlay {
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
            shape.strokeBorder(TraysVisualTokens.cardOuterStroke(for: colorScheme), lineWidth: 1.0)
        }
        .shadow(color: TraysVisualTokens.cardShadow(for: colorScheme), radius: 18, x: 0, y: 9)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No trays yet. Add your first tray to start tracking your aligner progress.")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("Trays Empty State") {
    ZStack {
        LinearGradient(
            colors: TraysVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        TraysEmptyState(onAddTray: {})
            .padding()
    }
}
