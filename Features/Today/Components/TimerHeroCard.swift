import SwiftUI

struct TimerHeroCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let isAlignerOut: Bool
    let currentTime: String
    let sessionsToday: Int
    let totalOutToday: String
    
    var body: some View {
        VStack(spacing: 16) {
            // State indicator pill
            HStack(spacing: 6) {
                Circle()
                    .fill(isAlignerOut ? TimerVisualTokens.timerOut : TimerVisualTokens.timerIn)
                    .frame(width: 6, height: 6)
                    .shadow(
                        color: (isAlignerOut ? TimerVisualTokens.timerOut : TimerVisualTokens.timerIn).opacity(0.5),
                        radius: 4
                    )
                
                Text(isAlignerOut ? "Aligners Out" : "Aligners In")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isAlignerOut ? TimerVisualTokens.timerOut : TimerVisualTokens.timerIn)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(TimerVisualTokens.statePillBackground(isOut: isAlignerOut, scheme: colorScheme))
                    .shadow(
                        color: TimerVisualTokens.statePillGlow(isOut: isAlignerOut).color,
                        radius: TimerVisualTokens.statePillGlow(isOut: isAlignerOut).radius
                    )
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isAlignerOut ? "Status: Aligners out" : "Status: Aligners in")
            
            // Timer digits (hero)
            Text(currentTime)
                .font(.system(size: 68, weight: .ultraLight, design: .default))
                .monospacedDigit()
                .tracking(-1.2)
                .foregroundStyle(isAlignerOut ? TimerVisualTokens.timerOut : TimerVisualTokens.timerIn)
                .shadow(color: .black.opacity(0.03), radius: 1, y: 1)
                .accessibilityLabel(isAlignerOut ? "Current session: \(currentTime)" : "No active session")
            
            // Supporting caption
            Text(isAlignerOut ? "current removal session" : "wearing aligners")
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
                .opacity(0.75)
            
            // Stats divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: TimerVisualTokens.heroDivider(for: colorScheme),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
                .padding(.horizontal, 24)
            
            // Stats row
            HStack(spacing: 20) {
                TimerStatPair(
                    value: "\(sessionsToday)",
                    label: "sessions today"
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(sessionsToday) sessions today")
                
                Spacer()
                
                TimerStatPair(
                    value: totalOutToday,
                    label: "total out today"
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(totalOutToday) total out today")
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background {
            ZStack {
                // Base material - cleaner
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.thinMaterial)
                
                // Warm tint overlay
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(TimerVisualTokens.heroCardTint(for: colorScheme))
            }
        }
        .overlay(alignment: .top) {
            // Top specular highlight - stronger
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: TimerVisualTokens.heroTopGloss(for: colorScheme),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 22)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .overlay {
            // Inner stroke
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(TimerVisualTokens.heroCardStroke(for: colorScheme), lineWidth: 1)
        }
        .shadow(
            color: TimerVisualTokens.heroCardShadow(for: colorScheme).color,
            radius: TimerVisualTokens.heroCardShadow(for: colorScheme).radius,
            y: TimerVisualTokens.heroCardShadow(for: colorScheme).y
        )
    }
}

struct TimerStatPair: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppTheme.textPrimary)
            
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

#Preview("Aligners Out - Light") {
    VStack {
        TimerHeroCard(
            isAlignerOut: true,
            currentTime: "01:23:45",
            sessionsToday: 3,
            totalOutToday: "2h 18m"
        )
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .light),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}

#Preview("Aligners In - Dark") {
    VStack {
        TimerHeroCard(
            isAlignerOut: false,
            currentTime: "00:00",
            sessionsToday: 2,
            totalOutToday: "1h 42m"
        )
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: HomeVisualTokens.pageGradient(for: .dark),
            startPoint: .top,
            endPoint: .bottom
        )
    )
    .preferredColorScheme(.dark)
}
