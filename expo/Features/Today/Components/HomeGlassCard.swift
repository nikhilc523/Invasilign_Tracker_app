import SwiftUI

struct HomeGlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 26, style: .continuous)

        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: shape)
        .overlay {
            // Reduced highlight - no more milky haze
            shape
                .fill(
                    LinearGradient(
                        colors: HomeVisualTokens.panelHighlight(for: colorScheme),
                        startPoint: .topLeading,
                        endPoint: .bottom
                    )
                )
                .blendMode(.overlay)
        }
        .overlay {
            // Single clean stroke (warm-tinted)
            shape.strokeBorder(HomeVisualTokens.panelOuterStroke(for: colorScheme), lineWidth: 1.0)
        }
        .shadow(color: HomeVisualTokens.cardShadow(for: colorScheme), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: HomeVisualTokens.pageGradient(for: .light), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        HomeGlassCard {
            Text("HomeGlassCard")
                .font(.headline)
            Text("Layered premium glass panel")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
