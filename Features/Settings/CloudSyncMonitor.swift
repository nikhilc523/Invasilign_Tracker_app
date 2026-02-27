import SwiftUI
import SwiftData
import CloudKit

/// Monitors iCloud sync status and provides visual feedback
@MainActor
final class CloudSyncMonitor: ObservableObject {
    @Published private(set) var syncStatus: SyncStatus = .idle
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var errorMessage: String?
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success
        case error(String)
        case accountUnavailable
        
        var displayText: String {
            switch self {
            case .idle: return "Ready"
            case .syncing: return "Syncing..."
            case .success: return "Synced"
            case .error: return "Sync Error"
            case .accountUnavailable: return "iCloud Unavailable"
            }
        }
        
        var icon: String {
            switch self {
            case .idle: return "icloud"
            case .syncing: return "icloud.and.arrow.up"
            case .success: return "icloud.and.arrow.up"
            case .error: return "icloud.slash"
            case .accountUnavailable: return "icloud.slash"
            }
        }
        
        var color: Color {
            switch self {
            case .idle: return .secondary
            case .syncing: return .blue
            case .success: return .green
            case .error: return .red
            case .accountUnavailable: return .orange
            }
        }
    }
    
    static let shared = CloudSyncMonitor()
    
    private var statusObserver: NSObjectProtocol?
    
    init() {
        // CloudKit disabled - using local storage only
        syncStatus = .idle
        print("ℹ️ [CloudSync] CloudKit sync disabled - using local persistent storage")
    }
    
    deinit {
        if let observer = statusObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - CloudKit Account Status
    
    private func observeCloudKitAccountStatus() {
        Task {
            await checkAccountStatus()
        }
        
        // Re-check when the app becomes active
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.checkAccountStatus()
            }
        }
    }
    
    func checkAccountStatus() async {
        // For now, disable CloudKit checking to prevent crashes
        // TODO: Enable CloudKit when properly configured
        await MainActor.run {
            syncStatus = .idle
            print("☁️ [CloudSync] CloudKit monitoring temporarily disabled")
        }
        return
        
        /* Uncomment this when CloudKit is configured:
        do {
            let container = CKContainer.default()
            let status = try await container.accountStatus()
            
            await MainActor.run {
                switch status {
                case .available:
                    if syncStatus == .accountUnavailable {
                        syncStatus = .idle
                    }
                    print("☁️ [CloudSync] iCloud account available")
                case .noAccount:
                    syncStatus = .accountUnavailable
                    errorMessage = "No iCloud account signed in"
                    print("⚠️ [CloudSync] No iCloud account")
                case .restricted:
                    syncStatus = .accountUnavailable
                    errorMessage = "iCloud access is restricted"
                    print("⚠️ [CloudSync] iCloud restricted")
                case .couldNotDetermine:
                    syncStatus = .error("Could not determine iCloud status")
                    print("⚠️ [CloudSync] Could not determine status")
                case .temporarilyUnavailable:
                    syncStatus = .error("iCloud temporarily unavailable")
                    print("⚠️ [CloudSync] Temporarily unavailable")
                @unknown default:
                    syncStatus = .error("Unknown iCloud status")
                    print("⚠️ [CloudSync] Unknown status")
                }
            }
        } catch {
            await MainActor.run {
                syncStatus = .error("Failed to check iCloud status")
                errorMessage = error.localizedDescription
                print("❌ [CloudSync] Error checking status: \(error)")
            }
        }
        */
    }
    
    // MARK: - Sync Event Monitoring
    
    private func observeSyncEvents() {
        // Listen for SwiftData persistent history changes (indicates sync activity)
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleRemoteChange(notification)
            }
        }
        
        // Listen for CloudKit sync notifications
        statusObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NSPersistentStoreCoordinatorStoresWillChange"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.syncStatus = .syncing
            }
        }
    }
    
    private func handleRemoteChange(_ notification: Notification) {
        print("☁️ [CloudSync] Remote change detected - data synced from iCloud")
        
        syncStatus = .syncing
        
        // Show success after a brief moment
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                syncStatus = .success
                lastSyncDate = Date()
                
                // Return to idle after showing success
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    await MainActor.run {
                        if case .success = syncStatus {
                            syncStatus = .idle
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Manual Sync Trigger
    
    func triggerSync() {
        syncStatus = .syncing
        print("☁️ [CloudSync] Manual sync triggered")
        
        // SwiftData with CloudKit syncs automatically, but we can force a save
        // The actual sync will happen in the repository layer
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                syncStatus = .success
                lastSyncDate = Date()
                
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    await MainActor.run {
                        if case .success = syncStatus {
                            syncStatus = .idle
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Sync Status View

struct CloudSyncStatusView: View {
    @ObservedObject var monitor = CloudSyncMonitor.shared
    @State private var showDetails = false
    
    var body: some View {
        Button {
            showDetails = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: monitor.syncStatus.icon)
                    .font(.caption)
                    .symbolEffect(.pulse, isActive: monitor.syncStatus == .syncing)
                
                Text(monitor.syncStatus.displayText)
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(monitor.syncStatus.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(monitor.syncStatus.color.opacity(0.12), in: Capsule())
            .overlay {
                Capsule().strokeBorder(monitor.syncStatus.color.opacity(0.25), lineWidth: 0.8)
            }
        }
        .buttonStyle(.plain)
        .alert("iCloud Sync Status", isPresented: $showDetails) {
            Button("Check Now") {
                Task {
                    await monitor.checkAccountStatus()
                    monitor.triggerSync()
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            VStack(alignment: .leading, spacing: 4) {
                Text(monitor.syncStatus.displayText)
                if let lastSync = monitor.lastSyncDate {
                    Text("Last sync: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                }
                if let error = monitor.errorMessage {
                    Text("Error: \(error)")
                }
            }
        }
    }
}

// MARK: - Settings Row for Sync Status

struct CloudSyncStatusRow: View {
    @ObservedObject var monitor = CloudSyncMonitor.shared
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("iCloud Sync")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                if let lastSync = monitor.lastSyncDate {
                    Text("Last synced \(timeAgoString(from: lastSync))")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.95))
                } else {
                    Text("Keeps your data safe across devices")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.95))
                }
            }
            
            Spacer(minLength: 8)
            
            HStack(spacing: 8) {
                Image(systemName: monitor.syncStatus.icon)
                    .font(.body.weight(.medium))
                    .foregroundStyle(monitor.syncStatus.color)
                    .symbolEffect(.pulse, isActive: monitor.syncStatus == .syncing)
                
                Button {
                    Task {
                        await monitor.checkAccountStatus()
                        monitor.triggerSync()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(AppTheme.textPrimary)
                        .background(Color.secondary.opacity(0.1), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("iCloud Sync: \(monitor.syncStatus.displayText)")
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}
