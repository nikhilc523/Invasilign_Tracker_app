import SwiftUI
import UIKit

struct TraysView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @StateObject private var viewModel: TraysViewModel
    @State private var showAddSheet = false
    @State private var newTrayNumber = ""
    @State private var newTrayDays = "15"
    @State private var newTrayStartDate = Date()
    @State private var trayToDelete: Tray?
    @State private var showDeleteDialog = false
    @State private var expandedTrayID: UUID?

    init(store: TrackingStore) {
        _viewModel = StateObject(wrappedValue: TraysViewModel(store: store))
    }

    var body: some View {
        ZStack {
            // Atmospheric background
            pageBackground
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Header
                    header
                    
                    // MARK: - Content
                    if viewModel.sortedTrays.isEmpty {
                        TraysScreenEmptyState {
                            showAddTraySheet()
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        traysList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .refreshable {
                // Trigger cloud sync check
                await CloudSyncMonitor.shared.checkAccountStatus()
                CloudSyncMonitor.shared.triggerSync()
                
                // Reload data from repository (picks up any cloud changes)
                await viewModel.reload()
            }
        }
        .sheet(isPresented: $showAddSheet) {
            addTraySheet
        }
        .confirmationDialog("Delete Tray", isPresented: $showDeleteDialog, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let tray = trayToDelete {
                    // Haptic feedback
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.warning)
                    
                    viewModel.deleteTray(id: tray.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let tray = trayToDelete {
                Text("Delete Tray \(tray.number)? Your wear sessions will be kept.")
            } else {
                Text("Delete this tray? Your wear sessions will be kept.")
            }
        }
    }
    
    // MARK: - Page Background
    
    private var pageBackground: some View {
        ZStack {
            LinearGradient(
                colors: TraysScreenVisualTokens.pageGradient(for: colorScheme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle radial accent
            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.05 : 0.14),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 14,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Trays")
                    .font(.largeTitle.bold())
                    .tracking(-0.5)
                    .foregroundStyle(AppTheme.textPrimary)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                
                CloudSyncStatusView()
            }
            
            Spacer()
            
            TraysScreenAddButton {
                showAddTraySheet()
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Trays List
    
    private var traysList: some View {
        LazyVStack(spacing: 14) {
            ForEach(Array(viewModel.sortedTrays.enumerated()), id: \.element.id) { index, tray in
                TrayCardView(
                    metrics: viewModel.cardMetrics(for: tray),
                    expandedTrayID: $expandedTrayID,
                    viewModel: viewModel,
                    trayToDelete: $trayToDelete,
                    showDeleteDialog: $showDeleteDialog
                )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                        removal: .scale(scale: 0.96).combined(with: .opacity)
                    ))
                    .animation(
                        reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.82).delay(Double(index) * 0.04),
                        value: viewModel.sortedTrays.count
                    )
            }

            TraysScreenListFooter(
                trayCount: viewModel.sortedTrays.count,
                totalTrays: viewModel.settings.totalTrays,
                currentTrayNumber: viewModel.sortedTrays.first(where: { $0.id == viewModel.settings.currentTrayID })?.number
            )
            .padding(.top, 6)
        }
    }
    
// MARK: - Tray Card View

struct TrayCardView: View {
    let metrics: TrayCardMetrics
    @Binding var expandedTrayID: UUID?
    @ObservedObject var viewModel: TraysViewModel
    @Binding var trayToDelete: Tray?
    @Binding var showDeleteDialog: Bool
    
    var body: some View {
        TraysScreenGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Tappable Content Area
                VStack(alignment: .leading, spacing: 16) {
                    // Header: Tray name + status badge
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tray \(metrics.tray.number)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(AppTheme.textPrimary)
                                .accessibilityAddTraits(.isHeader)
                            
                            Text("\(Formatters.shortMonthDay.string(from: metrics.tray.startDate)) → \(Formatters.shortMonthDay.string(from: metrics.endDate))")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary.opacity(0.94))
                        }
                        
                        Spacer()
                        
                        TraysScreenStatusBadge(status: badgeStatus(for: metrics))
                        
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .rotationEffect(.degrees(expandedTrayID == metrics.id ? -180 : 0))
                            .padding(.leading, 4)
                    }
                    
                    // Progress bar
                    TraysScreenProgressBar(
                        progress: metrics.progress,
                        label: progressLabel(for: metrics),
                        status: badgeStatus(for: metrics)
                    )
                    
                    // Metrics
                    if metrics.isDataUnavailable {
                        TraysScreenMetricRow(metrics: [
                            ("—", "compliance"),
                            ("—", "days passed"),
                            ("Data unavailable", "avg wear")
                        ])
                    } else {
                        let tertiaryValue = metrics.isCurrent
                            ? Formatters.durationShort(minutes: metrics.lifeDebtMinutes)
                            : (metrics.avgWear > 0 ? Formatters.durationShort(minutes: metrics.avgWear) : "—")
                        let tertiaryLabel = metrics.isCurrent ? "life debt" : "avg wear"

                        TraysScreenMetricRow(metrics: [
                            ("\(metrics.compliance)%", "compliance"),
                            ("\(metrics.passCount)/\(max(1, min(metrics.daysPassed, metrics.tray.plannedDays)))", "days passed"),
                            (tertiaryValue, tertiaryLabel)
                        ])
                    }
                    
                    // Expanded Daily Breakdown
                    if expandedTrayID == metrics.id {
                        TrayDayBreakdownList(logs: metrics.dailyLogs)
                            .padding(.top, 12)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if expandedTrayID == metrics.id {
                            expandedTrayID = nil
                        } else {
                            expandedTrayID = metrics.id
                        }
                    }
                }
                
                // MARK: - Action Buttons (Non-tappable area)
                if metrics.isCurrent {
                    if metrics.canAddExtraDay {
                        HStack(spacing: 10) {
                            TraysScreenActionButton(
                                title: "Add 1 Day",
                                icon: "calendar.badge.plus",
                                style: .secondary
                            ) {
                                viewModel.extendTrayByOneDay(id: metrics.tray.id)
                            }
                            .accessibilityHint("Extends this tray by one day")

                            TraysScreenActionButton(
                                title: "Delete Tray",
                                icon: "trash",
                                style: .destructive
                            ) {
                                trayToDelete = metrics.tray
                                showDeleteDialog = true
                            }
                            .accessibilityHint("Removes this tray only")
                        }
                    } else {
                        TraysScreenActionButton(
                            title: "Delete Tray",
                            icon: "trash",
                            style: .destructive
                        ) {
                            trayToDelete = metrics.tray
                            showDeleteDialog = true
                        }
                        .accessibilityHint("Removes this tray only")
                    }
                } else {
                    // Non-current tray: set current + delete
                    HStack(spacing: 10) {
                        TraysScreenActionButton(
                            title: "Set Current",
                            icon: "checkmark.circle",
                            style: .secondary
                        ) {
                            viewModel.setCurrentTray(id: metrics.tray.id)
                        }
                        .accessibilityHint("Makes this your active tray")
                        
                        TraysScreenActionButton(
                            title: "Delete",
                            icon: "trash",
                            style: .destructive
                        ) {
                            trayToDelete = metrics.tray
                            showDeleteDialog = true
                        }
                        .accessibilityHint("Removes this tray only")
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tray \(metrics.tray.number), \(progressLabel(for: metrics)), compliance \(metrics.compliance) percent")
    }
    
    // Extracted Helpers specific to the card
    private func badgeStatus(for metrics: TrayCardMetrics) -> TraysScreenStatus {
        if metrics.isCurrent {
            return .current
        } else if metrics.isComplete {
            return .completed
        } else {
            return .inactive
        }
    }
    
    private func progressLabel(for metrics: TrayCardMetrics) -> String {
        let day = min(metrics.daysPassed, metrics.tray.plannedDays)
        let total = metrics.tray.plannedDays
        
        if metrics.isCurrent && metrics.daysRemaining > 0 {
            return "Day \(day) of \(total) · \(metrics.daysRemaining)d remaining"
        } else {
            return "Day \(day) of \(total)"
        }
    }
}
    
    // MARK: - Add Tray Sheet
    
    private var addTraySheet: some View {
        NavigationStack {
            Form {
                Section("New Tray") {
                    TextField("Tray Number", text: $newTrayNumber)
                        .keyboardType(.numberPad)
                    TextField("Planned Days", text: $newTrayDays)
                        .keyboardType(.numberPad)
                    DatePicker("Start Time", selection: $newTrayStartDate)
                }
            }
            .navigationTitle("Add New Tray")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let number = Int(newTrayNumber), number > 0,
                              let days = Int(newTrayDays), (1...90).contains(days) else { return }
                        
                        // Haptic feedback
                        let notification = UINotificationFeedbackGenerator()
                        notification.notificationOccurred(.success)
                        
                        viewModel.addTray(number: number, plannedDays: days, startDate: newTrayStartDate)
                        showAddSheet = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showAddTraySheet() {
        newTrayDays = "\(viewModel.settings.plannedDaysPerTray)"
        newTrayNumber = "\((viewModel.trays.map(\.number).max() ?? 0) + 1)"
        newTrayStartDate = viewModel.now
        showAddSheet = true
    }
    
    private func badgeStatus(for metrics: TrayCardMetrics) -> TraysScreenStatus {
        if metrics.isCurrent {
            return .current
        } else if metrics.isComplete {
            return .completed
        } else {
            return .inactive
        }
    }
    
    private func progressLabel(for metrics: TrayCardMetrics) -> String {
        let day = min(metrics.daysPassed, metrics.tray.plannedDays)
        let total = metrics.tray.plannedDays
        
        if metrics.isCurrent && metrics.daysRemaining > 0 {
            return "Day \(day) of \(total) · \(metrics.daysRemaining)d remaining"
        } else {
            return "Day \(day) of \(total)"
        }
    }
}

// MARK: - Daily Breakdown Subview

struct TrayDayBreakdownList: View {
    let logs: [TrayDailyLog]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppTheme.textSecondary.opacity(0.2))
                .padding(.bottom, 12)
                
            ForEach(logs) { log in
                HStack(spacing: 12) {
                    // Day + Date
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Day \(log.dayNumber)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(Formatters.shortMonthDay.string(from: log.date))
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(width: 60, alignment: .leading)
                    
                    // Connecting Line / Dot
                    Circle()
                        .fill(dotColor(for: log.status))
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                        )
                        .shadow(color: dotColor(for: log.status).opacity(0.3), radius: 3)
                    
                    // Wear Time
                    if log.status == .future {
                        Text("—")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if log.status == .empty {
                         Text("No Data")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(Formatters.durationShort(minutes: log.wearMinutes))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private func dotColor(for status: DayStatus) -> Color {
        switch status {
        case .pass: return AppTheme.successGreen
        case .warn, .today: return AppTheme.warningOrange
        case .fail: return AppTheme.errorRed
        case .empty, .future: return AppTheme.textSecondary.opacity(0.3)
        }
    }
}
