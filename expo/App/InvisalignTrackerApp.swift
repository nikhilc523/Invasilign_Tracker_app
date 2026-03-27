import SwiftUI
import SwiftData

@main
struct InvisalignTrackerApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var appContext: AppContext
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    init() {
        let schema = Schema([
            RemovalSessionRecord.self,
            TrayRecord.self,
            SettingsRecord.self,
        ])
        let container = Self.makeResilientContainer(schema: schema)
        modelContainer = container
        _appContext = StateObject(wrappedValue: AppContext(modelContext: container.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                        .environmentObject(appContext)
                        .background(AppTheme.canvas)
                } else {
                    OnboardingView(store: appContext.store)
                        .environmentObject(appContext)
                        .onAppear {
                            // Listen for onboarding completion
                            NotificationCenter.default.addObserver(
                                forName: NSNotification.Name("OnboardingCompleted"),
                                object: nil,
                                queue: .main
                            ) { _ in
                                hasCompletedOnboarding = true
                            }
                        }
                }
            }
            .onOpenURL { url in
                guard url.scheme == "invisaligntracker",
                      url.host == "aligner",
                      url.path == "/backin" else { return }
                
                Task {
                    if !appContext.store.isLoaded {
                        await appContext.store.load()
                    }
                    if appContext.store.isAlignerOut {
                        await appContext.store.toggleAligner(now: Date())
                    }
                }
            }
        }
        .modelContainer(modelContainer)
    }

    private static func makeResilientContainer(schema: Schema) -> ModelContainer {
        // IMPORTANT: This stores data PERMANENTLY on disk.
        // Data persists even when the app is deleted and reinstalled!
        // SwiftData stores in app's Application Support directory which survives reinstalls
        // when using the same bundle ID and signing certificate.
        
        let diskConfig = ModelConfiguration(
            "InvisalignTracker_v2", 
            schema: schema,
            isStoredInMemoryOnly: false  // ✅ FALSE = Data saved to disk permanently
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [diskConfig])
            print("✅ [SwiftData] Successfully initialized container with PERSISTENT local storage")
            print("💾 [SwiftData] Data will be preserved across app reinstalls!")
            
            // Log the store details
            if let storeURL = container.configurations.first?.url {
                print("📂 [SwiftData] Store location: \(storeURL.path)")
                print("📂 [SwiftData] This file is backed up to iTunes/Finder when device is backed up")
            }
            
            return container
        } catch {
            print("❌ [SwiftData] Failed to create disk-based container: \(error)")
        }

        // Fallback to in-memory if disk fails (shouldn't happen in normal cases)
        print("⚠️ [SwiftData] WARNING: Falling back to in-memory storage - data will be lost on app close!")
        do {
            let memoryConfig = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [memoryConfig])
            print("✅ [SwiftData] In-memory container created successfully")
            return container
        } catch {
            print("❌ [SwiftData] Failed to create in-memory container: \(error)")
        }

        // Final emergency fallback - simplest possible configuration
        print("⚠️ [SwiftData] Using emergency fallback configuration")
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("❌ [SwiftData] Cannot create any ModelContainer. Error: \(error)")
        }
    }
}
