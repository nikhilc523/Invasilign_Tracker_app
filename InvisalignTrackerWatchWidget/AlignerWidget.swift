import WidgetKit
import SwiftUI

private let watchOpenURL = URL(string: "invisaligntracker://open")!
private let watchStopURL = URL(string: "invisaligntracker://aligner/backin")!

// Colors matching AppTheme
private let themeGreen = Color(red: 31/255, green: 209/255, blue: 115/255)
private let themeOrange = Color(red: 242/255, green: 143/255, blue: 33/255)
private let themeRed = Color(red: 220/255, green: 82/255, blue: 82/255)

// MARK: - Widget Entry
struct AlignerWidgetEntry: TimelineEntry {
    let date: Date
    let isAlignerOut: Bool
    let wornMinutes: Int
    let outTodayMinutes: Int
    let targetMinutes: Int
    let deficitMinutes: Int
    let sessionStart: Date?
    let currentTrayNumber: Int?
}

// MARK: - Timeline Provider
struct AlignerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlignerWidgetEntry {
        AlignerWidgetEntry(
            date: Date(),
            isAlignerOut: false,
            wornMinutes: 1200,
            outTodayMinutes: 120,
            targetMinutes: 1320,
            deficitMinutes: 60,
            sessionStart: nil,
            currentTrayNumber: 5
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AlignerWidgetEntry) -> Void) {
        let entry = loadCurrentState()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AlignerWidgetEntry>) -> Void) {
        let entry = loadCurrentState()
        
        // "Live" cadence while aligners are out.
        let cadenceMinutes = entry.isAlignerOut ? 1 : 15
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: cadenceMinutes, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadCurrentState() -> AlignerWidgetEntry {
        let state = WidgetDataStore.loadState()
        return AlignerWidgetEntry(
            date: Date(),
            isAlignerOut: state.isOut,
            wornMinutes: state.worn,
            outTodayMinutes: state.outToday,
            targetMinutes: state.target > 0 ? state.target : 1320,
            deficitMinutes: state.deficit,
            sessionStart: state.sessionStart,
            currentTrayNumber: state.tray
        )
    }
}

// MARK: - 1. Worn Time Widget
struct AlignerWearTimeWidgetView: View {
    let entry: AlignerWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var progress: Double {
        let target = Double(entry.targetMinutes)
        let worn = Double(entry.wornMinutes)
        return min(max(worn / target, 0.0), 1.0)
    }
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: progress) {
                Text("Worn")
            } currentValueLabel: {
                let hours = entry.wornMinutes / 60
                Text("\(hours)h")
                    .font(.system(.body, design: .rounded, weight: .bold))
            }
            .gaugeStyle(.accessoryCircular)
            .tint(themeGreen)
            .widgetURL(watchOpenURL)
            
        case .accessoryRectangular:
            Gauge(value: progress) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(themeGreen)
                    Text("Time Worn")
                        .font(.headline)
                }
            } currentValueLabel: {
                let hours = entry.wornMinutes / 60
                let mins = entry.wornMinutes % 60
                Text("\(hours)h \(mins)m")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("\(entry.targetMinutes / 60)h")
            }
            .gaugeStyle(.accessoryLinear)
            .tint(themeGreen)
            .widgetURL(watchOpenURL)
            
        case .accessoryInline:
            let hours = entry.wornMinutes / 60
            Text("\(Image(systemName: "checkmark.circle.fill")) \(hours)h Worn")
                .widgetURL(watchOpenURL)
            
        case .accessoryCorner:
            let hours = entry.wornMinutes / 60
            Text("\(hours)h Worn")
                .widgetLabel { Text("Time Worn") }
                .widgetURL(watchOpenURL)
            
        default:
            Text("\(entry.wornMinutes / 60)h")
        }
    }
}

struct AlignerWearTimeWidget: Widget {
    let kind: String = "AlignerWearTimeWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlignerWidgetProvider()) { entry in
            AlignerWearTimeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Time Worn")
        .description("How many hours you wore the aligners today.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
    }
}

// MARK: - 2. Out Time Widget
struct AlignerOutTimeWidgetView: View {
    let entry: AlignerWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var progress: Double {
        let maxOut = 24.0 * 60.0 - Double(entry.targetMinutes)
        let outTime = Double(entry.outTodayMinutes)
        return min(max(maxOut > 0 ? outTime / maxOut : 0, 0.0), 1.0)
    }
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: progress) {
                Text("Out")
            } currentValueLabel: {
                let hours = entry.outTodayMinutes / 60
                let mins = entry.outTodayMinutes % 60
                if hours > 0 {
                    Text("\(hours)h")
                        .font(.system(.body, design: .rounded, weight: .bold))
                } else {
                    Text("\(mins)m")
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
            .gaugeStyle(.accessoryCircular)
            .tint(themeOrange)
            .widgetURL(entry.isAlignerOut ? watchStopURL : watchOpenURL)
            
        case .accessoryRectangular:
            Gauge(value: progress) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(themeOrange)
                    Text("Time Out")
                        .font(.headline)
                }
            } currentValueLabel: {
                let hours = entry.outTodayMinutes / 60
                let mins = entry.outTodayMinutes % 60
                Text("\(hours)h \(mins)m")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("\((24 * 60 - entry.targetMinutes) / 60)h")
            }
            .gaugeStyle(.accessoryLinear)
            .tint(themeOrange)
            .widgetURL(entry.isAlignerOut ? watchStopURL : watchOpenURL)
            
        case .accessoryInline:
            let hours = entry.outTodayMinutes / 60
            let mins = entry.outTodayMinutes % 60
            Text("\(Image(systemName: "clock.fill")) \(hours)h \(mins)m Out")
                .widgetURL(entry.isAlignerOut ? watchStopURL : watchOpenURL)
            
        case .accessoryCorner:
            let hours = entry.outTodayMinutes / 60
            Text("\(hours)h Out")
                .widgetLabel { Text("Time Out") }
                .widgetURL(entry.isAlignerOut ? watchStopURL : watchOpenURL)
            
        default:
            Text("\(entry.outTodayMinutes / 60)h")
        }
    }
}

struct AlignerOutTimeWidget: Widget {
    let kind: String = "AlignerOutTimeWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlignerWidgetProvider()) { entry in
            AlignerOutTimeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Time Out")
        .description("How many hours removed today.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
    }
}

// MARK: - 3. Cumulative Deficit Widget
struct AlignerCarriedDeficitWidgetView: View {
    let entry: AlignerWidgetEntry
    @Environment(\.widgetFamily) var family
    
    // Pink color as requested
    private let themePink = Color.pink
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                Circle()
                    .stroke(themePink.opacity(0.3), lineWidth: 5)
                
                VStack(spacing: 0) {
                    Text("Behind")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(themePink)
                    
                    let hours = entry.deficitMinutes / 60
                    Text("\(hours)h")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
            }
            .widgetURL(watchOpenURL)
            
        case .accessoryRectangular:
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(themePink)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tray \(entry.currentTrayNumber ?? 1) Deficit")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    let hours = entry.deficitMinutes / 60
                    let mins = entry.deficitMinutes % 60
                    
                    if entry.deficitMinutes <= 0 {
                        Text("On track")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(themeGreen)
                    } else {
                        Text("Behind by \(hours)h \(mins)m")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(themePink)
                    }
                }
                Spacer()
            }
            .widgetURL(watchOpenURL)
            
        case .accessoryInline:
            let hours = entry.deficitMinutes / 60
            if entry.deficitMinutes <= 0 {
                Text("\(Image(systemName: "checkmark.circle.fill")) On Track")
            } else {
                Text("\(Image(systemName: "exclamationmark.triangle.fill")) -\(hours)h Behind")
            }
            
        case .accessoryCorner:
            let hours = entry.deficitMinutes / 60
            Text("-\(hours)h")
                .widgetLabel { Text("Tray Deficit") }
                .foregroundStyle(themePink)
                .widgetURL(watchOpenURL)
            
        default:
            Text("\(entry.deficitMinutes)")
        }
    }
}

struct AlignerCarriedDeficitWidget: Widget {
    let kind: String = "AlignerCarriedDeficitWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlignerWidgetProvider()) { entry in
            AlignerCarriedDeficitWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Cumulative Deficit")
        .description("How many hours behind for the current tray.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
    }
}

// MARK: - Widget Bundle
@main
struct AlignerWidgetBundle: WidgetBundle {
    var body: some Widget {
        AlignerWearTimeWidget()
        AlignerOutTimeWidget()
        AlignerCarriedDeficitWidget()
    }
}
