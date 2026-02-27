import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var viewModel: SettingsViewModel
    @State private var showResetConfirmation = false

    init(store: TrackingStore) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(store: store))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Settings")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .tracking(-0.5)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.bottom, 2)

                SettingsSectionHeader(title: "Wear Target")
                SettingsGlassCard {
                    SettingsStepperRow(
                        title: "Target Hours / Day",
                        subtitle: "Recommended: 22 hours",
                        valueText: "\(viewModel.settings.targetHoursPerDay)h",
                        value: viewModel.settings.targetHoursPerDay,
                        range: 18...24,
                        step: 1,
                        onChange: viewModel.updateTargetHours
                    )

                    SettingsStepperRow(
                        title: "Grace Minutes",
                        subtitle: "Allowed under target before failing",
                        valueText: "\(viewModel.settings.graceMinutes)m",
                        value: viewModel.settings.graceMinutes,
                        range: 0...30,
                        step: 5,
                        onChange: viewModel.updateGraceMinutes
                    )
                }

                SettingsSectionHeader(title: "Tray Settings")
                SettingsGlassCard {
                    SettingsStepperRow(
                        title: "Default Days / Tray",
                        subtitle: "Used when adding new trays",
                        valueText: "\(viewModel.settings.plannedDaysPerTray)d",
                        value: viewModel.settings.plannedDaysPerTray,
                        range: 7...30,
                        step: 1,
                        onChange: viewModel.updatePlannedDays
                    )
                }

                SettingsSectionHeader(title: "Reminders")
                SettingsGlassCard {
                    SettingsToggleRow(
                        title: "Enable Reminders",
                        subtitle: "Get notified to put aligners back",
                        isOn: viewModel.settings.remindersEnabled,
                        onChange: viewModel.updateRemindersEnabled
                    )
                    
                    if viewModel.settings.remindersEnabled {
                        SettingsStepperRow(
                            title: "First Reminder",
                            subtitle: "After removing aligners",
                            valueText: "\(viewModel.settings.firstReminderMinutes)m",
                            value: viewModel.settings.firstReminderMinutes,
                            range: 1...60,
                            step: 1,
                            onChange: viewModel.updateFirstReminderMinutes
                        )
                        
                        SettingsStepperRow(
                            title: "Follow-up Interval",
                            subtitle: "Repeat reminder every",
                            valueText: "\(viewModel.settings.followUpReminderMinutes)m",
                            value: viewModel.settings.followUpReminderMinutes,
                            range: 1...30,
                            step: 1,
                            onChange: viewModel.updateFollowUpReminderMinutes
                        )
                    }
                }

                SettingsSectionHeader(title: "Compliance Mode")
                SettingsGlassCard {
                    ForEach(ComplianceMode.allCases, id: \.rawValue) { mode in
                        SettingsModeOption(
                            mode: mode,
                            isSelected: viewModel.settings.complianceMode == mode,
                            onTap: { viewModel.updateComplianceMode(mode) }
                        )
                    }
                }

                SettingsSectionHeader(title: "Current Tray")
                SettingsGlassCard {
                    if let tray = viewModel.currentTray {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tray \(tray.number)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Started: \(tray.startDate.formatted(date: .numeric, time: .omitted)) · \(tray.plannedDays)d planned")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                            Text("Switch trays in the Trays tab")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Current tray \(tray.number), started \(tray.startDate.formatted(date: .numeric, time: .omitted)), \(tray.plannedDays) days planned")
                    } else {
                        Text("No trays added yet")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                SettingsSectionHeader(title: "iCloud Sync")
                SettingsGlassCard {
                    CloudSyncStatusRow()
                }
                
                SettingsSectionHeader(title: "About")
                SettingsGlassCard {
                    Text("Invisalign Tracker")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Track removal sessions to ensure you meet your daily wear target.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                SettingsGlassCard {
                    Button("Force Sync to Watch") {
                        WatchConnectivityManager.shared.syncToWatch()
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 2)
                    
                    Divider().opacity(0.5)

                    Button("Reset All Data", role: .destructive) {
                        showResetConfirmation = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 2)
                    .accessibilityHint("Deletes sessions and trays")
                }
                
                #if DEBUG
                SettingsSectionHeader(title: "Developer Options")
                SettingsGlassCard {
                    Button {
                        // Reset onboarding AND delete all data
                        Task {
                            await viewModel.resetData()
                            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                            // Small delay to let data deletion complete
                            try? await Task.sleep(for: .milliseconds(500))
                            exit(0) // Restart app to see onboarding
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reset Onboarding")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.blue)
                            Text("Deletes all data and shows onboarding again")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                #endif
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 36)
        }
        .background(pageBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 28)
        }
        .alert("Reset All Data", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { viewModel.resetData() }
        } message: {
            Text("This will delete all sessions and trays. This cannot be undone.")
        }
    }

    private var pageBackground: some View {
        ZStack {
            LinearGradient(
                colors: SettingsVisualTokens.pageGradient(for: colorScheme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.06 : 0.16),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 14,
                endRadius: 380
            )
        }
    }
}

#Preview("Default") {
    VStack {
        Text("SettingsView uses live store in app runtime")
            .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(LinearGradient(colors: SettingsVisualTokens.pageGradient(for: .light), startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Large Dynamic Type") {
    VStack(alignment: .leading, spacing: 10) {
        SettingsSectionHeader(title: "Wear Target")
        SettingsGlassCard {
            SettingsStepperRow(
                title: "Target Hours / Day",
                subtitle: "Recommended: 22 hours",
                valueText: "22h",
                value: 22,
                range: 18...24,
                step: 1,
                onChange: { _ in }
            )
            SettingsStepperRow(
                title: "Grace Minutes",
                subtitle: "Allowed under target before failing",
                valueText: "5m",
                value: 5,
                range: 0...30,
                step: 5,
                onChange: { _ in }
            )
        }
    }
    .padding()
    .dynamicTypeSize(.accessibility2)
    .background(LinearGradient(colors: SettingsVisualTokens.pageGradient(for: .light), startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Dark Mode") {
    VStack(alignment: .leading, spacing: 10) {
        SettingsSectionHeader(title: "Compliance Mode")
        SettingsGlassCard {
            SettingsModeOption(mode: .dailyPassFail, isSelected: true, onTap: {})
            SettingsModeOption(mode: .totalHours, isSelected: false, onTap: {})
        }
    }
    .padding()
    .background(LinearGradient(colors: SettingsVisualTokens.pageGradient(for: .dark), startPoint: .topLeading, endPoint: .bottomTrailing))
    .preferredColorScheme(.dark)
}
