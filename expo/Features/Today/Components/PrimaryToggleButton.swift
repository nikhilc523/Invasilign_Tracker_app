import SwiftUI
import UIKit

private struct PremiumPressFeedback: ButtonStyle {
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

struct GlassButton: View {
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Capsule()
                                .fill(tint.opacity(0.10))
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
        .buttonStyle(PremiumPressFeedback())
    }
}

struct PrimaryToggleButton: View {
    let isAlignerOut: Bool
    let action: () -> Void

    var body: some View {
        GlassButton(
            title: isAlignerOut ? "Aligners Back In" : "Remove Aligners",
            tint: isAlignerOut ? AppTheme.successGreen : AppTheme.warningOrange,
            action: action
        )
        .contentShape(Rectangle())
        .accessibilityLabel(isAlignerOut ? "Aligners back in" : "Remove aligners")
        .accessibilityHint("Double tap to toggle aligner state")
    }
}

#Preview("Option A: Full-width pill in dock") {
    VStack {
        Spacer()
        BottomActionDock {
            PrimaryToggleButton(isAlignerOut: false, action: {})
        }
    }
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
#Preview("Both states") {
    VStack(spacing: 20) {
        Spacer()
        
        BottomActionDock {
            PrimaryToggleButton(isAlignerOut: false, action: {})
        }
        
        BottomActionDock {
            PrimaryToggleButton(isAlignerOut: true, action: {})
        }
    }
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}

#Preview("Dark mode") {
    VStack {
        Spacer()
        BottomActionDock {
            PrimaryToggleButton(isAlignerOut: false, action: {})
        }
    }
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .dark),
            startPoint: .top,
            endPoint: .bottom
        )
    )
    .preferredColorScheme(.dark)
}
