import Foundation
import SwiftData

@MainActor
final class AppContext: ObservableObject {
    let store: TrackingStore
    private let watchConnectivity = WatchConnectivityManager.shared

    init(modelContext: ModelContext) {
        let repository = SwiftDataTrackingRepository(context: modelContext)
        self.store = TrackingStore(repository: repository)
        watchConnectivity.configure(with: store)

        Task {
            await store.load()
            watchConnectivity.syncToWatch()
        }
    }
}
