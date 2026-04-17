import SwiftUI

struct RingClusterItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let progress: Double
    let tint: Color
}

struct RingClusterView: View {
    let items: [RingClusterItem]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(items) { item in
                ActivityRing(
                    title: item.title,
                    subtitle: item.subtitle,
                    progress: item.progress,
                    tint: item.tint
                )
            }
        }
    }
}

#Preview {
    RingClusterView(items: [
        .init(title: "Wear", subtitle: "20:45", progress: 0.81, tint: HomeVisualTokens.ringEmerald),
        .init(title: "Buffer", subtitle: "55m left", progress: 0.68, tint: HomeVisualTokens.ringAmber),
        .init(title: "Tray", subtitle: "Day 12", progress: 0.52, tint: HomeVisualTokens.ringGraphite)
    ])
    .padding()
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
