import SwiftUI

enum TrayActionButtonStyle {
    case secondary
    case destructive
}

struct TrayActionButton: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let icon: String?
    let style: TrayActionButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, icon: String? = nil, style: TrayActionButtonStyle = .secondary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(buttonStroke, lineWidth: 1.0)
            }
            .shadow(color: buttonShadow, radius: 6, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.70), value: isPressed)
        }
        .buttonStyle(TrayActionButtonPressStyle(isPressed: $isPressed))
        .foregroundStyle(textColor)
    }
    
    private var buttonBackground: Color {
        switch style {
        case .secondary:
            return TraysVisualTokens.actionButtonBackground(for: colorScheme)
        case .destructive:
            return TraysVisualTokens.destructiveButtonTint.opacity(0.12)
        }
    }
    
    private var buttonStroke: Color {
        switch style {
        case .secondary:
            return TraysVisualTokens.actionButtonStroke(for: colorScheme)
        case .destructive:
            return TraysVisualTokens.destructiveButtonTint.opacity(0.35)
        }
    }
    
    private var buttonShadow: Color {
        switch style {
        case .secondary:
            return TraysVisualTokens.actionButtonShadow(for: colorScheme)
        case .destructive:
            return TraysVisualTokens.destructiveButtonTint.opacity(0.18)
        }
    }
    
    private var textColor: Color {
        switch style {
        case .secondary:
            return AppTheme.textPrimary
        case .destructive:
            return TraysVisualTokens.destructiveButtonTint
        }
    }
}

/// Custom button style to capture press state
private struct TrayActionButtonPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

#Preview("Tray Action Buttons") {
    VStack(spacing: 16) {
        HStack(spacing: 10) {
            TrayActionButton(title: "Set Current", icon: "checkmark.circle", style: .secondary) {}
            TrayActionButton(title: "Delete", icon: "trash", style: .destructive) {}
        }
        
        TrayActionButton(title: "Set as Current Tray", style: .secondary) {}
        TrayActionButton(title: "Delete Tray", style: .destructive) {}
    }
    .padding()
    .background(
        ZStack {
            LinearGradient(
                colors: TraysVisualTokens.pageGradient(for: .light),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    )
}
