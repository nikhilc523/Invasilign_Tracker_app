import SwiftUI

struct BottomActionDock<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background {
            ZStack {
                // Base material
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                // Warm tint overlay
                Rectangle()
                    .fill(dockTint.opacity(colorScheme == .dark ? 0.38 : 0.22))
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private var dockTint: Color {
        if colorScheme == .dark {
            return Color(red: 0.10, green: 0.10, blue: 0.11)
        }
        return Color(red: 0.98, green: 0.93, blue: 0.88)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomActionDock {
            Button("Test Action") {}
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
    .background(Color.gray.opacity(0.2))
}
