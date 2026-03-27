import SwiftUI

#Preview("Single Current Tray") {
    TraysPreviewContainer(scenario: .singleCurrent)
}

#Preview("Multiple Trays") {
    TraysPreviewContainer(scenario: .multipleTrays)
}

#Preview("Empty State") {
    TraysPreviewContainer(scenario: .empty)
}

#Preview("Dark Mode - Multiple Trays") {
    TraysPreviewContainer(scenario: .multipleTrays)
        .preferredColorScheme(.dark)
}

#Preview("Dark Mode - Empty State") {
    TraysPreviewContainer(scenario: .empty)
        .preferredColorScheme(.dark)
}

// MARK: - Preview Container

private struct TraysPreviewContainer: View {
    @Environment(\.colorScheme) private var colorScheme
    let scenario: PreviewScenario
    
    var body: some View {
        ZStack {
            pageBackground
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack(alignment: .center) {
                        Text("Trays")
                            .font(.largeTitle.bold())
                            .tracking(-0.5)
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        AddTrayButton {}
                    }
                    .padding(.vertical, 6)
                    
                    // Content
                    switch scenario {
                    case .empty:
                        TraysEmptyState(onAddTray: {})
                    
                    case .singleCurrent:
                        singleCurrentTrayCard
                    
                    case .multipleTrays:
                        multipleTraysCards
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var pageBackground: some View {
        ZStack {
            LinearGradient(
                colors: TraysVisualTokens.pageGradient(for: colorScheme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.06 : 0.22),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 14,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Single Current Tray
    
    private var singleCurrentTrayCard: some View {
        TrayGlassCard {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tray 14")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text("Feb 10 → Feb 24")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Spacer()
                
                TrayStatusBadge(status: .current)
            }
            
            // Progress
            TrayProgressBar(
                progress: 0.60,
                label: "Day 9 of 15 · 6d remaining"
            )
            
            // Metrics
            TrayMetricRow(metrics: [
                ("88%", "compliance"),
                ("7/9", "days passed"),
                ("19h 24m", "avg wear")
            ])
            
            // Action
            TrayActionButton(
                title: "Delete Tray",
                icon: "trash",
                style: .destructive
            ) {}
        }
    }
    
    // MARK: - Multiple Trays
    
    private var multipleTraysCards: some View {
        LazyVStack(spacing: 14) {
            // Completed tray
            TrayGlassCard {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tray 12")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Jan 13 → Jan 27")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    TrayStatusBadge(status: .completed)
                }
                
                TrayProgressBar(
                    progress: 1.0,
                    label: "Day 15 of 15"
                )
                
                TrayMetricRow(metrics: [
                    ("93%", "compliance"),
                    ("14/15", "days passed"),
                    ("20h 42m", "avg wear")
                ])
                
                HStack(spacing: 10) {
                    TrayActionButton(
                        title: "Set Current",
                        icon: "checkmark.circle",
                        style: .secondary
                    ) {}
                    
                    TrayActionButton(
                        title: "Delete",
                        icon: "trash",
                        style: .destructive
                    ) {}
                }
            }
            
            // Completed tray (older)
            TrayGlassCard {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tray 13")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Jan 28 → Feb 9")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    TrayStatusBadge(status: .completed)
                }
                
                TrayProgressBar(
                    progress: 1.0,
                    label: "Day 14 of 14"
                )
                
                TrayMetricRow(metrics: [
                    ("100%", "compliance"),
                    ("14/14", "days passed"),
                    ("22h 18m", "avg wear")
                ])
                
                HStack(spacing: 10) {
                    TrayActionButton(
                        title: "Set Current",
                        icon: "checkmark.circle",
                        style: .secondary
                    ) {}
                    
                    TrayActionButton(
                        title: "Delete",
                        icon: "trash",
                        style: .destructive
                    ) {}
                }
            }
            
            // Current tray
            TrayGlassCard {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tray 14")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Feb 10 → Feb 24")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    TrayStatusBadge(status: .current)
                }
                
                TrayProgressBar(
                    progress: 0.60,
                    label: "Day 9 of 15 · 6d remaining"
                )
                
                TrayMetricRow(metrics: [
                    ("88%", "compliance"),
                    ("7/9", "days passed"),
                    ("19h 24m", "avg wear")
                ])
                
                TrayActionButton(
                    title: "Delete Tray",
                    icon: "trash",
                    style: .destructive
                ) {}
            }
            
            // Future tray
            TrayGlassCard {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tray 15")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Feb 25 → Mar 11")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    TrayStatusBadge(status: .inactive)
                }
                
                TrayProgressBar(
                    progress: 0.0,
                    label: "Day 0 of 15"
                )
                
                TrayMetricRow(metrics: [
                    ("—", "compliance"),
                    ("0/15", "days passed"),
                    ("—", "avg wear")
                ])
                
                HStack(spacing: 10) {
                    TrayActionButton(
                        title: "Set Current",
                        icon: "checkmark.circle",
                        style: .secondary
                    ) {}
                    
                    TrayActionButton(
                        title: "Delete",
                        icon: "trash",
                        style: .destructive
                    ) {}
                }
            }
        }
    }
}

private enum PreviewScenario {
    case empty
    case singleCurrent
    case multipleTrays
}
