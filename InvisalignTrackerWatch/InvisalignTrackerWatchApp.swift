import SwiftUI

@main
struct InvisalignTrackerWatchApp: App {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
                .onAppear {
                    // Request initial sync
                    connectivity.requestSync()
                }
                .onOpenURL { url in
                    guard url.scheme == "invisaligntracker" else { return }
                    if url.host == "aligner", url.path == "/backin" {
                        connectivity.stopSession()
                    } else {
                        connectivity.requestSync()
                    }
                }
        }
    }
}
