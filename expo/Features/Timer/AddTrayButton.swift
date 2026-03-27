import SwiftUI

struct AddTrayButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                Text("Add")
                    .font(.subheadline.weight(.bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(TraysVisualTokens.addButtonBackground(for: colorScheme), in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(TraysVisualTokens.addButtonStroke(for: colorScheme), lineWidth: 1.0)
            }
            .shadow(color: TraysVisualTokens.addButtonShadow(for: colorScheme), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.68), value: isPressed)
        }
        .buttonStyle(AddTrayButtonPressStyle(isPressed: $isPressed))
        .foregroundStyle(AppTheme.textPrimary)
        .accessibilityLabel("Add new tray")
    }
}

private struct AddTrayButtonPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

#Preview("Add Tray Button") {
    VStack(spacing: 20) {
        AddTrayButton {}
        
        HStack {
            Text("Trays")
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            AddTrayButton {}
        }
    }
    .padding()
    .background(
        LinearGradient(
            colors: TraysVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
