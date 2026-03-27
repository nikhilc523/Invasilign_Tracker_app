import SwiftUI
import UIKit

enum SettingsVisualTokens {
    static func pageGradient(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [Color(red: 0.11, green: 0.11, blue: 0.13), Color(red: 0.09, green: 0.09, blue: 0.11)]
        }
        return [Color(red: 0.99, green: 0.95, blue: 0.90), Color(red: 0.94, green: 0.85, blue: 0.73)]
    }

    static func cardUnderlay(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.19, green: 0.17, blue: 0.16).opacity(0.74)
            : Color(red: 0.97, green: 0.93, blue: 0.87).opacity(0.88)
    }

    static func outerStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.13) : .white.opacity(0.30)
    }

    static func innerStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white.opacity(0.10) : .white.opacity(0.16)
    }

    static func ambientShadow(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.42) : .black.opacity(0.10)
    }

    static func keyShadow(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.24) : .black.opacity(0.14)
    }

    static let activeModeFill = Color(red: 0.25, green: 0.21, blue: 0.19).opacity(0.90)
    static let activeModeText = Color(red: 1.0, green: 0.95, blue: 0.86)

    static func controlFill(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.24, green: 0.22, blue: 0.21).opacity(0.66)
            : Color(red: 0.98, green: 0.95, blue: 0.90).opacity(0.96)
    }
}

struct SettingsSectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .tracking(0.9)
            .foregroundStyle(AppTheme.textSecondary)
            .padding(.horizontal, 4)
    }
}

struct SettingsGlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)

        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(16)
        .background(SettingsVisualTokens.cardUnderlay(for: colorScheme), in: shape)
        .background(.ultraThinMaterial, in: shape)
        .overlay {
            shape.fill(
                LinearGradient(
                    colors: colorScheme == .dark ? [.white.opacity(0.08), .clear] : [.white.opacity(0.22), .white.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.screen)
            .allowsHitTesting(false)
        }
        .overlay {
            shape.strokeBorder(SettingsVisualTokens.outerStroke(for: colorScheme), lineWidth: 1)
                .allowsHitTesting(false)
        }
        .overlay {
            shape.inset(by: 1)
                .strokeBorder(SettingsVisualTokens.innerStroke(for: colorScheme), lineWidth: 0.7)
                .allowsHitTesting(false)
        }
        .shadow(color: SettingsVisualTokens.ambientShadow(for: colorScheme), radius: 16, x: 0, y: 10)
        .shadow(color: SettingsVisualTokens.keyShadow(for: colorScheme), radius: 6, x: 0, y: 2)
    }
}

struct SettingsStepperRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let subtitle: String?
    let valueText: String
    let value: Int
    let range: ClosedRange<Int>
    let step: Int
    let onChange: (Int) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.95))
                }
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                stepButton(systemName: "minus", isEnabled: value - step >= range.lowerBound) {
                    let next = max(range.lowerBound, value - step)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onChange(next)
                }

                Text(valueText)
                    .font(.body.monospacedDigit().weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(minWidth: 52)
                    .multilineTextAlignment(.center)

                stepButton(systemName: "plus", isEnabled: value + step <= range.upperBound) {
                    let next = min(range.upperBound, value + step)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onChange(next)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title), \(valueText)")
        }
    }

    private func stepButton(systemName: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.subheadline.weight(.semibold))
                .frame(width: 36, height: 36)
                .foregroundStyle(isEnabled ? AppTheme.textPrimary : AppTheme.textTertiary)
                .background(SettingsVisualTokens.controlFill(for: colorScheme), in: Capsule())
                .background(.thinMaterial, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(Color.white.opacity(0.20), lineWidth: 0.8)
                }
        }
        .disabled(!isEnabled)
        .buttonStyle(SettingsPressStyle(reduceMotion: reduceMotion))
        .accessibilityLabel(systemName == "plus" ? "Increase" : "Decrease")
    }
}

struct SettingsToggleRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let subtitle: String?
    let isOn: Bool
    let onChange: (Bool) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.95))
                }
            }

            Spacer(minLength: 8)

            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newValue in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onChange(newValue)
                }
            ))
            .labelsHidden()
            .tint(AppTheme.successGreen)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

struct SettingsModeOption: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let mode: ComplianceMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(titleColor)
                    Text(mode.subtitle)
                        .font(.caption)
                        .foregroundStyle(subtitleColor)
                }

                Spacer(minLength: 10)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(iconColor)
                    .padding(.top, 1)
            }
            .padding(12)
            .background(.thinMaterial, in: shape)
            .background(isSelected ? SettingsVisualTokens.activeModeFill : SettingsVisualTokens.controlFill(for: colorScheme), in: shape)
            .overlay {
                shape.strokeBorder(strokeColor, lineWidth: 0.8)
            }
        }
        .buttonStyle(SettingsPressStyle(reduceMotion: reduceMotion))
        .accessibilityLabel(mode.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to choose compliance mode")
    }

    private var titleColor: Color {
        isSelected ? SettingsVisualTokens.activeModeText : AppTheme.textPrimary
    }

    private var subtitleColor: Color {
        isSelected ? SettingsVisualTokens.activeModeText.opacity(0.84) : AppTheme.textSecondary
    }

    private var iconColor: Color {
        isSelected ? SettingsVisualTokens.activeModeText : AppTheme.textTertiary
    }

    private var strokeColor: Color {
        isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.12)
    }
}

private struct SettingsPressStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.88), value: configuration.isPressed)
    }
}

#Preview("Section Card") {
    VStack(alignment: .leading, spacing: 10) {
        SettingsSectionHeader(title: "Wear Target")
        SettingsGlassCard {
            SettingsStepperRow(
                title: "Target Hours / Day",
                subtitle: "Recommended: 22 hours",
                valueText: "22h",
                value: 22,
                range: 18...24,
                step: 1,
                onChange: { _ in }
            )
            SettingsStepperRow(
                title: "Grace Minutes",
                subtitle: "Allowed under target before failing",
                valueText: "5m",
                value: 5,
                range: 0...30,
                step: 5,
                onChange: { _ in }
            )
        }
    }
    .padding()
    .background(LinearGradient(colors: SettingsVisualTokens.pageGradient(for: .light), startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Dark Mode") {
    VStack(alignment: .leading, spacing: 12) {
        SettingsSectionHeader(title: "Compliance Mode")
        SettingsGlassCard {
            SettingsModeOption(mode: .dailyPassFail, isSelected: true, onTap: {})
            SettingsModeOption(mode: .totalHours, isSelected: false, onTap: {})
        }
    }
    .padding()
    .background(LinearGradient(colors: SettingsVisualTokens.pageGradient(for: .dark), startPoint: .topLeading, endPoint: .bottomTrailing))
    .preferredColorScheme(.dark)
}
