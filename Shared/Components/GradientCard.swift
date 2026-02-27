import SwiftUI

struct GradientCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppTheme.cardTop, AppTheme.cardMid, AppTheme.cardBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        )
    }
}
