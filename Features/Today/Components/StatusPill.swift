import SwiftUI

struct StatusPill: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isAlignerOut: Bool
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 9, height: 9)
                .shadow(color: dotColor.opacity(0.5), radius: 3)

            Text(isAlignerOut ? "OUT" : "IN")
                .font(.caption.weight(.bold))
                .tracking(0.5)
                .foregroundStyle(dotColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(.regularMaterial, in: Capsule())
        .background(HomeVisualTokens.statusPillTint(isOut: isAlignerOut, scheme: colorScheme), in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(HomeVisualTokens.tileStroke(for: colorScheme), lineWidth: 1.0)
        }
        .shadow(color: isAlignerOut ? AppTheme.warningOrange.opacity(pulse ? 0.24 : 0.08) : .clear, radius: pulse ? 10 : 3)
        .scaleEffect(isAlignerOut && !reduceMotion ? (pulse ? 1.04 : 1) : 1)
        .onAppear { updatePulse(isOut: isAlignerOut) }
        .onChange(of: isAlignerOut) { _, newValue in updatePulse(isOut: newValue) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isAlignerOut ? "Aligners out" : "Aligners in")
    }

    private var dotColor: Color {
        isAlignerOut ? AppTheme.warningOrange : AppTheme.successGreen
    }

    private func updatePulse(isOut: Bool) {
        guard isOut, !reduceMotion else {
            pulse = false
            return
        }

        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusPill(isAlignerOut: false)
        StatusPill(isAlignerOut: true)
    }
    .padding()
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
