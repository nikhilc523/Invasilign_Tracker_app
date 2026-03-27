// INTEGRATION INSTRUCTIONS FOR iOS APP
// Add this code to your AppContext.swift file

/*
In your AppContext class, add this property:

    private let watchConnectivity = WatchConnectivityManager.shared

In your init() method, after creating the store, add:

    init(modelContext: ModelContext) {
        // ... existing initialization code ...
        
        // Configure watch connectivity
        watchConnectivity.configure(with: store)
        
        // Initial sync
        Task {
            await store.load()
            watchConnectivity.syncToWatch()
        }
    }

In your TrackingStore.toggleAligner() method, add this after await load():

    func toggleAligner(now: Date = Date()) async {
        do {
            try await repository.toggleAligner(at: now)
            await load()
            
            // ADD THIS LINE:
            WatchConnectivityManager.shared.syncToWatch()
            
            // ... rest of existing code ...
        }
    }

Also add sync calls in these methods after `await load()`:
- deleteSession
- addTray
- setCurrentTray
- updateSettings

This ensures the watch stays in sync whenever data changes.
*/
