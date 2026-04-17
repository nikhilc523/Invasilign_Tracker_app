import SwiftUI

private enum WatchUI {
    static let bgTop = Color(red: 0.98, green: 0.95, blue: 0.90)
    static let bgBottom = Color(red: 0.93, green: 0.87, blue: 0.78)
    static let textPrimary = Color(red: 0.20, green: 0.16, blue: 0.14)
    static let textSecondary = Color(red: 0.39, green: 0.33, blue: 0.28)
    static let cardFill = Color.white.opacity(0.60)
    static let cardStroke = Color.white.opacity(0.35)
    static let accentOut = Color(red: 0.95, green: 0.62, blue: 0.25)
    static let accentIn = Color(red: 0.31, green: 0.78, blue: 0.56)
}

struct ContentView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var currentTime = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView {
            // Main Timer View
            MainTimerView()
                .environmentObject(connectivity)
            
            // Today's Summary View
            SummaryView()
                .environmentObject(connectivity)
        }
        .tabViewStyle(.verticalPage)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

// MARK: - Main Timer View
struct MainTimerView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @State private var currentTime = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [WatchUI.bgTop, WatchUI.bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if let state = connectivity.currentState {
                VStack(spacing: 10) {
                    HStack {
                        Text(state.isAlignerOut ? "OUT" : "IN")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill((state.isAlignerOut ? WatchUI.accentOut : WatchUI.accentIn).opacity(0.18))
                            )
                            .foregroundStyle(state.isAlignerOut ? WatchUI.accentOut : WatchUI.accentIn)
                        Spacer()
                    }
                    .padding(.horizontal, 4)

                    // Activity Ring
                    ActivityRing(
                        progress: progress(for: state),
                        lineWidth: 10,
                        isAlignerOut: state.isAlignerOut
                    )
                    .frame(width: 124, height: 124)
                    .overlay {
                        VStack(spacing: 4) {
                            if state.isAlignerOut, let sessionStart = state.sessionStart {
                                // Show live timer when out
                                Text(formatElapsedTime(from: sessionStart, to: currentTime))
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(WatchUI.textPrimary)
                                    .monospacedDigit()
                                
                                Text("out")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(WatchUI.textSecondary)
                            } else {
                                // Show worn time with minute precision (avoid "0" for <1 hour)
                                let hours = state.wornTodayMinutes / 60
                                let minutes = state.wornTodayMinutes % 60

                                if hours == 0 {
                                    Text("\(minutes)")
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .foregroundStyle(WatchUI.textPrimary)

                                    Text("mins worn")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(WatchUI.textSecondary)
                                } else {
                                    Text("\(hours)h \(minutes)m")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundStyle(WatchUI.textPrimary)
                                        .minimumScaleFactor(0.75)
                                        .lineLimit(1)

                                    Text("worn today")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(WatchUI.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // Toggle Button
                    Button {
                        toggleAligner(state: state)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: state.isAlignerOut ? "checkmark.circle.fill" : "minus.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                            
                            Text(state.isAlignerOut ? "Put Back In" : "Remove")
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            Capsule()
                                .fill(state.isAlignerOut ? WatchUI.accentIn : WatchUI.accentOut)
                                .overlay(
                                    Capsule()
                                        .fill(.white.opacity(0.22))
                                        .padding(1.5)
                                        .blur(radius: 5)
                                        .mask(
                                            LinearGradient(
                                                colors: [.white, .clear],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                        )
                        .foregroundStyle(WatchUI.textPrimary)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                    
                    // Tray Number (if available)
                    if let trayNumber = state.currentTrayNumber {
                        Text("Tray \(trayNumber)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WatchUI.textSecondary)
                            .padding(.top, 1)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(WatchUI.cardFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(WatchUI.cardStroke, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            } else {
                // Loading / Not connected state
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(WatchUI.textPrimary)
                    
                    Text("Connecting...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(WatchUI.textSecondary)
                    
                    Button("Retry") {
                        connectivity.requestSync()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WatchUI.accentOut)
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .onAppear {
            connectivity.requestSync()
        }
    }
    
    private func progress(for state: WatchStatePayload) -> Double {
        let target = Double(state.targetMinutes)
        let worn = Double(state.wornTodayMinutes)
        return min(worn / target, 1.0)
    }
    
    private func toggleAligner(state: WatchStatePayload) {
        if state.isAlignerOut {
            connectivity.stopSession()
        } else {
            connectivity.startSession()
        }
    }
    
    private func formatElapsedTime(from start: Date, to current: Date) -> String {
        let elapsed = Int(current.timeIntervalSince(start))
        let minutes = (elapsed / 60) % 60
        let seconds = elapsed % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Activity Ring
struct ActivityRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let isAlignerOut: Bool
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    WatchUI.textSecondary.opacity(0.22),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }
    
    private var ringColor: Color {
        if isAlignerOut {
            return WatchUI.accentOut
        } else if progress >= 1.0 {
            return WatchUI.accentIn
        } else if progress >= 0.8 {
            return Color(red: 0.84, green: 0.73, blue: 0.50)
        } else {
            return WatchUI.accentIn
        }
    }
}

// MARK: - Summary View
struct SummaryView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [WatchUI.bgTop, WatchUI.bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if let state = connectivity.currentState {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Summary")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(WatchUI.textPrimary)
                            .padding(.horizontal)
                        
                        // Stats Cards
                        StatsCard(
                            title: "Worn Time",
                            value: formatHours(state.wornTodayMinutes),
                            subtitle: "of \(state.targetMinutes / 60)h goal",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatsCard(
                            title: "Removed Time",
                            value: formatHours(totalRemovedMinutes(state)),
                            subtitle: "\(state.todaySessions.count) sessions",
                            icon: "minus.circle.fill",
                            color: .orange
                        )
                        
                        StatsCard(
                            title: "Remaining",
                            value: formatHours(remainingMinutes(state)),
                            subtitle: "to hit goal",
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        // Sessions List
                        if !state.todaySessions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sessions")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(WatchUI.textSecondary)
                                    .padding(.horizontal)
                                
                                ForEach(state.todaySessions.indices, id: \.self) { index in
                                    SessionRow(session: state.todaySessions[index])
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(WatchUI.textPrimary)
                    Text("Loading...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(WatchUI.textSecondary)
                }
            }
        }
    }
    
    private func totalRemovedMinutes(_ state: WatchStatePayload) -> Int {
        state.todaySessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    private func remainingMinutes(_ state: WatchStatePayload) -> Int {
        max(0, state.targetMinutes - state.wornTodayMinutes)
    }
    
    private func formatHours(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(mins)m"
        }
    }
}

// MARK: - Stats Card
struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(WatchUI.textSecondary)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(WatchUI.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WatchUI.textSecondary.opacity(0.9))
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(WatchUI.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(WatchUI.cardStroke, lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Session Row
struct SessionRow: View {
    let session: WatchStatePayload.SessionSummary
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formatTime(session.startTime))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(WatchUI.textPrimary)
                
                if let endTime = session.endTime {
                    Text("to \(formatTime(endTime))")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WatchUI.textSecondary)
                } else {
                    Text("ongoing")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WatchUI.accentOut)
                }
            }
            
            Spacer()
            
            Text("\(session.durationMinutes)m")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(WatchUI.textSecondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchConnectivityManager.shared)
}
