import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appContext: AppContext

    var body: some View {
        TabView {
            NavigationStack { TodayView(store: appContext.store) }
                .tabItem { Label("Today", systemImage: "sun.max") }

            NavigationStack { TimerView(store: appContext.store) }
                .tabItem { Label("Timer", systemImage: "timer") }

            NavigationStack { CalendarView(store: appContext.store) }
                .tabItem { Label("Calendar", systemImage: "calendar") }

            NavigationStack { TraysView(store: appContext.store) }
                .tabItem { Label("Trays", systemImage: "square.stack.3d.up") }

            NavigationStack { SettingsView(store: appContext.store) }
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(AppTheme.textPrimary)
        .task {
            if !appContext.store.isLoaded {
                await appContext.store.load()
            }
        }
    }
}
