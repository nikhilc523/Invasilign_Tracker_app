import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let centerText: String
    let ringColor: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.progressTrack, lineWidth: 14)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text(centerText)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("wear today")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(width: 170, height: 170)
    }
}
