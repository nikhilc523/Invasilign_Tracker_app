import SwiftUI
import UIKit

private struct PremiumButtonPress: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.26, dampingFraction: 0.88), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
    }
}

struct TimerPrimaryButton: View {
    let isAlignerOut: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isAlignerOut ? "Aligners Back In" : "Remove Aligners")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(isAlignerOut ? AppTheme.successGreen : AppTheme.warningOrange)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Capsule()
                                .fill((isAlignerOut ? AppTheme.successGreen : AppTheme.warningOrange).opacity(0.10))
                        }
                        .overlay {
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.58),
                                            Color.white.opacity(0.18),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                }
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 5)
        }
        .buttonStyle(PremiumButtonPress())
        .contentShape(Rectangle())
        .accessibilityLabel(isAlignerOut ? "Aligners back in" : "Remove aligners")
        .accessibilityHint("Double tap to toggle aligner state")
    }
}

#Preview("Remove - Light") {
    VStack {
        Spacer()
        TimerPrimaryButton(isAlignerOut: false, action: {})
            .padding(.horizontal, 20)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}

#Preview("Back In - Light") {
    VStack {
        Spacer()
        TimerPrimaryButton(isAlignerOut: true, action: {})
            .padding(.horizontal, 20)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}

#Preview("Dark Mode") {
    VStack {
        Spacer()
        TimerPrimaryButton(isAlignerOut: false, action: {})
            .padding(.horizontal, 20)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .dark),
            startPoint: .top,
            endPoint: .bottom
        )
    )
    .preferredColorScheme(.dark)
}
