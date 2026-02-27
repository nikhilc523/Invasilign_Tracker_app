import SwiftUI
import WidgetKit
import ActivityKit

private let backInURL = URL(string: "invisaligntracker://aligner/backin")!

struct AlignerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlignerLiveActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 8) {
                Text("Aligner Out")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.84))

                HStack(spacing: 10) {
                    Text(context.state.startTime, style: .timer)
                        .font(.system(size: 30, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(AppTheme.warningOrange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: 0)
                    
                    // Premium Apple-style "End" button for Lock Screen
                    HStack(spacing: 4) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 10, weight: .black))
                        Text("End")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.85))
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    )
                    .accessibilityLabel("Stop session")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .activityBackgroundTint(Color.black.opacity(0.5))
            .activitySystemActionForegroundColor(AppTheme.textPrimary)
            .widgetURL(backInURL)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.startTime, style: .timer)
                        .font(.system(size: 24, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(AppTheme.warningOrange)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Link(destination: backInURL) {
                        // Premium Apple-style "End" button for Dynamic Island
                        HStack(spacing: 4) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 10, weight: .black))
                            Text("End")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.red)
                        )
                    }
                    .accessibilityLabel("End tracking session")
                    .padding(.trailing, 8)
                }
                // Center and Bottom regions removed for a clean, non-clipping minimal layout
            } compactLeading: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.red)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } compactTrailing: {
                Text(context.state.startTime, style: .timer)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.warningOrange)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } minimal: {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.warningOrange)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .widgetURL(backInURL)
            .keylineTint(AppTheme.warningOrange)
        }
    }
}

@main
struct AlignerLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        AlignerLiveActivityWidget()
    }
}
