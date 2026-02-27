import SwiftUI
import UIKit

enum TraysScreenVisualTokens {
    static func pageGradient(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [Color(red: 0.11, green: 0.11, blue: 0.13), Color(red: 0.09, green: 0.09, blue: 0.11)]
        }
        return [Color(red: 0.99, green: 0.95, blue: 0.90), Color(red: 0.95, green: 0.87, blue: 0.77)]
    }

    static let primaryStrokeLight = Color.white.opacity(0.30)
    static let primaryStrokeDark = Color.white.opacity(0.13)
    static let secondaryStrokeLight = Color.white.opacity(0.16)
    static let secondaryStrokeDark = Color.white.opacity(0.10)

    static let progressTrack = Color(red: 0.30, green: 0.22, blue: 0.17).opacity(0.24)
    static let progressFill = LinearGradient(
        colors: [Color(red: 0.95, green: 0.56, blue: 0.13), Color(red: 0.78, green: 0.37, blue: 0.22)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let badgeCurrentFill = Color(red: 0.23, green: 0.20, blue: 0.18).opacity(0.82)
    static let badgeCurrentText = Color(red: 1.0, green: 0.95, blue: 0.86)
    static let badgeCompletedFill = Color(red: 0.26, green: 0.52, blue: 0.35).opacity(0.18)
    static let badgeCompletedText = Color(red: 0.23, green: 0.52, blue: 0.33)

    static func cardUnderlay(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.19, green: 0.17, blue: 0.16).opacity(0.62)
            : Color(red: 0.98, green: 0.95, blue: 0.90).opacity(0.72)
    }

    static func tileUnderlay(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.23, green: 0.21, blue: 0.20).opacity(0.62)
            : Color(red: 0.97, green: 0.94, blue: 0.90).opacity(0.86)
    }

    static func glassShadowAmbient(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.42) : .black.opacity(0.09)
    }

    static func glassShadowKey(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.24) : .black.opacity(0.14)
    }
}

enum TraysScreenStatus {
    case current
    case completed
    case inactive
}

enum TraysScreenActionStyle {
    case secondary
    case destructive
}

struct TraysScreenGlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(16)
        .background(TraysScreenVisualTokens.cardUnderlay(for: colorScheme), in: shape)
        .background(.ultraThinMaterial, in: shape)
        .overlay {
            shape.fill(
                LinearGradient(
                    colors: colorScheme == .dark ? [.white.opacity(0.07), .clear] : [.white.opacity(0.20), .white.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.screen)
            .allowsHitTesting(false)
        }
        .overlay {
            shape.strokeBorder(colorScheme == .dark ? TraysScreenVisualTokens.primaryStrokeDark : TraysScreenVisualTokens.primaryStrokeLight, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .overlay {
            shape.inset(by: 1)
                .strokeBorder(colorScheme == .dark ? TraysScreenVisualTokens.secondaryStrokeDark : TraysScreenVisualTokens.secondaryStrokeLight, lineWidth: 0.7)
                .allowsHitTesting(false)
        }
        .shadow(color: TraysScreenVisualTokens.glassShadowAmbient(for: colorScheme), radius: 18, x: 0, y: 10)
        .shadow(color: TraysScreenVisualTokens.glassShadowKey(for: colorScheme), radius: 7, x: 0, y: 2)
    }
}

struct TraysScreenAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.subheadline.weight(.semibold))
                Text("Add")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.24, green: 0.20, blue: 0.18), Color(red: 0.17, green: 0.14, blue: 0.13)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add tray")
    }
}

struct TraysScreenStatusBadge: View {
    let status: TraysScreenStatus

    var body: some View {
        switch status {
        case .current:
            Text("CURRENT")
                .font(.caption2.weight(.bold))
                .foregroundStyle(TraysScreenVisualTokens.badgeCurrentText)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(TraysScreenVisualTokens.badgeCurrentFill, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(.white.opacity(0.16), lineWidth: 0.8)
                }
                .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)
        case .completed:
            Text("DONE")
                .font(.caption2.weight(.bold))
                .foregroundStyle(TraysScreenVisualTokens.badgeCompletedText)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(TraysScreenVisualTokens.badgeCompletedFill, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(TraysScreenVisualTokens.badgeCompletedText.opacity(0.30), lineWidth: 0.8)
                }
        case .inactive:
            EmptyView()
        }
    }
}

struct TraysScreenProgressBar: View {
    let progress: Double
    let label: String
    var status: TraysScreenStatus = .inactive

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            GeometryReader { proxy in
                let width = proxy.size.width
                let fill = max(0, min(progress, 1)) * width

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(TraysScreenVisualTokens.progressTrack)
                        .frame(height: 8)
                    Capsule()
                        .fill(progressFillStyle)
                        .frame(width: fill, height: 8)
                    Capsule()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: fill, height: 3)
                        .offset(y: -2)
                }
            }
            .frame(height: 8)

            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .monospacedDigit()
                .accessibilityLabel("Progress \(label)")
        }
    }

    private var progressFillStyle: some ShapeStyle {
        switch status {
        case .current:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.56, blue: 0.13), Color(red: 0.78, green: 0.37, blue: 0.22)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .completed:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color(red: 0.25, green: 0.58, blue: 0.37), Color(red: 0.18, green: 0.48, blue: 0.31)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .inactive:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color(red: 0.38, green: 0.31, blue: 0.28), Color(red: 0.31, green: 0.25, blue: 0.22)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

struct TraysScreenMetricRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let metrics: [(String, String)]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { idx, item in
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.0)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(item.1)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.92))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(TraysScreenVisualTokens.tileUnderlay(for: colorScheme), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.16), lineWidth: 0.75)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(item.1), \(item.0)")

                if idx < metrics.count - 1 {
                    Divider().opacity(0)
                }
            }
        }
    }
}

struct TraysScreenActionButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let icon: String
    let style: TraysScreenActionStyle
    let action: () -> Void

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 42)
            .padding(.horizontal, 12)
            .foregroundStyle(style == .destructive ? AppTheme.errorRed : AppTheme.textPrimary)
            .background(background)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(strokeColor, lineWidth: 0.9)
            }
        }
        .buttonStyle(TraysScreenPressStyle(reduceMotion: reduceMotion))
        .accessibilityLabel(title)
    }

    private var background: some ShapeStyle {
        if style == .destructive {
            return AnyShapeStyle(Color(red: 0.94, green: 0.38, blue: 0.33).opacity(colorScheme == .dark ? 0.14 : 0.10))
        }
        return AnyShapeStyle(TraysScreenVisualTokens.tileUnderlay(for: colorScheme))
    }

    private var strokeColor: Color {
        style == .destructive ? AppTheme.errorRed.opacity(0.25) : Color.white.opacity(0.22)
    }
}

private struct TraysScreenPressStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.88), value: configuration.isPressed)
    }
}

struct TraysScreenEmptyState: View {
    let onAdd: () -> Void

    var body: some View {
        TraysScreenGlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("No trays yet")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Add your first tray to start tracking treatment progress.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                TraysScreenAddButton(action: onAdd)
                    .padding(.top, 4)
            }
        }
    }
}

struct TraysScreenListFooter: View {
    @Environment(\.colorScheme) private var colorScheme
    let trayCount: Int
    let totalTrays: Int
    let currentTrayNumber: Int?

    var body: some View {
        HStack {
            Text(currentTrayNumber.map { "Current: Tray \($0)" } ?? "No current tray")
            Spacer()
            Text("\(trayCount) of \(totalTrays) total")
        }
        .font(.footnote)
        .foregroundStyle(AppTheme.textSecondary.opacity(0.95))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(TraysScreenVisualTokens.tileUnderlay(for: colorScheme), in: Capsule())
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule().strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.16), lineWidth: 0.8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(currentTrayNumber.map { "Current tray \($0). \(trayCount) trays total" } ?? "No current tray. \(trayCount) trays total")
    }
}

#Preview("One Tray") {
    ScrollView {
        VStack(spacing: 14) {
            TraysScreenGlassCard {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tray 12").font(.title3.weight(.bold))
                        Text("Feb 10 → Feb 24").font(.subheadline).foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    TraysScreenStatusBadge(status: .current)
                }
                TraysScreenProgressBar(progress: 0.66, label: "Day 10 of 15 · 5d remaining")
                TraysScreenMetricRow(metrics: [("88%", "compliance"), ("8/10", "days passed"), ("20h 38m", "avg wear")])
                TraysScreenActionButton(title: "Delete Tray", icon: "trash", style: .destructive, action: {})
            }
            TraysScreenListFooter(trayCount: 1, totalTrays: 14, currentTrayNumber: 12)
        }
        .padding()
    }
    .background(LinearGradient(colors: TraysScreenVisualTokens.pageGradient(for: .light), startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Two Trays") {
    ScrollView {
        VStack(spacing: 14) {
            TraysScreenGlassCard {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tray 11").font(.title3.weight(.bold))
                        Text("Jan 25 → Feb 08").font(.subheadline).foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    TraysScreenStatusBadge(status: .completed)
                }
                TraysScreenProgressBar(progress: 1.0, label: "Day 15 of 15")
                TraysScreenMetricRow(metrics: [("93%", "compliance"), ("14/15", "days passed"), ("21h 04m", "avg wear")])
                HStack(spacing: 10) {
                    TraysScreenActionButton(title: "Set Current", icon: "checkmark.circle", style: .secondary, action: {})
                    TraysScreenActionButton(title: "Delete", icon: "trash", style: .destructive, action: {})
                }
            }

            TraysScreenGlassCard {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tray 12").font(.title3.weight(.bold))
                        Text("Feb 10 → Feb 24").font(.subheadline).foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    TraysScreenStatusBadge(status: .current)
                }
                TraysScreenProgressBar(progress: 0.66, label: "Day 10 of 15 · 5d remaining")
                TraysScreenMetricRow(metrics: [("88%", "compliance"), ("8/10", "days passed"), ("20h 38m", "avg wear")])
                TraysScreenActionButton(title: "Delete Tray", icon: "trash", style: .destructive, action: {})
            }
            TraysScreenListFooter(trayCount: 2, totalTrays: 14, currentTrayNumber: 12)
        }
        .padding()
    }
    .background(LinearGradient(colors: TraysScreenVisualTokens.pageGradient(for: .light), startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Long List") {
    ScrollView {
        VStack(spacing: 14) {
            ForEach(1...6, id: \.self) { idx in
                TraysScreenGlassCard {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Tray \(idx)").font(.title3.weight(.bold))
                            Text("Jan \(idx) → Jan \(idx + 14)").font(.subheadline).foregroundStyle(AppTheme.textSecondary)
                        }
                        Spacer()
                        TraysScreenStatusBadge(status: idx == 6 ? .current : .completed)
                    }
                    TraysScreenProgressBar(progress: idx == 6 ? 0.48 : 1.0, label: idx == 6 ? "Day 7 of 15 · 8d remaining" : "Day 15 of 15")
                    TraysScreenMetricRow(metrics: [("\(80 + idx)%", "compliance"), ("\(idx + 6)/\(idx + 7)", "days passed"), ("20h \(10 + idx)m", "avg wear")])
                    if idx == 6 {
                        TraysScreenActionButton(title: "Delete Tray", icon: "trash", style: .destructive, action: {})
                    } else {
                        HStack(spacing: 10) {
                            TraysScreenActionButton(title: "Set Current", icon: "checkmark.circle", style: .secondary, action: {})
                            TraysScreenActionButton(title: "Delete", icon: "trash", style: .destructive, action: {})
                        }
                    }
                }
            }
            TraysScreenListFooter(trayCount: 6, totalTrays: 14, currentTrayNumber: 6)
        }
        .padding()
    }
    .background(LinearGradient(colors: TraysScreenVisualTokens.pageGradient(for: .light), startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Dark Mode") {
    ScrollView {
        VStack(spacing: 14) {
            TraysScreenGlassCard {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tray 12").font(.title3.weight(.bold))
                        Text("Feb 10 → Feb 24").font(.subheadline).foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    TraysScreenStatusBadge(status: .current)
                }
                TraysScreenProgressBar(progress: 0.66, label: "Day 10 of 15 · 5d remaining")
                TraysScreenMetricRow(metrics: [("88%", "compliance"), ("8/10", "days passed"), ("20h 38m", "avg wear")])
                TraysScreenActionButton(title: "Delete Tray", icon: "trash", style: .destructive, action: {})
            }
            TraysScreenListFooter(trayCount: 1, totalTrays: 14, currentTrayNumber: 12)
        }
        .padding()
    }
    .background(LinearGradient(colors: TraysScreenVisualTokens.pageGradient(for: .dark), startPoint: .topLeading, endPoint: .bottomTrailing))
    .preferredColorScheme(.dark)
}
