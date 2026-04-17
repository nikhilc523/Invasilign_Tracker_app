import SwiftUI

struct CalendarMonthCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .background {
            ZStack {
                // Base material
                shape.fill(.thinMaterial)
                
                // Tint overlay - CRITICAL: .allowsHitTesting(false)
                shape
                    .fill(CalendarVisualTokens.cardTint(for: colorScheme))
                    .allowsHitTesting(false)
                
                // Top gloss - CRITICAL: .allowsHitTesting(false)
                shape
                    .fill(
                        LinearGradient(
                            colors: CalendarVisualTokens.cardTopGloss(for: colorScheme),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 22)
                    .clipShape(shape)
                    .allowsHitTesting(false)
            }
        }
        .overlay {
            shape
                .strokeBorder(CalendarVisualTokens.cardStroke(for: colorScheme), lineWidth: 1.0)
                .allowsHitTesting(false)
        }
        .shadow(
            color: CalendarVisualTokens.cardShadow(for: colorScheme).color,
            radius: CalendarVisualTokens.cardShadow(for: colorScheme).radius,
            y: CalendarVisualTokens.cardShadow(for: colorScheme).y
        )
    }
}
