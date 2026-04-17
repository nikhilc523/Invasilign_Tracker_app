import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: OnboardingViewModel
    @State private var currentPage = 0
    @State private var animateBackground = false
    
    // Cinematic State Vars
    @State private var showStage1 = false
    @State private var stage1Offset: CGFloat = 14
    @State private var stage1Opacity: Double = 0
    
    @State private var showStage2 = false
    @State private var stage2Offset: CGFloat = 24
    @State private var stage2Opacity: Double = 0
    @State private var stage2Blur: CGFloat = 10
    
    @State private var showStage3 = false
    @State private var stage3Offset: CGFloat = 18
    @State private var stage3Opacity: Double = 0
    @State private var stage3Blur: CGFloat = 8
    @State private var typedText3 = false
    @State private var stage3Pulse = false
    
    @State private var showButton = false
    @State private var brightenBackground = false
    
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
        .environment(\.colorScheme, currentPage == 0 ? .light : colorScheme)
        .onAppear {
            animateBackground = true
            runCinematicFlow()
        }
        .onChange(of: currentPage) { newValue in
            if newValue == 0 {
                runCinematicFlow()
            }
        }
    }
    
    // MARK: - Welcome Page
    
    private var welcomePage: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                if showStage1 {
                    heroGreeting
                        .opacity(stage1Opacity)
                        .offset(y: stage1Offset)
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                if showStage2 || showStage3 || showButton {
                    VStack(spacing: 24) {
                        ZStack {
                            // Stage 2
                            if showStage2 {
                                Text("Struggling to keep track of your Invisalign hours? Don't worry, I'm here for you!")
                                    .font(.system(size: 18, weight: .regular, design: .rounded))
                                    .lineSpacing(8)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .opacity(stage2Opacity)
                                    .offset(y: stage2Offset)
                                    .blur(radius: stage2Blur)
                                    .padding(.horizontal, 10)
                            }
                            
                            // Stage 3
                            if showStage3 {
                                Text("")
                                    .modifier(TypewriterModifier(
                                        text: "I can do anything for you 🥺, so I designed this app where I'm at my best. ☺️\n\nLet's make sure your smile journey is perfectly tracked, just like you deserve. 💕",
                                        speed: 0.027,
                                        isAnimating: $typedText3
                                    ))
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .lineSpacing(8)
                                    .foregroundStyle(Color.primary.opacity(0.86))
                                    .multilineTextAlignment(.center)
                                    .scaleEffect(stage3Pulse ? 1.01 : 1.0)
                                    .opacity(stage3Opacity)
                                    .offset(y: stage3Offset)
                                    .blur(radius: stage3Blur)
                                    .padding(.horizontal, 10)
                            }
                        }
                        
                        // Stage 4 Button
                        if showButton {
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                    currentPage = 1
                                }
                            }) {
                                Text("Let's Get Started")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        AppTheme.warningOrange,
                                                        AppTheme.warningOrange.opacity(0.84)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                                    )
                                    .shadow(color: AppTheme.warningOrange.opacity(0.32), radius: 12, y: 6)
                                    .padding(.horizontal, 20)
                            }
                            .buttonStyle(ScaleButtonStyle(pressedScale: 0.97, pressedOpacity: 0.95))
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            Color.clear.frame(height: 56)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.10), radius: 20, y: 10)
                    .padding(.horizontal, 22)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                Color.clear.frame(height: 34)
            }
        }
    }
    
    private var heroGreeting: some View {
        (
            Text("Hey ")
                .foregroundStyle(Color.primary)
            + Text("cutuuuu")
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.40, green: 0.28, blue: 0.22),
                            AppTheme.warningOrange.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            + Text("! 🐶")
                .foregroundStyle(Color.primary)
        )
        .font(.system(size: 42, weight: .heavy, design: .default))
        .multilineTextAlignment(.center)
    }
    
    // MARK: - Setup Page
    
    private var setupPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Let's Personalize Your Experience")
                    .font(.system(.largeTitle, design: .default).weight(.bold))
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
                                    .foregroundStyle(AppTheme.warningOrange)
                                Spacer()
                                Text("Recommended: 22h")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .padding()
                        .background(AppTheme.textTertiary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
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
                                    .foregroundStyle(AppTheme.warningOrange)
                                Spacer()
                                Text("Typical: 14-15 days")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .padding()
                        .background(AppTheme.textTertiary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
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
                                    .foregroundStyle(AppTheme.warningOrange)
                            }
                        }
                        .padding()
                        .background(AppTheme.textTertiary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        
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
                        .background(AppTheme.textTertiary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
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
                                    Text("Set your preferred reminder intervals")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }
                        }
                        .tint(AppTheme.warningOrange)
                        .padding()
                        .background(AppTheme.textTertiary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        
                        if viewModel.remindersEnabled {
                            Divider()
                                .padding(.vertical, 4)
                            
                            // First Reminder Duration
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Reminder")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                
                                Text("How long after taking them out?")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                
                                Stepper(value: Binding(
                                    get: { viewModel.firstReminderMinutes },
                                    set: { new in
                                        viewModel.firstReminderMinutes = max(10, min(new, viewModel.secondReminderMinutes - 5))
                                    }
                                ), in: 10...120, step: 5) {
                                    HStack {
                                        Text("\(viewModel.firstReminderMinutes)")
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(AppTheme.warningOrange)
                                        Text("minutes")
                                            .font(.subheadline)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                                .padding()
                                .background(AppTheme.textTertiary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Second Reminder Duration
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Second Reminder")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                
                                Text("When should we remind you again?")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                
                                Stepper(value: Binding(
                                    get: { viewModel.secondReminderMinutes },
                                    set: { new in
                                        viewModel.secondReminderMinutes = max(viewModel.firstReminderMinutes + 5, min(new, 240))
                                    }
                                ), in: 15...240, step: 5) {
                                    HStack {
                                        Text("\(viewModel.secondReminderMinutes)")
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(AppTheme.warningOrange)
                                        Text("minutes")
                                            .font(.subheadline)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                                .padding()
                                .background(AppTheme.textTertiary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.remindersEnabled)
                
                // Done Button
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
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
                            colors: [AppTheme.warningOrange, AppTheme.warningOrange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .shadow(color: AppTheme.warningOrange.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            if currentPage == 0 {
                LinearGradient(
                    colors: brightenBackground
                        ? [Color(red: 0.99, green: 0.95, blue: 0.90), Color(red: 0.96, green: 0.89, blue: 0.81)]
                        : [Color(red: 0.98, green: 0.93, blue: 0.87), Color(red: 0.94, green: 0.86, blue: 0.78)],
                    startPoint: animateBackground ? .topLeading : .topTrailing,
                    endPoint: animateBackground ? .bottomTrailing : .bottomLeading
                )
                
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 320, height: 320)
                    .blur(radius: 90)
                    .offset(x: animateBackground ? 130 : -120, y: animateBackground ? -220 : -170)
                
                Circle()
                    .fill(Color(red: 0.97, green: 0.74, blue: 0.56).opacity(0.30))
                    .frame(width: 360, height: 360)
                    .blur(radius: 100)
                    .offset(x: animateBackground ? -150 : 160, y: animateBackground ? 270 : 210)
                
                Circle()
                    .fill(Color(red: 0.94, green: 0.83, blue: 0.70).opacity(0.22))
                    .frame(width: 260, height: 260)
                    .blur(radius: 80)
                    .offset(x: animateBackground ? 120 : -90, y: animateBackground ? 90 : 20)
            } else {
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(red: 0.24, green: 0.20, blue: 0.16), Color(red: 0.30, green: 0.25, blue: 0.20)]
                        : [Color(red: 0.98, green: 0.93, blue: 0.87), Color(red: 0.95, green: 0.87, blue: 0.79)],
                    startPoint: animateBackground ? .topLeading : .topTrailing,
                    endPoint: animateBackground ? .bottomTrailing : .bottomLeading
                )
                
                RadialGradient(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.08 : 0.24),
                        Color.clear
                    ],
                    center: animateBackground ? .topTrailing : .topLeading,
                    startRadius: 10,
                    endRadius: 360
                )
                
                RadialGradient(
                    colors: [
                        Color(red: 0.84, green: 0.52, blue: 0.33).opacity(colorScheme == .dark ? 0.10 : 0.18),
                        Color.clear
                    ],
                    center: animateBackground ? .bottomLeading : .bottomTrailing,
                    startRadius: 10,
                    endRadius: 420
                )
            }
        }
        .animation(.easeInOut(duration: 11).repeatForever(autoreverses: true), value: animateBackground)
    }
    
    private func runCinematicFlow() {
        Task {
            // Reset state
            await MainActor.run {
                showStage1 = false
                showStage2 = false
                showStage3 = false
                showButton = false
                typedText3 = false
                stage3Pulse = false
                brightenBackground = false
                stage3Offset = 18
                stage3Opacity = 0
                stage3Blur = 8
            }
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            await playStage1()
            await playStage2()
            await playStage3()
        }
    }
    
    @MainActor
    private func playStage1() async {
        showStage1 = true
        stage1Offset = 14
        stage1Opacity = 0
        
        withAnimation(.easeOut(duration: 0.4)) {
            stage1Opacity = 1
            stage1Offset = 0
        }

        try? await Task.sleep(nanoseconds: 1_500_000_000) // Hold 1.5s
        
        withAnimation(.easeIn(duration: 0.4)) {
            stage1Opacity = 0
            stage1Offset = -20
        }
        try? await Task.sleep(nanoseconds: 400_000_000)
        showStage1 = false
    }
    
    @MainActor
    private func playStage2() async {
        showStage2 = true
        stage2Offset = 24
        stage2Opacity = 0
        stage2Blur = 10
        
        withAnimation(.easeOut(duration: 0.5)) {
            stage2Opacity = 1
            stage2Offset = 0
            stage2Blur = 0
        }
        
        try? await Task.sleep(nanoseconds: 2_500_000_000) // 2s hold + 0.5s animation
        
        withAnimation(.easeIn(duration: 0.4)) {
            stage2Opacity = 0
            stage2Offset = -25
        }
        try? await Task.sleep(nanoseconds: 400_000_000)
        showStage2 = false
    }
    
    @MainActor
    private func playStage3() async {
        showStage3 = true
        stage3Offset = 18
        stage3Opacity = 0
        stage3Blur = 8
        
        withAnimation(.easeOut(duration: 0.45)) {
            stage3Opacity = 1
            stage3Offset = 0
            stage3Blur = 0
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        typedText3 = true
        
        // 158 chars * 0.027 = 4.26 sec
        try? await Task.sleep(nanoseconds: 4_350_000_000)
        
        // Climax pulse
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            stage3Pulse = true
        }
        withAnimation(.easeInOut(duration: 1.0)) {
            brightenBackground = true
        }
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            stage3Pulse = false
        }
        
        try? await Task.sleep(nanoseconds: 3_000_000_000) // Hold 3 seconds
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showButton = true
        }
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.96
    var pressedOpacity: CGFloat = 0.9
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
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
    @Published var firstReminderMinutes: Int = 30
    @Published var secondReminderMinutes: Int = 60
    
    private let store: TrackingStore
    
    init(store: TrackingStore) {
        self.store = store
    }
    
    func completeOnboarding() {
        Task {
            print("🎯 [Onboarding] Starting onboarding completion flow...")
            
            // STEP 0: CLEAR ALL EXISTING DATA
            print("🗑️ [Onboarding] Clearing any existing data...")
            await store.resetAllData(now: Date())
            print("✅ [Onboarding] All existing data cleared")
            
            // STEP 1: Update app settings with user selections
            print("📝 [Onboarding] Updating app settings...")
            var updatedSettings = await store.settings
            updatedSettings.targetHoursPerDay = targetHours
            updatedSettings.plannedDaysPerTray = daysPerTray
            updatedSettings.remindersEnabled = remindersEnabled
            updatedSettings.firstReminderMinutes = firstReminderMinutes
            updatedSettings.followUpReminderMinutes = secondReminderMinutes
            
            await store.updateSettings(updatedSettings)
            print("✅ [Onboarding] App settings saved: targetHours=\(targetHours)h, daysPerTray=\(daysPerTray)d, reminders=\(remindersEnabled)")
            
            // STEP 2: Save notification times to UserDefaults (backup)
            print("🔔 [Onboarding] Saving notification durations to UserDefaults...")
            UserDefaults.standard.set(firstReminderMinutes, forKey: "firstReminderMinutes")
            UserDefaults.standard.set(secondReminderMinutes, forKey: "secondReminderMinutes")
            
            print("✅ [Onboarding] Notification durations saved:")
            print("   First: \(firstReminderMinutes)m")
            print("   Second: \(secondReminderMinutes)m")
            
            // STEP 3: Create the first tray with exact start time (NOW, not midnight)
            print("🦷 [Onboarding] Creating first tray...")
            let now = Date()
            await store.addTray(
                number: trayNumber,
                plannedDays: daysPerTray,
                startDate: now  // Use current time, not midnight!
            )
            print("✅ [Onboarding] First tray created: Tray #\(trayNumber), started \(now), \(daysPerTray) days planned")
            print("ℹ️ [Onboarding] Tracking will start from THIS MOMENT (\(now.formatted(date: .omitted, time: .shortened))), not midnight")
            
            // STEP 4: Request notification permissions if enabled
            if remindersEnabled {
                print("🔔 [Onboarding] Requesting notification permissions...")
                let center = UNUserNotificationCenter.current()
                
                do {
                    let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                    
                    if granted {
                        print("✅ [Onboarding] Notification permission granted!")
                        print("ℹ️ [Onboarding] Reminders will be scheduled automatically when aligners are removed.")
                        print("ℹ️ [Onboarding] First reminder: \(firstReminderMinutes)m after removal")
                        print("ℹ️ [Onboarding] Second reminder: \(secondReminderMinutes)m after removal")
                    } else {
                        print("⚠️ [Onboarding] Notification permission denied by user")
                    }
                } catch {
                    print("❌ [Onboarding] Error requesting notification permission: \(error)")
                }
            } else {
                print("ℹ️ [Onboarding] Reminders disabled by user, skipping notification setup")
            }
            
            // STEP 5: Mark onboarding as complete
            await MainActor.run {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
                print("🎉 [Onboarding] Onboarding completed successfully!")
                print("🏠 [Onboarding] Transitioning to main dashboard...")
                print("📊 [Onboarding] Dashboard will show wear time FROM NOW, not from midnight")
            }
        }
    }
}

// MARK: - Cinematic Modifiers

struct TypewriterModifier: ViewModifier {
    let text: String
    let speed: Double
    @Binding var isAnimating: Bool
    
    @State private var revealedCount: Int = 0
    
    func body(content: Content) -> some View {
        Text(attributedString)
            .onAppear {
                if isAnimating && revealedCount == 0 {
                    animate()
                }
            }
            .onChange(of: isAnimating) { start in
                if start && revealedCount == 0 {
                    animate()
                }
            }
    }
    
    private var attributedString: AttributedString {
        var attrStr = AttributedString()
        let chars = Array(text)
        for (i, char) in chars.enumerated() {
            var str = AttributedString(String(char))
            if i >= revealedCount {
                str.foregroundColor = .clear
            }
            attrStr.append(str)
        }
        return attrStr
    }
    
    private func animate() {
        Task {
            for i in 0...text.count {
                try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
                await MainActor.run { revealedCount = i }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Text("Preview OnboardingView in live app")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}
