import SwiftUI
import Foundation

struct ActivityRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let subtitle: String
    let progress: Double
    let tint: Color
    var lineWidth: CGFloat = 10
    var size: CGFloat = 82

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Track with stronger contrast
                Circle()
                    .stroke(tint.opacity(0.24), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                // Active arc with vivid gradient
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        AngularGradient(
                            colors: [tint.opacity(0.75), tint, tint.opacity(0.95)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // Clean cap indicator (no shadow blur)
                Circle()
                    .fill(.white)
                    .frame(width: lineWidth * 0.62, height: lineWidth * 0.62)
                    .overlay {
                        Circle()
                            .strokeBorder(tint.opacity(0.30), lineWidth: 1.0)
                    }
                    .offset(capOffset)
                    .opacity(animatedProgress > 0.02 ? 1 : 0)

                // Center well
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: size * 0.56, height: size * 0.56)
                    .overlay {
                        Circle()
                            .strokeBorder(.white.opacity(0.28), lineWidth: 0.5)
                    }
            }
            .frame(width: size, height: size)
            .onAppear { animatedProgress = clampedProgress }
            .onChange(of: clampedProgress) { _, newValue in
                if reduceMotion {
                    animatedProgress = newValue
                } else {
                    withAnimation(.spring(response: 0.52, dampingFraction: 0.84)) {
                        animatedProgress = newValue
                    }
                }
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .shadow(color: .black.opacity(0.03), radius: 0.5, x: 0, y: 0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(Int(clampedProgress * 100)) percent, \(subtitle)")
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var capOffset: CGSize {
        let angle = (animatedProgress * 360.0) - 90.0
        let radius = (size - lineWidth) / 2
        let radians = angle * .pi / 180
        return CGSize(
            width: Foundation.cos(radians) * radius,
            height: Foundation.sin(radians) * radius
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        ActivityRing(title: "Wear", subtitle: "21h 10m", progress: 0.88, tint: HomeVisualTokens.ringEmerald)
        ActivityRing(title: "Buffer", subtitle: "35m left", progress: 0.73, tint: HomeVisualTokens.ringAmber)
        ActivityRing(title: "Tray", subtitle: "Day 9", progress: 0.45, tint: HomeVisualTokens.ringGraphite)
    }
    .padding()
    .background(
        ZStack {
            LinearGradient(
                colors: HomeVisualTokens.pageGradient(for: .light),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    )
}
