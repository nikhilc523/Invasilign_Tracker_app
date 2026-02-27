import SwiftUI

struct TrayMetricRow: View {
    let metrics: [(value: String, label: String)]
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { index, metric in
                metricColumn(value: metric.value, label: metric.label)
                
                if index < metrics.count - 1 {
                    Spacer()
                }
            }
        }
    }
    
    private func metricColumn(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.80)
            
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#Preview("Tray Metric Row") {
    VStack(spacing: 20) {
        TrayMetricRow(metrics: [
            ("95%", "compliance"),
            ("13/14", "days passed"),
            ("21h 10m", "avg wear")
        ])
        
        TrayMetricRow(metrics: [
            ("82%", "compliance"),
            ("9/15", "days passed"),
            ("18h 6m", "avg wear")
        ])
    }
    .padding()
    .background(AppTheme.canvas)
}
