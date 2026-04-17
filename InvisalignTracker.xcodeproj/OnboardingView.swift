import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: OnboardingViewModel
    @State private var currentPage = 0
    
    init(store: TrackingStore) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(store: store))
    }
    
    var body: some View {
        ZStack {
            backgroundLayer
                .ignoresSafeArea()
            
            if currentPage == 0 {
                welcomePage
                    .transition(.opacity.combined(with: .scale))
            } else {
                setupPage
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
    }
    
    // MARK: - Welcome Page
    
    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                AnimatedWelcomeText()
                    .padding(.horizontal, 32)
                
                Spacer()
                    .frame(height: 60)
                
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        currentPage = 1
                    }
                } label: {
                    Text("Let's Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
            }
            
            Spacer()
                .frame(height: 100)
        }
    }
    
    // MARK: - Setup Page
    
    private var setupPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Let's Personalize Your Experience")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                
                Text("Just a few quick settings to get you started")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                
                // Target Hours
                OnboardingGlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Daily Wear Target", systemImage: "clock.fill")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("How many hours should you wear your aligners per day?")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        Stepper(value: $viewModel.targetHours, in: 18...24, step: 1) {
                            HStack {
                                Text("\(viewModel.targetHours) hours")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(AppTheme.accentBlue)
                                Spacer()
                                Text("Recommended: 22h")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                
                // Days Per Tray
                OnboardingGlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Tray Duration", systemImage: "calendar")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("How many days do you wear each tray?")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        Stepper(value: $viewModel.daysPerTray, in: 7...30, step: 1) {
                            HStack {
                                Text("\(viewModel.daysPerTray) days")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(AppTheme.accentBlue)
                                Spacer()
                                Text("Typical: 14-15 days")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                
                // First Tray Setup
                OnboardingGlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Your First Tray", systemImage: "1.circle.fill")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Which tray are you currently on?")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        Stepper(value: $viewModel.trayNumber, in: 1...99, step: 1) {
                            HStack {
                                Text("Tray \(viewModel.trayNumber)")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(AppTheme.accentBlue)
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("When did you start this tray?")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        DatePicker(
                            "Start Date",
                            selection: $viewModel.trayStartDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                
                // Reminders
                OnboardingGlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Reminders", systemImage: "bell.fill")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Get notified to put your aligners back in")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        Toggle(isOn: $viewModel.remindersEnabled) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Reminders")
                                    .font(.body.weight(.semibold))
                                if viewModel.remindersEnabled {
                                    Text("First reminder after 30 minutes")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textTertiary)
                                }
                            }
                        }
                        .tint(AppTheme.accentBlue)
                        .padding()
                        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                
                // Done Button
                Button {
                    viewModel.completeOnboarding()
                } label: {
                    HStack {
                        Text("Start Tracking")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .shadow(color: Color.green.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.25),
                    Color(red: 0.15, green: 0.1, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Ambient glow
            RadialGradient(
                colors: [
                    Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.15),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 50,
                endRadius: 400
            )
            
            RadialGradient(
                colors: [
                    Color.purple.opacity(colorScheme == .dark ? 0.15 : 0.1),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 50,
                endRadius: 400
            )
        }
    }
}

// MARK: - Animated Welcome Text

struct AnimatedWelcomeText: View {
    @State private var visibleCharacters = 0
    
    let fullText = """
    Hey Niharika! 💝
    
    Struggling to keep track of your Invisalign hours? Don't worry, I'm here for you!
    
    I can do anything for you, so I designed this app where I'm at my best. ✨
    
    Let's make sure your smile journey is perfectly tracked, just like you deserve. 💕
    """
    
    var body: some View {
        Text(displayedText)
            .font(.system(.title2, design: .rounded))
            .fontWeight(.medium)
            .foregroundStyle(
                LinearGradient(
                    colors: [.white, Color.white.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .lineSpacing(8)
            .onAppear {
                animateText()
            }
    }
    
    private var displayedText: String {
        String(fullText.prefix(visibleCharacters))
    }
    
    private func animateText() {
        let totalCharacters = fullText.count
        let animationDuration: Double = 3.0
        let intervalPerCharacter = animationDuration / Double(totalCharacters)
        
        for index in 0...totalCharacters {
            DispatchQueue.main.asyncAfter(deadline: .now() + intervalPerCharacter * Double(index)) {
                withAnimation(.linear(duration: intervalPerCharacter)) {
                    visibleCharacters = index
                }
            }
        }
    }
}

// MARK: - Onboarding Glass Card

struct OnboardingGlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.2), radius: 20, y: 10)
    }
}

// MARK: - View Model

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var targetHours: Int = 22
    @Published var daysPerTray: Int = 15
    @Published var trayNumber: Int = 1
    @Published var trayStartDate: Date = Date()
    @Published var remindersEnabled: Bool = true
    
    private let store: TrackingStore
    
    init(store: TrackingStore) {
        self.store = store
    }
    
    func completeOnboarding() {
        Task {
            // Update settings
            await store.updateSettings { settings in
                settings.targetHoursPerDay = targetHours
                settings.plannedDaysPerTray = daysPerTray
                settings.remindersEnabled = remindersEnabled
            }
            
            // Create first tray
            await store.addTray(
                number: trayNumber,
                startDate: trayStartDate,
                plannedDays: daysPerTray
            )
            
            // Mark onboarding as complete
            await MainActor.run {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @StateObject private var mockStore = TrackingStore(repository: InMemoryTrackingRepository())
        
        var body: some View {
            OnboardingView(store: mockStore)
        }
    }
    
    return PreviewWrapper()
}
