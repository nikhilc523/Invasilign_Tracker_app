import SwiftUI

struct TrayProgressBar: View {
    let progress: Double
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: TraysVisualTokens.progressCornerRadius, style: .continuous)
                        .fill(TraysVisualTokens.progressTrack)
                        .frame(height: TraysVisualTokens.progressHeight)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: TraysVisualTokens.progressCornerRadius, style: .continuous)
                        .fill(TraysVisualTokens.progressFill)
                        .frame(width: max(0, geometry.size.width * progress), height: TraysVisualTokens.progressHeight)
                        .shadow(color: TraysVisualTokens.progressFill.opacity(0.30), radius: 3, x: 0, y: 1)
                }
            }
            .frame(height: TraysVisualTokens.progressHeight)
            
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress: \(label)")
    }
}

#Preview("Tray Progress Bar") {
    VStack(spacing: 20) {
        TrayProgressBar(progress: 0.0, label: "Day 0 of 15")
        TrayProgressBar(progress: 0.4, label: "Day 6 of 15")
        TrayProgressBar(progress: 0.73, label: "Day 11 of 15 · 4d remaining")
        TrayProgressBar(progress: 1.0, label: "Day 15 of 15")
    }
    .padding()
    .background(AppTheme.canvas)
}
