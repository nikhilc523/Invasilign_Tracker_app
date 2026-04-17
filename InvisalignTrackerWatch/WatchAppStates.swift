import SwiftUI
import WatchKit

/// Loading and error states for the watch app
enum WatchAppState {
    case loading
    case loaded(WatchStatePayload)
    case error(String)
    case disconnected
}

/// Enhanced ContentView with proper state management
struct ContentViewWithStates: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var currentTime = Date()
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var appState: WatchAppState {
        print("⌚️ evaluating appState... isConnected: \(connectivity.isConnected), hasState: \(connectivity.currentState != nil)")
        if !connectivity.isConnected {
            return .disconnected
        }
        
        if let state = connectivity.currentState {
            return .loaded(state)
        }
        
        return .loading
    }
    
    var body: some View {
        Group {
            switch appState {
            case .loading:
                LoadingView()
                
            case .loaded(let state):
                TabView {
                    MainTimerView()
                        .environmentObject(connectivity)
                    
                    SummaryView()
                        .environmentObject(connectivity)
                }
                .tabViewStyle(.verticalPage)
                
            case .error(let message):
                ErrorView(message: message) {
                    connectivity.requestSync()
                }
                
            case .disconnected:
                DisconnectedView {
                    connectivity.requestSync()
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .onAppear {
            print("⌚️ ContentViewWithStates onAppear, requesting sync in 0.5s")
            // Request sync on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("⌚️ ContentViewWithStates triggering requestSync()")
                connectivity.requestSync()
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            WatchTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Spinning ring
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        WatchTheme.success,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                Text("Connecting...")
                    .font(WatchTheme.body())
                    .foregroundStyle(WatchTheme.textSecondary)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Disconnected View
struct DisconnectedView: View {
    let onRetry: () -> Void
    
    var body: some View {
        ZStack {
            WatchTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "applewatch.slash")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(WatchTheme.warning)
                
                Text("Not Connected")
                    .font(WatchTheme.sectionHeader(size: 16))
                    .foregroundStyle(WatchTheme.textPrimary)
                
                Text("Open the iPhone app")
                    .font(WatchTheme.caption())
                    .foregroundStyle(WatchTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    onRetry()
                } label: {
                    Text("Retry")
                        .font(WatchTheme.body(size: 14))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            Capsule()
                                .fill(WatchTheme.warning)
                        )
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
            }
            .padding()
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        ZStack {
            WatchTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(.red)
                
                Text("Error")
                    .font(WatchTheme.sectionHeader(size: 16))
                    .foregroundStyle(WatchTheme.textPrimary)
                
                Text(message)
                    .font(WatchTheme.caption())
                    .foregroundStyle(WatchTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    onRetry()
                } label: {
                    Text("Try Again")
                        .font(WatchTheme.body(size: 14))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            Capsule()
                                .fill(.red)
                        )
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
            }
            .padding()
        }
    }
}

// MARK: - Success Feedback View
struct SuccessFeedback: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(WatchTheme.success)
                    
                    Text(message)
                        .font(WatchTheme.body())
                        .foregroundStyle(WatchTheme.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(WatchTheme.background)
                )
                .padding(.horizontal, 20)
            }
            .transition(.opacity)
            .onAppear {
                // Auto-dismiss after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }
}

// MARK: - Haptic Feedback
enum WatchHaptics {
    /// Light tap for minor actions
    static func light() {
        WKInterfaceDevice.current().play(.click)
    }
    
    /// Success feedback
    static func success() {
        WKInterfaceDevice.current().play(.success)
    }
    
    /// Failure feedback
    static func failure() {
        WKInterfaceDevice.current().play(.failure)
    }
    
    /// Start action
    static func start() {
        WKInterfaceDevice.current().play(.start)
    }
    
    /// Stop action
    static func stop() {
        WKInterfaceDevice.current().play(.stop)
    }
}

// MARK: - Enhanced MainTimerView with Haptics
extension MainTimerView {
    func toggleAlignerWithFeedback(state: WatchStatePayload) {
        if state.isAlignerOut {
            // Stopping - aligners going back in
            WatchHaptics.stop()
            connectivity.stopSession()
        } else {
            // Starting - aligners coming out
            WatchHaptics.start()
            connectivity.startSession()
        }
    }
}

// MARK: - Preview
#Preview("Loading") {
    LoadingView()
}

#Preview("Disconnected") {
    DisconnectedView {
        print("Retry tapped")
    }
}

#Preview("Error") {
    ErrorView(message: "Failed to sync data") {
        print("Retry tapped")
    }
}
