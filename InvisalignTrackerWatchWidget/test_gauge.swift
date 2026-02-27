import SwiftUI

struct TestGauge: View {
    var body: some View {
        Gauge(value: 0.5) {
            Text("Tray 1")
        } currentValueLabel: {
            Text("12h 30m")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("22")
        }
        .gaugeStyle(.accessoryLinear)
        .tint(.green)
    }
}
