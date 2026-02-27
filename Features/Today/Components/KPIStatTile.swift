import SwiftUI

struct KPIStatTile: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let value: String
    let valueColor: Color

    init(title: String, value: String, valueColor: Color = AppTheme.textPrimary) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)

        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(valueColor)
                .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(.thinMaterial, in: shape)
        .overlay {
            shape.strokeBorder(HomeVisualTokens.tileStroke(for: colorScheme), lineWidth: 1.0)
        }
        .shadow(color: HomeVisualTokens.tileShadow(for: colorScheme), radius: 8, x: 0, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value)")
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 10) {
            KPIStatTile(title: "Worn today", value: "20h 24m")
            KPIStatTile(title: "Remaining", value: "1h 31m", valueColor: AppTheme.warningOrange)
        }
        HStack(spacing: 10) {
            KPIStatTile(title: "Tray day", value: "9")
            KPIStatTile(title: "Tray left", value: "6d")
        }
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
